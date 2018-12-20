require "pathname"
require "thread"

require "rspec/core"
require "rspec/buildkite/recolorizer"

module RSpec::Buildkite
  # Create a Buildkite annotation for RSpec failures
  #
  # Help folks fix their builds as soon as possible when failures crop up by
  # calling out failures in an annotation, even while the build is still running.
  #
  # Uses a background Thread so we don't block the build.
  #
  class AnnotationFormatter
    RSpec::Core::Formatters.register self, :example_failed

    def initialize(output)
      # We don't actually use this, but keep a reference anyway
      @output = output

      # Only setup if we're actually running on Buildkite
      if ENV["BUILDKITE"]
        @queue = Queue.new
        @thread = Thread.new(&method(:thread))
        at_exit { @queue.push(:close); @thread.join }
      end
    end

    def example_failed(notification)
      @queue.push(notification) if @queue
    end

    private

    def thread
      while notification = @queue.pop
        break if notification == :close

        if notification
          if screenshot = notification.example.metadata[:screenshot]
            screenshot = prepare_screenshot(screenshot)
          end

          system "buildkite-agent", "annotate",
            "--context", "rspec",
            "--style", "error",
            "--append",
            format_failure(notification, screenshot: screenshot),
            out: :close # only display errors
        end
      end
    rescue
      puts "Warning: Couldn't create Buildkite annotations:"
      puts "  " << $!.to_s, "    " << $!.backtrace.join("\n    ")
    end

    def prepare_screenshot(screenshot)
      # Take only image and html screenshots
      screenshot = screenshot.slice(:image, :html)

      # Make sure they're relative paths
      screenshot.transform_values do |path|
        Pathname.new(File.expand_path(path)).relative_path_from(Dir.pwd)
      end

      # Upload them as artifacts
      screenshot.each do |_, path|
        system "buildkite-agent", "artifact", "upload", path,
          out: :close # only display errors
      end

      # And turn them into artifact URLs
      screenshot.transform_values do |path|
        "artifact://#{path}"
      end
    end

    def format_failure(notification, screenshot: nil)
      build_url = ENV["BUILDKITE_BUILD_URL"].to_s
      job_id = ENV["BUILDKITE_JOB_ID"].to_s
      job_url = "#{build_url}##{job_id}"

      %{<details>\n} <<
      %{<summary>#{notification.description.encode(:xml => :text)}</summary>\n} <<
      %{<pre class="term">#{Recolorizer.recolorize(notification.colorized_message_lines.join("\n").encode(:xml => :text))}</pre>\n} <<
      %{#{format_screenshot(screenshot) if screenshot}} <<
      %{<pre class="term">rspec #{notification.example.location_rerun_argument.encode(:xml => :text)}</pre>\n} <<
      %{<p>in <a href=#{job_url.encode(:xml => :attr)}>Job ##{job_id.encode(:xml => :text)}</a></p>\n} <<
      %{</details>} <<
      %{\n\n\n}
    end

    def format_screenshot(image: nil, html: nil, **)
      %{<p>Screenshot: #{[%{<a href=#{image.encode(:xml => :attr)}>Image</a>}, %{<a href=#{image.encode(:xml => :attr)}>HTML</a>}].compact.join(", ")}</p>\n}
    end
  end
end
