require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/pre_load'

class PreLoadTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::PreLoad
  end

  def err(key)
    JFormalize::Constants::MESSAGES[key]
  end

  # -------------------------------------------------------------------
  # Max Size
  # -------------------------------------------------------------------

  def test_max_size_nil
    json_string = JSON.generate({a: 1, b: 2})
    ctx         = {json_string: json_string, max_size: nil, schema: {_id: {type: :string}}}
    result      = @subject.call(ctx)
    assert_equal 100_000, result.max_size
  end

  def test_max_size_zero
    json_string = JSON.generate({a: 1, b: 2})
    ctx         = {json_string: json_string, max_size: 0, schema: {_id: {type: :string}}}
    result      = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:max_size_invalid), result.message
  end

  def test_max_size_huge
    json_string = JSON.generate({a: 1, b: 2})
    ctx         = {json_string: json_string, max_size: 100_000_000, schema: {_id: {type: :string}}}
    result      = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:max_size_invalid), result.message
  end

  # -------------------------------------------------------------------
  # JSON string
  # -------------------------------------------------------------------

  def test_string_not_string
    ctx    = {json_string: 100, max_size: 100_000, schema: {_id: {type: :string}}}
    result = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:json_not_string), result.message
  end

  def test_string_empty
    ctx    = {json_string: '', max_size: 100_000, schema: {_id: {type: :string}}}
    result = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:json_is_empty), result.message
  end

  def test_string_empty_newlines
    ctx    = {json_string: "\n\n\n  \n\n\n", max_size: 100_000, schema: {_id: {type: :string}}}
    result = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:json_is_empty), result.message
  end

  def test_string_too_large
    json_h      = {
      a_long_key: 'a' * 100,
      b_long_key: 'b' * 100
    }
    json_string = JSON.generate(json_h)
    ctx         = {json_string: json_string, max_size: 100, schema: {_id: {type: :string}}}
    result      = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:json_too_long), result.message
  end

  def test_string_not_utf8
    json_h      = {a: 'hellÔ!'}
    json_string = JSON.generate(json_h)
    ctx         = {json_string: json_string.encode('ISO-8859-1'), max_size: 100, schema: {_id: {type: :string}}}
    result      = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:json_not_utf8), result.message
  end

  def test_string_not_valid
    ctx    = {json_string: 'This. Is. Not. JSON.', max_size: 100, schema: {_id: {type: :string}}}
    result = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:json_invalid), result.message
  end

  # -------------------------------------------------------------------
  # Schema
  # -------------------------------------------------------------------

  def test_schema_hash
    ctx    = {json_string: '[]', max_size: 100, schema: 'Not. Hash.'}
    result = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:schema_not_hash), result.message
  end

  def test_schema_no_type
    ctx    = {json_string: '[]', max_size: 100, schema: {gonzo: {}}}
    result = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:schema_value_must_have_type), result.message
  end

  def test_schema_valid_type
    ctx    = {json_string: '[]', max_size: 100, schema: {gonzo: {type: :not_valid_type}}}
    result = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal err(:schema_type_must_be_valid), result.message
  end

  # -------------------------------------------------------------------
  # Passes
  # -------------------------------------------------------------------

  def test_passes
    json_h      = {
      _id: 1
    }
    json_string = JSON.generate(json_h)
    max_size    = 100_000
    schema      = {
      _id:             {type: :integer},
      url:             {type: :url},
      external_id:     {type: :guid},
      name:            {type: :string},
      alias:           {type: :string},
      created_at:      {type: :datetime},
      active:          {type: :boolean},
      verified:        {type: :boolean},
      shared:          {type: :boolean},
      locale:          {type: :locale},
      timezone:        {type: :timezone},
      last_login_at:   {type: :datetime},
      email:           {type: :email},
      phone:           {type: :regex, match: /\d\d\d\d-\d\d\d-\d\d\d/},
      signature:       {type: :string},
      organization_id: {type: :integer},
      tags:            {type: :array, subtype: :string},
      suspended:       {type: :boolean},
      role:            {type: :string, allowed: %w[admin agent end_user]}
    }
    ctx         = {
      json_string: json_string,
      max_size:    max_size,
      schema:      schema
    }
    result      = @subject.call(ctx)
    assert_equal true, result.success?
    assert_equal json_string, result.json_string
    assert_equal max_size, result.max_size
    assert_equal schema, result.schema
  end

end
