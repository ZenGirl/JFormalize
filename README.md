# JFormalize

## Back story

This gem was created based on several in-application gems created over the years.

The requirement to have a simple parser, validator, defaulter and formalizer for incoming JSON has recurred repeatedly for me over the years.
This gem is simply a wrap up of those requirements.

Loads, parses and validates JSON input into formalized ruby objects according to a schema.

According to the dictionary, to formalize is to:

1. To make agree with a single established standard or model
2. To give official acceptance of as satisfactory
3. To make solemn, or official, through ceremony or legal act
4. To represent in a particular style

While it is humorous to think of JSON involving solemnity, officialness or legality, 
it certainly involves ceremony.

This gem provides a simple way to validate an incoming JSON string, load it, parse it and formalize objects
according to a provided schema into ruby objects.

## Acknowledgements

Due to my choice not to include any external runtime dependencies, this gem includes a cut-down version of `Interactor`.

See https://github.com/collectiveidea/interactor for full codebase

I **LOVE** this gem, and Collective Idea have some great gems.
Show them some love at https://collectiveidea.com/

Normally I would simply add the complete gem as a runtime dependency, but I'm avoiding
having any external runtime dependencies.
As such, I messed about pulling some code in but not others.
Tests exist for this.

Note that I've had to use rubocop directives so that the original
code is as close to Collective Ideas code.

Apologies.

## Usage

The engine requires 3 arguments: `json_string`, `max_size` and a `schema`.

The `json_string` is normally read from a file, but can be created from a hash like this:

```ruby
json_h = [
  {
    _id:              1,
    url:              'http://goober.bubly.com/api/v2/users/1.json',
    external_id:      '74341f74-9c79-49d5-9611-87ef9b6eb75f',
    name:             'Francisca Rasmussen',
    alias:            'Miss Coffey',
    created_at:       '2019-12-31T05:19:46 -10:00',
    active:           true,
    verified:         true,
    shared:           false,
    locale:           'en-AU',
    timezone:         'AEST',
    last_login_at:    '2020-01-01T01:03:27 -10:00',
    email:            'coffeyrasmussen@flotonic.com',
    phone:            '0555-422-718',
    signature:        'Don\'t Worry Be Happy!',
    organization_id:  119,
    tags:             %w(Springville Sutton Hartsville/Hartley Diaperville),
    suspended:        true,
    role:             'admin'
  }
]
json_string = JSON.generate(json_h)
```

The `max_size` defaults to 100,000 if the value is `nil`.
For example:

```ruby
max_size = nil 
max_size = 100_000
```

Are equivalent.

The `schema` is a definition of the fields that are expected in the incoming data.
For example:

```ruby
schema      = {
  _id:             {type: :integer},
  url:             {type: :url},
  external_id:     {type: :guid},
  name:            {type: :string},
  alias:           {type: :string},
  created_at:      {type: :datetime},
  active:          {type: :boolean},
  verified:        {type: :boolean},
  shared:          {type: :boolean},
  locale:          {type: :locale},
  timezone:        {type: :timezone},
  last_login_at:   {type: :datetime},
  email:           {type: :email},
  phone:           {type: :regex, match: /\d\d\d\d-\d\d\d-\d\d\d/},
  signature:       {type: :string},
  organization_id: {type: :integer},
  tags:            {type: :array, subtype: :string},
  suspended:       {type: :boolean},
  role:            {type: :string, allowed: %w[admin agent end_user]}
}
```

Each key/value pair consists of the expected key name and a hash.
The "types" here are a set of constants internal to the gem.
The allowed set is as follows:

| Type | Must | Options | Default |
| ---- | ---- | ------- | ------- |
| `string` | be a ruby string | `:allowed` value array *1 | `''`
| `guid` | match `guid_re` | | `00000000-0000-0000-0000-000000000000` |
| `integer` | be a ruby integer | | `0` |
| `url` | match `url_re` | | `''` |
| `datetime` | succeed a `Time.parse` | | `1970-01-01T10:00:00 -10:00` |
| `boolean` | be true or false | | false |
| `locale` | at this point, simply a string | | `''` |
| `timezone` | at this point, simply a string | | `''` |
| `email` | match `email_re` | | `''` |
| `regex` | match the `:match` key-value | | `''` |
| `array` | be a ruby array | `:allowed` array & `:subtype` type *2 | `[]` |

- `guid_re` == `/\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b/`
- `email_re` == `/\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i`
- `url_re` == `%r{https?://[\S]+}`

- **1**. e.g. `{type: :string, allowed: %w[admin agent end_user]}`
- **2**. e.g. `{type: :array, subtype: :integer, allowed: [1,3,5,7,9]}`

> **Note:** There is no ability to have the schema recurse at this time.
That is, you can't have the type `:object` which itself is a schema.
This also applies to arrays of `:object`
  
> Floats and other types will be supported in a later version 

The incoming schema can have an additional value pair to provide a default value.

The engine can now be called with the arguments:

```ruby
result = JFormalize::Engine.call(
  json_string: json_string,
  max_size:    max_size,
  schema:      schema
)
```

If all is ok, then the result hash various outputs:

| key | meaning |
| --- | ------- |
| `success?` | `true` or `false` |
| `errors` | Array of error messages |
| `formalized_objects` | An array of formalized objects |

Internally, 3 interactors are called to validate and formalize the incoming JSON.
They are `PreLoad`, `Objectify` and `Formalize`. 
Each may generate error messages and fail fast.

Errors are generated based on these criteria:

1. The `max_size` must be a reasonable size (between 100 and 10,000,000 characters)
2. The `json_string` must:
    1. be a string
    2. not be empty
    3. not be too big 
    4. not contain non UTF-8 characters
    5. match a simple JSON regex
    6. be parseable
