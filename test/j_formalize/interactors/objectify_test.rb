require_relative '../../test_helper'

require 'minitest/autorun'

require_relative '../../../lib/j_formalize/constants'
require_relative '../../../lib/j_formalize/interactors/common_context'
require_relative '../../../lib/j_formalize/interactors/objectify'

class ObjectifyTest < Minitest::Test

  def setup
    @subject = JFormalize::Interactors::Objectify
  end

  def err(key)
    JFormalize::Constants::MESSAGES[key]
  end

  def test_fails
    json_h      = [
      {
        _id:  1,
        name: 'Gonzo'
      }
    ]
    json_string = JSON.generate(json_h) + 'Not Valid JSON'
    max_size    = 100_000
    schema      = {
      _id:  {type: :integer},
      name: {type: :string}
    }
    ctx         = {
      json_string: json_string,
      max_size:    max_size,
      schema:      schema
    }
    result      = @subject.call(ctx)
    assert_equal true, result.failure?
    assert_equal true, result.message.start_with?('JSONError:')
  end

  def test_passes
    json_h      = [
      {
        :_id             => 1,
        :url             => 'http://over.the.rainbow.com/api/v2/users/1.json',
        :external_id     => '74341f74-9c79-49d5-9611-87ef9b6eb75f',
        :name            => 'Gonzo the Great',
        :alias           => 'Hunter',
        :created_at      => '2019-04-15T05:19:46 -10:00',
        :active          => true,
        :verified        => true,
        :shared          => false,
        :locale          => 'en-AU',
        :timezone        => 'Some Place',
        :last_login_at   => '2019-08-04T01:03:27 -10:00',
        :email           => 'gonzo@over.the.rainbow.com',
        :phone           => '8335-422-718',
        :signature       => 'Don\'t Worry Be Happy!',
        :organization_id => 119,
        :tags            => %w(Springville Sutton Hartsville/Hartley Diaperville),
        :suspended       => true,
        :role            => 'admin'
      }
    ]
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
  end

end
