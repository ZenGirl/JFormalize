# frozen_string_literal: true

module JFormalize
  module Constants
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

    # This table links data types to the validation method
    # rubocop:disable Layout/AlignHash
    METHOD_TABLE = {
      string:   :must_be_string,
      guid:     :must_be_guid,
      integer:  :must_be_integer,
      url:      :must_be_url,
      datetime: :must_be_datetime,
      boolean:  :must_be_boolean,
      locale:   :must_be_string,
      timezone: :must_be_timezone,
      email:    :must_be_email,
      regex:    :must_be_regex,
      array:    :must_be_array
    }.freeze
    # rubocop:enable Layout/AlignHash

    # rubocop:disable Layout/AlignHash
    MESSAGES = {
      max_size_invalid:            'max_size must be between 100 & 10_000_000',
      json_not_string:             'json_string must be a string',
      json_is_empty:               'json_string must not be empty',
      json_too_long:               'json_string is too large',
      json_not_utf8:               'json_string has non UTF-8 characters',
      json_invalid:                'json_string does not match regex',
      schema_not_hash:             'schema must be a hash',
      schema_value_must_have_type: 'schema values must have type',
      schema_type_must_be_valid:   'schema type must be valid'
    }.freeze
    # rubocop:enable Layout/AlignHash

    GUID_RE = /\A\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b\z/.freeze

    URL_RE = %r{https?://[\S]+}.freeze

    EMAIL_RE = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.freeze
  end
end
