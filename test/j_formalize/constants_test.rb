require_relative '../test_helper'

require 'minitest/autorun'

class ConstantsTest < Minitest::Test
  def test_invalid_json
    str        = 'This is not valid JSON'
    match_json = str.gsub(/^#{str.scan(/^(?!\n)\s*/).min_by {|l| l.length}}/u, '')
    result     = match_json.match(JFormalize::Constants::JSON_REGEX)
    assert_nil result
  end

  def test_valid_json
    str        = '[{"a":"aaa","b":"bbb"},{"c":"ccc"}]'
    match_json = str.gsub(/^#{str.scan(/^(?!\n)\s*/).min_by {|l| l.length}}/u, '')
    result     = match_json.match(JFormalize::Constants::JSON_REGEX)
    refute_nil result
  end

  def test_method_table
    table = JFormalize::Constants::METHOD_TABLE
    assert_equal :must_be_string, table[:string]
    assert_equal :must_be_guid, table[:guid]
    assert_equal :must_be_integer, table[:integer]
    assert_equal :must_be_url, table[:url]
    assert_equal :must_be_datetime, table[:datetime]
    assert_equal :must_be_boolean, table[:boolean]
    assert_equal :must_be_string, table[:locale]
    assert_equal :must_be_timezone, table[:timezone]
    assert_equal :must_be_email, table[:email]
    assert_equal :must_be_regex, table[:regex]
    assert_equal :must_be_array, table[:array]
  end
end
