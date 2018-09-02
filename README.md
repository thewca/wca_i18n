# WcaI18n [![Build Status](https://travis-ci.org/thewca/wca_i18n.svg?branch=master)](https://travis-ci.org/thewca/wca_i18n)

Use this Gem to diff Rails translations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wca_i18n'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wca_i18n

## Usage

### Using the wca_i18n executable

Use the included `wca_i18n` binary to compare translations to a base translation to see
how out of date they are.

```bash
$ wca_i18n en.yml *.yml
```

### Using the wca_i18n library

There are two parts to this library: `WcaI18n::YAMLWithComments` (a YAML parser
that preserves comments) and `WcaI18n::Translation` (used to load and diff
translation YAML files). Until we have better documentation, it's best to look
at our [specs](https://github.com/thewca/wca_i18n/tree/master/spec) for how to
them.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thewca/wca_i18n.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
