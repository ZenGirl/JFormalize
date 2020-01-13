require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeIntegerTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_string
    raw_objects = [{_id: 'not an integer'}]
    schema      = {_id: {type: :integer}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [_id] value [not an integer] is not a valid integer')
    assert_equal true, result.errors[0].start_with?('key [_id] value [not an integer] is not a valid integer')
  end

  def test_passes_integer
    raw_objects = [{_id: 4_732}]
    schema      = {_id: {type: :integer}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:_id] == 4732
  end

  def test_passes_integers
    raw_objects = [{_id: 4_732, size: 42}]
    schema      = {_id: {type: :integer}, size: {type: :integer}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:_id] == 4732
    assert_equal true, result.formalized_objects[0][:size] == 42
  end

end
