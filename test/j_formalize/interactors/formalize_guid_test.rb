require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeGuidTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_guid_string
    raw_objects = [{org_id: '11111111-2222-3333-4444-555555555555 whoops'}]
    schema      = {org_id: {type: :guid}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [org_id] value [11111111-2222-3333-4444-555555555555 whoops] is not a valid guid')
    assert_equal true, result.errors[0].start_with?('key [org_id] value [11111111-2222-3333-4444-555555555555 whoops] is not a valid guid')
  end

  def test_fails_guid_integer
    raw_objects = [{org_id: 1_234_567}]
    schema      = {org_id: {type: :guid}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [org_id] value [1234567] is not a valid guid')
  end

  def test_passes_guid
    raw_objects = [{org_id: '11111111-2222-3333-4444-555555555555', com_id: '66666666-7777-8888-9999-000000000000'}]
    schema      = {org_id: {type: :guid}, com_id: {type: :guid}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:org_id] == '11111111-2222-3333-4444-555555555555'
    assert_equal true, result.formalized_objects[0][:com_id] == '66666666-7777-8888-9999-000000000000'
  end

end