3. The `schema` must:
    1. be a hash
    2. have values that are hashes
    3. have values hash that have a `type` key
    4. have values hash key `type` key that is allowed 
4. The parsed `json_string` keys must:
    1. validate against to the `type`









## Details

### `PreLoad`

The incoming string must match a simple regex to proceed.
That regex is shown below:

```ruby
# For reference, this is modified from:
# https://stackoverflow.com/questions/2583472/regex-to-validate-json
# rubocop:disable Style/MutableConstant, Style/RegexpLiteral
JSON_REGEX = /(
  # define subtypes and build up the json syntax, BNF-grammar-style
  # The {0} is a hack to simply define them as named groups here but not match on them yet
  # I added some atomic grouping to prevent catastrophic backtracking on invalid inputs
  (?<number>  -?(?=[1-9]|0(?!\d))\d+(\.\d+)?([eE][+-]?\d+)?){0}
  (?<boolean> true | false | null ){0}
  (?<string>  " (?>[^"\\\\]* | \\\\ ["\\\\bfnrt\/] | \\\\ u [0-9a-f]{4} )* " ){0}
  (?<array>   \[ (?> \g<json> (?: , \g<json> )* )? \s* \] ){0}
  (?<pair>    \s* \g<string> \s* : \g<json> ){0}
  (?<object>  \{ (?> \g<pair> (?: , \g<pair> )* )? \s* \} ){0}
  (?<json>    \s* (?> \g<number> | \g<boolean> | \g<string> | \g<array> | \g<object> ) \s* ){0}
)
\A \g<json> \Z
/uix
# rubocop:enable Style/MutableConstant, Style/RegexpLiteral
```

> The `rubocop` notations are simply to avoid unnecessary messages.

> **Note:** At some point this may be changed to use `max_objects` as well as `max_size`

After the string has been verified, the provided schema has to be checked.
Here is an example schema:

```ruby
schema = {
  _id:             {type: :integer},
  url:             {type: :url},
  external_id:     {type: :guid},
  name:            {type: :string},
  alias:           {type: :string},
  created_at:      {type: :datetime},
  active:          {type: :boolean},
  verified:        {type: :boolean},
  shared:          {type: :boolean},
  locale:          {type: :locale},
  timezone:        {type: :timezone},
  last_login_at:   {type: :datetime},
  email:           {type: :email},
  phone:           {type: :regex, match: /\d\d\d\d-\d\d\d-\d\d\d/},
  signature:       {type: :string},
  organization_id: {type: :integer},
  tags:            {type: :array, subtype: :string},
  suspended:       {type: :boolean},
  role:            {type: :string, allowed: %w[admin agent end_user]}
}.freeze
```

### `Objectify`

The purpose of this is simply to isolate the parsing of the incoming string.

Any `JSONError` exceptions are wrapped in a `JFormalize::Exceptions::JSONError` with a formatted backtrace.

The output of this is an internal set of raw objects from the incoming string.






### `Formalize`

This is the meat of the full process.
The internal `objects` built by the `Objectify` class are iterated.

- Each object is scanned, and matched to the schema provided.
- Non-matching keys are ignored and discarded.
- Each present matching key has its value validated against the schema.
- Each non-present key has a default applied based on either a) the `:default` value in the schema, or b) a meaningful default if not.

This creates a formalised list of objects.

If a key is present in the object, but the value of that key does not match the schema test, then an error is added to an internal list.
This list is available externally after processing.

Exceptions are *not* raised during the process, but at the end if the errors list has any values.
That exception is `JFormalize::Exceptions::SchemaMismatch` and includes the error list (formatted).


### Examples

```ruby
json_value  = [
                {
                  _id:    1,
                  name:   'Billy Bob',
                  goober: 'Goober',
                  phone:  '(0555) 123 456',
                  tags:   %w(One Two Three),
                  gonzo:  'Gonzo',
                  active: true                  
                },
                {
                  _id:    1,
                  name:   'Billy Bob',
                  phone:  '(0555) 123 456',
                  tags:   %w(One Two Three),
                  bongo:  {
                          a: 1, b: 2, c: 3
                          },
                  active: true                  
                }
              ]
json_string = JSON.generate(json_value)
max_size    = 100_000
schema      = {
              _id:    {type: :integer},
              name:   {type: :string},
              phone:  {type: :regex, match: /\(\d\d\d\d\) \d\d\d \d\d\d/},
              tags:   {type: :string, subtype: :string},
              active: {type: :boolean}
              }
result = JFormalize::Engine.call(json_string, max_size, schema)

# Assuming no errors... :-)
assert result.success == true 
assert_equal [
    {
      _id:    1,
      name:   'Billy Bob',
      phone:  '(0555) 123 456',
      tags:   %w(One Two Three),
      active: true                  
    },
    {
      _id:    1,
      name:   'Billy Bob',
      phone:  '(0555) 123 456',
      tags:   %w(One Two Three),
      active: true                  
    }
], result.formalized_objects 
```

Notice that incoming keys that do not match the schema are dropped.

## Installation

Add this line to your application's Gemfile:

    gem 'JFormalize'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install JFormalize

## Testing

    clear; bundle exec rake; bundle exec rubocop

I used `minitest` for testing to reduce any external dependencies.

## Git

[Full details](./GitFlow.md)
[Bash details](./GitBash.md)

### Versioning

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, 
which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

This should only be done on the `master` branch.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ZenGirl/JFormalize. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to 
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JFormalize project’s codebases, issue trackers, chat rooms and mailing lists is 
expected to follow the [code of conduct](https://github.com/[USERNAME]/jsvad/blob/master/CODE_OF_CONDUCT.md).
