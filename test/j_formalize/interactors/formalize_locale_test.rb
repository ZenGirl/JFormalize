require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeLocaleTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_integer
    raw_objects = [{locale: 4_732}]
    schema      = {locale: {type: :locale}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('key [locale] value [4732] is not a valid locale')
    assert_equal true, result.errors[0].start_with?('key [locale] value [4732] is not a valid locale')
  end

  def test_passes_string
    raw_objects = [{locale: 'en-AU'}]
    schema      = {locale: {type: :locale}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:locale] == 'en-AU'
  end

  def test_passes_strings
    raw_objects = [{locale1: 'en-AU', locale2: 'en-US'}]
    schema      = {locale1: {type: :locale}, locale2: {type: :locale}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:locale1] == 'en-AU'
    assert_equal true, result.formalized_objects[0][:locale2] == 'en-US'
  end

end
