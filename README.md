# JFormalize

Loads, parses and validates a JSON file into formalized ruby objects according to a schema.

According to the dictionary, to formalize is to:

1. To make agree with a single established standard or model
2. To give official acceptance of as satisfactory
3. To make solemn, or official, through ceremony or legal act
4. To represent in a particular style

While it is humorous to think of JSON involving solemnity, officialness or legality, 
it certainly involves ceremony.

This gem provides a simple way to validate a file, load it as JSON, parse it and formalize objects into ruby objects.

This involves a process like this:

- PreLoad
- Load
- Objectify
- Formalize

## `PreLoad`

This involves verifying that a provide file pass the following tests:

1. It must exist
2. It must be a file (e.g. not a directory)
3. It must be readable
4. It must not be too big
5. 

The first 3 are self explanatory.
Number 4 and 5 require some explanation.

A file has a size and the gem tests that this size does not exceed a limit.
The allowed maximum size either defaults to 1,000,000 characters or a value provided to the pre-loader.



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'JFormalize'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install JFormalize

## Usage

### Testing

```bash
clear; bundle exec rake; bundle exec rubocop
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, 
which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/JFormalize. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to 
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JFormalize project’s codebases, issue trackers, chat rooms and mailing lists is 
expected to follow the [code of conduct](https://github.com/[USERNAME]/jsvad/blob/master/CODE_OF_CONDUCT.md).
