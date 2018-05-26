# RSpec Buildkite

Output [RSpec][rspec] failure messages as [Buildkite annotations][buildkite-annotations] as soon as they happen so you can fix them while your build finishes.

![A Buildkite build still in progress with an annotation showing an RSpec failure][screenshot]

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sj26/rspec-buildkite.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
