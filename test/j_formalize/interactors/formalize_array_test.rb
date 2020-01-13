require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeArrayTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_integer
    raw_objects = [{tags: 4_732}]
    schema      = {tags: {type: :array, subtype: :string}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [tags] value [4732] is not a valid array')
    assert_equal true, result.errors[0].start_with?('key [tags] value [4732] is not a valid array')
  end

  def test_fails_mixed_subtypes
    raw_objects = [{tags: [1, 'hello', 2, 'there']}]
    schema      = {tags: {type: :array, subtype: :string}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal result.errors, [
      'key [tags] array value [1] is not a string',
      'key [tags] array value [2] is not a string',
      'key [tags] value [[1, "hello", 2, "there"]] is not a valid array - Object: {:tags=>[1, "hello", 2, "there"]}'
    ]
  end

  def test_passes_strings
    raw_objects = [{tags: ['hello', 'there']}]
    schema      = {tags: {type: :array, subtype: :string}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal ['hello', 'there'], result.formalized_objects[0][:tags]
  end

  def test_passes_integers
    raw_objects = [{tags: [1,2,3,4,5]}]
    schema      = {tags: {type: :array, subtype: :integer}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal [1,2,3,4,5], result.formalized_objects[0][:tags]
  end

end
