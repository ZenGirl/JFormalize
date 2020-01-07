require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/formalize'

class FormalizeTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Formalize.new
  end

  def err(key)
    JFormalize::Constants::MESSAGES[key]
  end

  # -------------------------------------------------------------------------
  # String
  # -------------------------------------------------------------------------
  def test_subtype_case_string_fails
    @subject.send(:subtype_case, 'Dummy error', :string, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_string_succeeds
    @subject.send(:subtype_case, 'Dummy error', :string, 'hello')
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # GUID
  # -------------------------------------------------------------------------
  def test_subtype_case_guid_fails
    @subject.send(:subtype_case, 'Dummy error', :guid, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_guid_succeeds
    @subject.send(:subtype_case, 'Dummy error', :guid, '11111111-2222-3333-4444-555555555555')
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # Integer
  # -------------------------------------------------------------------------
  def test_subtype_case_integer_fails
    @subject.send(:subtype_case, 'Dummy error', :integer, 'Goober')
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_integer_succeeds
    @subject.send(:subtype_case, 'Dummy error', :integer, 4_732)
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # URL
  # -------------------------------------------------------------------------
  def test_subtype_case_url_fails1
    @subject.send(:subtype_case, 'Dummy error', :url, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_url_fails2
    @subject.send(:subtype_case, 'Dummy error', :url, 'not an url')
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_url_succeeds
    @subject.send(:subtype_case, 'Dummy error', :url, 'http://gonzo.com')
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # Datetime
  # -------------------------------------------------------------------------
  def test_subtype_case_datetime_fails1
    @subject.send(:subtype_case, 'Dummy error', :datetime, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_datetime_fails2
    @subject.send(:subtype_case, 'Dummy error', :datetime, 'not an datetime')
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_datetime_succeeds
    @subject.send(:subtype_case, 'Dummy error', :datetime, '2019-12-20T10:25:00 -10:00')
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # Boolean
  # -------------------------------------------------------------------------
  def test_subtype_case_boolean_fails1
    @subject.send(:subtype_case, 'Dummy error', :boolean, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_boolean_fails2
    @subject.send(:subtype_case, 'Dummy error', :boolean, 'not a boolean')
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_boolean_succeeds
    @subject.send(:subtype_case, 'Dummy error', :boolean, true)
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # Locale
  # -------------------------------------------------------------------------
  def test_subtype_case_locale_fails1
    @subject.send(:subtype_case, 'Dummy error', :locale, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_locale_fails2
    @subject.send(:subtype_case, 'Dummy error', :locale, nil)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_locale_succeeds
    @subject.send(:subtype_case, 'Dummy error', :locale, 'AEST')
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # Timezone
  # -------------------------------------------------------------------------
  def test_subtype_case_timezone_fails1
    @subject.send(:subtype_case, 'Dummy error', :timezone, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_timezone_fails2
    @subject.send(:subtype_case, 'Dummy error', :timezone, nil)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_timezone_succeeds
    @subject.send(:subtype_case, 'Dummy error', :timezone, 'AEST')
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # Email
  # -------------------------------------------------------------------------
  def test_subtype_case_email_fails1
    @subject.send(:subtype_case, 'Dummy error', :email, 1)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_email_fails2
    @subject.send(:subtype_case, 'Dummy error', :email, nil)
    assert_includes @subject.context.errors, 'Dummy error'
  end

  def test_subtype_case_email_succeeds
    @subject.send(:subtype_case, 'Dummy error', :email, 'bob@bill.com')
    assert_equal @subject.context.errors, []
  end

  # -------------------------------------------------------------------------
  # None of the above
  # -------------------------------------------------------------------------
  def test_subtype_case_none
    @subject.send(:subtype_case, 'Dummy error', :none_of_the_above, 1)
    assert_equal @subject.context.errors, ['subtype [none_of_the_above] is not supported']
  end

end
