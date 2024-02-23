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
      return if @queue.nil? || RSpec.world.wants_to_quit

      @queue.push(notification)
    end

    private

    def thread
      while notification = @queue.pop
        break if notification == :close

        if notification
          system("buildkite-agent", "annotate",
            "--context", "rspec-#{ENV["BUILDKITE_STEP_KEY"]}",
            "--style", "error",
            "--append",
            format_failure(notification),
            out: :close # only display errors
          ) or raise "buildkite-agent failed to run: #{$?}#{" (command not found)" if $?.exitstatus == 127}"
        end
      end
    rescue
      $stderr.puts "Warning: Couldn't create Buildkite annotations:\n" <<
        "  #{$!.to_s}\n" <<
        "    #{$!.backtrace.join("\n    ")}"
    end

    def format_failure(notification)
      build_url = ENV["BUILDKITE_BUILD_URL"].to_s
      job_id = ENV["BUILDKITE_JOB_ID"].to_s
      step_name = "Job ##{job_id.encode(:xml => :text)} "

      if ENV["BUILDKITE_LABEL"]
        step_name = ENV["BUILDKITE_LABEL"]
        if ENV["BUILDKITE_PARALLEL_JOB"] && ENV["BUILDKITE_PARALLEL_JOB_COUNT"]
          step_name += " (#{ENV["BUILDKITE_PARALLEL_JOB"]}/#{ENV["BUILDKITE_PARALLEL_JOB_COUNT"]})"
        end
      end
      job_url = "#{build_url}##{job_id}"

      %{<details>\n} <<
      %{<summary>#{notification.description.encode(:xml => :text)}</summary>\n} <<
      %{<pre class="term">#{Recolorizer.recolorize(notification.colorized_message_lines.join("\n").encode(:xml => :text))}</pre>\n} <<
      format_rerun(notification) <<
      %{<p>in <a href=#{job_url.encode(:xml => :attr)}>#{step_name}</a></p>\n} <<
      %{</details>} <<
      %{\n\n\n}
    end

    def format_rerun(notification)
      %{<pre class="term">} <<
      %{<span class="term-fg31">rspec #{notification.example.location_rerun_argument.encode(:xml => :text)}</span>} <<
      %{ <span class="term-fg36"># #{notification.example.full_description.encode(:xml => :text)}</span>} <<
      %{</pre>\n}
    end
  end
end
