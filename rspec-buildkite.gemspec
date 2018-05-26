lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rspec/buildkite/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-buildkite"
  spec.version       = RSpec::Buildkite::VERSION
  spec.author        = "Samuel Cochran"
  spec.email         = "sj26@sj26.com"

  spec.summary       = %q{RSpec formatter creating Buildkite annotations for failures}
  spec.homepage      = "https://github.com/sj26/rspec-buildkite"
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/*"]

  spec.required_ruby_version = "~> 2.2"

  spec.add_dependency "rspec-core", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "coderay"
  spec.add_development_dependency "appraisal"
end
