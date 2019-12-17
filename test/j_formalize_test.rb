require 'test_helper'

require_relative '../lib/j_formalize'

class JFormalizeTest < Minitest::Test
  def test_it_has_a_version_number
    refute_nil ::JFormalize::VERSION
  end
end
