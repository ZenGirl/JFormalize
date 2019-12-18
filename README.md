# JFormalize

## Back story

This gem was created based on several in-application gems created over the years.

The requirement to have a simple parser, validator, defaulter and formalizer for incoming JSON has recurred repeatedly for me over the years.
This gem is simply a wrap up of those requirements.

## Details

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

This involves a process like this:

- PreLoad
- Objectify
- Formalize

Each of these sub-processes are isolated, but use a shared context provided by an umbrella class.
This is similar to the `Interactor` gem [which I love].

## `PreLoad`

This involves verifying that a provided string pass the following tests:

1. It must be a string
2. It must match a simple JSON regex
3. It must not be too big
4. It must not be empty
5. It must not contain non UTF-8 characters

The first is self explanatory.

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

The `rubocop` notations are simply to avoid unnecessary messages.

The "must not be too big" requirement requires some explanation.

The code tests that the string size does not exceed a limit.
The allowed maximum size either defaults to 1,000,000 characters or a value provided to the pre-loader.

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

An incoming string may look like this:

```ruby
[{"_id":1,"url":"http://somewhere.over.the.rainbow.com/api/v2/users/1.json","external_id":"74341f74-9c79-49d5-9611-87ef9b6eb75f","name":"Edmund Glenn","alias":"Eddie","created_at":"2019-04-15T05:19:46 -10:00","active":true,"verified":true,"shared":false,"locale":"en-AU","timezone":"AEST","last_login_at":"2019-08-04T01:03:27 -10:00","email":"edmund.glenn@bianka.com","phone":"8335-422-718","signature":"Don't Worry Be Happy!","organization_id":119,"tags":["Brunsville","Juneeburg","Pricegan Beach","Mutgulbal"],"suspended":true,"role":"admin"}]
```

And, for clarity, this corresponds to the following hash:

```ruby
[
  {
    _id:             1,
    url:             'http://somewhere.over.the.rainbow.com/api/v2/users/1.json',
    external_id:     '74341f74-9c79-49d5-9611-87ef9b6eb75f',
    name:            'Edmund Glenn',
    alias:           'Eddie',
    created_at:      '2019-04-15T05:19:46 -10:00',
    active:          true,
    verified:        true,
    shared:          false,
    locale:          'en-AU',
    timezone:        'AEST',
    last_login_at:   '2019-08-04T01:03:27 -10:00',
    email:           'edmund.glenn@bianka.com',
    phone:           '8335-422-718',
    signature:       'Don\'t Worry Be Happy!',
    organization_id: 119,
    tags:            %w(Brunsville Juneeburg Pricegan\ Beach Mutgulbal),
    suspended:       true,
    role:            'admin'
  }
]
```

During the `PreLoad` phase, exceptions may be raised.
All exceptions are in `JFormalise::Exceptions` and mostly wrap existing exceptions.
The purpose of having separate exceptions is to provide fine grained control if required.

The exceptions are shown below:

| Exception | Meaning |
| --------- | ------- |
| InputIsEmpty | The incoming string is empty |
| InputHasNonUtf8Chars | The incoming string has non UTF-8 characters |
| InputNotJson | The incoming string does not match the JSON regex |
| InputTooBig | The incoming string size exceeds the maximum size |
| SchemaNotJson | The incoming schema does not match the JSON regex |
| SchemaNotHash | The incoming schema is not a hash |
| SchemaHashKeyInvalid | In the schema hash, a key pair does not match the allowed values |







## `Objectify`

The purpose of this is simply to isolate the parsing of the incoming string.

Any `JSONError` exceptions are wrapped in a `JFormalize::Exceptions::JSONError` with a formatted backtrace.

The output of this is an internal set of raw objects from the incoming string.






## `Formalize`

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


## Usage

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
obj = JFormalize::Engine.new(json_string, max_size, schema)
obj.suppress_exceptions # Simply holds exceptions in an array - see example below
obj.run

# Assuming no exceptions... :-)
assert obj.success == true 
puts obj.objects 
> [
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
]

# Exceptions example:
assert obj.success == false
puts obj.errors
> [
  'InputIsEmpty:          Incoming string is empty',
  'InputHasNonUtf8Chars:  Incoming string has non UTF-8 characters [hellÔ!]',
  'InputNotJson:          Incoming string does not match the JSON regex',
  'InputTooBig:           Incoming string size exceeds the maximum size [100_000]',
  'SchemaNotJson:         Incoming schema does not match the JSON regex',
  'SchemaNotHash:         Incoming schema is not a hash',
  'SchemaHashKeyInvalid:  Incoming schema hash has a key [org_id] pair does not match the allowed values [must_be_guid]'
] 
```

## Installation

Add this line to your application's Gemfile:

    gem 'JFormalize'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install JFormalize

## Testing

    clear; bundle exec rake; bundle exec rubocop

## Git

My `git` process is as follows:

There is a `master` branch. 
From that a `develop` branch is created.
For each "feature" a new numbered branch is created:

```
kim@tinka ~/RubymineProjects/JFormalize (develop)$ git checkout -b features/001_ExtendReadme
Switched to a new branch 'features/001_ExtendReadme'
kim@tinka ~/RubymineProjects/JFormalize (features/001_ExtendReadme)$
```

The name and machine is irrelevant, but the current branch is shown in brackets.
Note that the numbering is somewhat arbitrary and once main line development is completed, it would switch to issue numbers.

> The *bash* scripts to provide this functionality is added to the base of this doc.

Once a feature branch is created, changes are made to the code base.
Once these reach a reasonable point, a commit is made:

```bash
git commit -a -m 'Extended Readme'
```

And a push occurs:

```
kim@tinka ~/RubymineProjects/JFormalize (features/001_ExtendReadme)$ git push
fatal: The current branch features/001_ExtendReadme has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin features/001_ExtendReadme

kim@tinka ~/RubymineProjects/JFormalize (features/001_ExtendReadme)$ git push --set-upstream origin features/001_ExtendReadme
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 749 bytes | 749.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
remote:
remote: Create a pull request for 'features/001_ExtendReadme' on GitHub by visiting:
remote:      https://github.com/ZenGirl/JFormalize/pull/new/features/001_ExtendReadme
remote:
To github.com:ZenGirl/JFormalize.git
 * [new branch]      features/001_ExtendReadme -> features/001_ExtendReadme
Branch 'features/001_ExtendReadme' set up to track remote branch 'features/001_ExtendReadme' from 'origin'.
```

The first notice only shows once if no upstream branch exists. 
Once done, only a `git push` is required.

After the branch is complete and accepted, it can be merged back into `develop`:

```bash
git checkout develop
git merge features/001_ExtendReadme
git push
```

Once a set of features are complete, `develop` can be merged into `master`, the version updated and pushed.
That done, the gem can be released.

An example process for an example set of features is shown below:

```
git checkout develop

# Some feature:
git checkout -b features/123_SomeFeature
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git push
git checkout develop
git merge features/123_Feature123
git push

# Another feature:
git checkout -b features/124_AnotherFeature
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git commit -a -m 'Meaningful message'
git push
git checkout develop
git merge features/124_AnotherFeature
git push

# Release
git checkout master
git merge develop
[update version.rb]
git commit -a -m 'Update to N.N.N'
git push
```

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
