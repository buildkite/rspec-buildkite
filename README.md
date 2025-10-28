# RSpec Buildkite

Output [RSpec][rspec] failure messages as [Buildkite annotations][buildkite-annotations] as soon as they happen so you can fix them while your build finishes.

[![A Buildkite build still in progress with an annotation showing an RSpec failure][screenshot]](https://buildkite.com/buildkite/rspec-buildkite)

  [rspec]: http://rspec.info
  [buildkite-annotations]: https://buildkite.com/docs/agent/v3/cli-annotate
  [screenshot]: https://user-images.githubusercontent.com/14028/40577709-5b839e8a-614d-11e8-898b-575bb0cc02ba.png

## Installation

Add the gem to your Gemfile, after rspec:

```ruby
gem "rspec"
gem "rspec-buildkite"
```

And then bundle:

    $ bundle

Or install it yourself as:

    $ gem install rspec-buildkite

## Usage

Add it to your `.rspec` alongside your favorite formatter:

```
--color
--require spec_helper
--format documentation
--format RSpec::Buildkite::AnnotationFormatter
```

Now run your specs on Buildkite!

### Docker & Docker Compose

If you run your RSpec builds inside Docker or Docker Compose then you'll need to make sure that buildkite-agent is available inside your container, and that some environment variables are propagated into the running containers. The buildkite-agent binary can be baked into your image, or mounted in as a volume. If you're using [the docker-compose-buildkite-plugin][dcbp] you can pass the environment using [plugin configuration][dcbp-env]. Or you can add them to the [environment section][dc-env] in your `docker-compose.yml`, or supply [env arguments][d-env] to your docker command.

The following environment variables are required:

- `BUILDKITE`
- `BUILDKITE_BUILD_URL`
- `BUILDKITE_JOB_ID`
- `BUILDKITE_AGENT_ACCESS_TOKEN`

  [dcbp]: https://github.com/buildkite-plugins/docker-compose-buildkite-plugin
  [dcbp-env]: https://github.com/buildkite-plugins/docker-compose-buildkite-plugin#environment
  [dc-env]: https://docs.docker.com/compose/environment-variables/
  [d-env]: https://docs.docker.com/engine/reference/run/#env-environment-variables

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/buildkite/rspec-buildkite.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
