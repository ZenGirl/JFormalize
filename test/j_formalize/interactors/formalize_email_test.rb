require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeEmailTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_integer
    raw_objects = [{email: 4_732}]
    schema      = {email: {type: :email}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [email] value [4732] is not a valid email')
    assert_equal true, result.errors[0].start_with?('key [email] value [4732] is not a valid email')
  end

  def test_passes_string
    raw_objects = [{email: 'gonzo@muppets.com'}]
    schema      = {email: {type: :email}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:email] == 'gonzo@muppets.com'
  end

  def test_passes_strings
    raw_objects = [{email1: 'fozzie@muppets.com', email2: 'goober@bongo.com'}]
    schema      = {email1: {type: :email}, email2: {type: :email}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:email1] == 'fozzie@muppets.com'
    assert_equal true, result.formalized_objects[0][:email2] == 'goober@bongo.com'
  end

end
