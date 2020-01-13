require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeTimezoneTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_integer
    raw_objects = [{timezone: 4_732}]
    schema      = {timezone: {type: :timezone}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [timezone] value [4732] is not a valid timezone')
    assert_equal true, result.errors[0].start_with?('key [timezone] value [4732] is not a valid timezone')
  end

  def test_passes_string
    raw_objects = [{timezone: 'AEST'}]
    schema      = {timezone: {type: :timezone}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:timezone] == 'AEST'
  end

  def test_passes_strings
    raw_objects = [{timezone1: 'AEST', timezone2: 'GMT'}]
    schema      = {timezone1: {type: :timezone}, timezone2: {type: :timezone}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:timezone1] == 'AEST'
    assert_equal true, result.formalized_objects[0][:timezone2] == 'GMT'
  end

end
