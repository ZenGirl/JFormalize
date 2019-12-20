require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeStringTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_integer
    raw_objects = [{name: 4_732}]
    schema      = {name: {type: :string}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal result.message, 'key [name] value [4732] is not a valid string'
    assert_equal result.errors, ['key [name] value [4732] is not a valid string']
  end

  def test_passes_string
    raw_objects = [{name: 'Gonzo the Great'}]
    schema      = {name: {type: :string}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:name] == 'Gonzo the Great'
  end

  def test_passes_strings
    raw_objects = [{name: 'Gonzo the Great', alias: 'Awesome'}]
    schema      = {name: {type: :string}, alias: {type: :string}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:name] == 'Gonzo the Great'
    assert_equal true, result.formalized_objects[0][:alias] == 'Awesome'
  end

end
