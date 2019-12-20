require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeDatetimeTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize
  end

  def test_fails_string
    raw_objects = [{created_at: 'not an datetime'}]
    schema      = {created_at: {type: :datetime}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.failure?
    assert_equal result.message, 'key [created_at] value [not an datetime] is not a valid datetime'
    assert_equal result.errors, ['key [created_at] value [not an datetime] is not a valid datetime']
  end

  def test_passes_datetime
    raw_objects = [{created_at: '2019-12-20T10:25:00 -10:00'}]
    schema      = {created_at: {type: :datetime}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:created_at] == '2019-12-20T10:25:00 -10:00'
  end

  def test_passes_datetimes
    raw_objects = [{created_at: '2019-12-20T10:25:00 -10:00', login_at: '1970-01-01T10:00:00 -10:00'}]
    schema      = {created_at: {type: :datetime}, login_at: {type: :datetime}}
    result      = @subject.call({raw_objects: raw_objects, schema: schema})
    assert_equal true, result.success?
    assert_equal true, result.formalized_objects[0][:created_at] == '2019-12-20T10:25:00 -10:00'
    assert_equal true, result.formalized_objects[0][:login_at] == '1970-01-01T10:00:00 -10:00'
  end

end
