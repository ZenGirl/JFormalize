require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeRegexTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
    @regex1  = /\A\d\d\d-\d\d\d\d-\d\d\d\d\Z/
    @regex2  = /\A\d\d\d\d-\d\d\d-\d\d\d\Z/
  end

  def test_fails_integer
    raw_objects = [{phone: 4_732}]
    schema      = {phone: {type: :regex, match: @regex1}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal result.message, 'key [phone] value [4732] is not a valid regex'
    assert_equal result.errors, ['key [phone] value [4732] is not a valid regex']
  end

  def test_passes_string
    raw_objects = [{phone: '555-1234-5678'}]
    schema      = {phone: {type: :regex, match: @regex1}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:phone] == '555-1234-5678'
  end

  def test_passes_strings
    raw_objects = [{phone1: '555-1234-5678', phone2: '0555-123-456'}]
    schema      = {phone1: {type: :regex, match: @regex1}, phone2: {type: :regex, match: @regex2}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:phone1] == '555-1234-5678'
    assert_equal true, result.formalized_objects[0][:phone2] == '0555-123-456'
  end

end
