module RSpec::Buildkite
  module Recolorizer
    module_function

    # Re-color an ANSI-colorized string using terminal CSS classes:
    # https://github.com/buildkite/terminal/blob/05a77905c468b9150cac41298fdb8a0735024d42/style.go#L34
    def recolorize(string)
      level = 0
      string.gsub(/\e\[(\d+(?:;\d+)*)m/) do
        "".tap do |buffer|
          codes = $1.split(";").map(&:to_i)

          classes = []
          while code = codes.shift
            case code
            when 0
              classes.clear
              buffer << ("</span>" * level)
              level = 0
            when 1..5, 9, 30..37
              classes << "term-fg#{code}"
            when 38
              if codes[0] == 5
                codes.shift
                if codes[0]
                  classes << "term-fgx#{codes.shift}"
                end
              end
            when 40..47
              classes << "term-bg#{code}"
            when 48
              if codes[0] == 5
                codes.shift
                if codes[0]
                  classes << "term-bgx#{codes.shift}"
                end
              end
            when 90..97
              classes << "term-fgi#{code}"
            when 100..107
              classes << "term-bgi#{code}"
            end
          end

          if classes.any?
            level += 1
            buffer << %{<span class=#{classes.map { |klass| klass }.join(" ").encode(:xml => :attr)}>}
          end
        end
      end << ("</span>" * level)
    end
    # Re-color an ANSI-colorized string using terminal CSS classes:
    # https://github.com/buildkite/terminal/blob/05a77905c468b9150cac41298fdb8a0735024d42/style.go#L34
    def recolorize(string)
      level = 0
      string.gsub(/\e\[(\d+(?:;\d+)*)m/) do
        "".tap do |buffer|
          codes = $1.split(";").map(&:to_i)

          classes = []
          while code = codes.shift
            case code
            when 0
              classes.clear
              buffer << ("</span>" * level)
              level = 0
            when 1..5, 9, 30..37
              classes << "term-fg#{code}"
            when 38
              if codes[0] == 5
                codes.shift
                if codes[0]
                  classes << "term-fgx#{codes.shift}"
                end
              end
            when 40..47
              classes << "term-bg#{code}"
            when 48
              if codes[0] == 5
                codes.shift
                if codes[0]
                  classes << "term-bgx#{codes.shift}"
                end
              end
            when 90..97
              classes << "term-fgi#{code}"
            when 100..107
              classes << "term-bgi#{code}"
            end
          end

          if classes.any?
            level += 1
            buffer << %{<span class=#{classes.map { |klass| klass }.join(" ").encode(:xml => :attr)}>}
          end
        end
      end << ("</span>" * level)
    end
  end
end
