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
          system "buildkite-agent", "annotate",
            "--context", "rspec",
            "--style", "error",
            "--append",
            format_failure(notification),
            out: :close # only display errors
        end
      end
    rescue
      puts "Warning: Couldn't create Buildkite annotations:"
      puts "  " << $!.to_s, "    " << $!.backtrace.join("\n    ")
    end

    def format_failure(notification)
      build_url = ENV["BUILDKITE_BUILD_URL"].to_s
      job_id = ENV["BUILDKITE_JOB_ID"].to_s
      job_url = "#{build_url}##{job_id}"

      %{<details>\n} <<
      %{<summary>#{notification.description.encode(:xml => :text)}</summary>\n\n} <<
      %{<code><pre class="term">#{Recolorizer.recolorize(notification.colorized_message_lines.join("\n").encode(:xml => :text))}</pre></code>\n\n} <<
      %{in <a href=#{job_url.encode(:xml => :attr)}>Job ##{job_id.encode(:xml => :text)}</a>\n} <<
      %{</details>} <<
      %{\n\n\n}
    end
  end
end
