require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeBooleanTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_string
    raw_objects = [{active: 'not a boolean'}]
    schema      = {active: {type: :boolean}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [active] value [not a boolean] is not a valid boolean')
    assert_equal true, result.errors[0].start_with?('key [active] value [not a boolean] is not a valid boolean')
  end

  def test_passes_boolean
    raw_objects = [{active: true}]
    schema      = {active: {type: :boolean}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:active] == true
  end

  def test_passes_datetimes
    raw_objects = [{active: true, is_admin: false}]
    schema      = {active: {type: :boolean}, is_admin: {type: :boolean}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:active] == true
    assert_equal true, result.formalized_objects[0][:is_admin] == false
  end

end
