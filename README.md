# JFormalize

Loads, parses and validates a JSON file into formalized ruby objects according to a schema.

According to the dictionary, to formalize is to:

1. To make agree with a single established standard or model
2. To give official acceptance of as satisfactory
3. To make solemn, or official, through ceremony or legal act
4. To represent in a particular style

While it is humorous to think of JSON involving solemnity, officialness or legality, 
it certainly involves ceremony.

This gem provides a simple way to validate a file, load it as JSON, parse it and formalize objects
according to a provided schema into ruby objects.

This involves a process like this:

- PreLoad
- Load
- Objectify
- Formalize

## `PreLoad`

This involves verifying that a provided file pass the following tests:

1. It must exist
2. It must be a file (e.g. not a directory)
3. It must be readable
4. It must not be too big

The first 3 are self explanatory.
Number 4 requires some explanation.

A file has a size and the gem tests that this size does not exceed a limit.
The allowed maximum size either defaults to 1,000,000 characters or a value provided to the pre-loader.

After the file has been verified, the provided schema has to be checked.
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

- `string` - must be a ruby string - can have `allowed` key-value array
- `guid` - must match `/\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b/`
- `integer` - must be a ruby integer
- `url` - simply match `%r{https?://[\S]+}`
- `datetime` - succeeds a `Time.parse`
- `boolean` - true or false
- `locale` - at this point, simply a string
- `timezone` - at this point, simply a string
- `email` - must match `/\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i`
- `regex` - must match the provided `match` key-value
- `array` - must be a ruby array - can have sub-type validation


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

### Git

My `git` process is as follows:

There is a `master` branch. 
From that a `develop` branch is created.
For each "feature" a new numbered branch is created:

```bash
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

```bash
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

### Versioning

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
