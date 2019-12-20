require 'test_helper'

require_relative '../lib/j_formalize'

class JFormalizeTest < Minitest::Test
  def test_it_has_a_version_number
    refute_nil ::JFormalize::VERSION
  end

  def setup
    @subject = JFormalize::Engine
  end

  def test_1
    json_h = [
      {
        _id:             1,
        url:             'http://initech.zendesk.com/api/v2/users/1.json',
        external_id:     '74341f74-9c79-49d5-9611-87ef9b6eb75f',
        name:            'Francisca Rasmussen',
        alias:           'Miss Coffey',
        created_at:      '2016-04-15T05:19:46 -10:00',
        active:          true,
        verified:        true,
        shared:          false,
        locale:          'en-AU',
        timezone:        'Sri Lanka',
        last_login_at:   '2013-08-04T01:03:27 -10:00',
        email:           'coffeyrasmussen@flotonic.com',
        phone:           '8335-422-718',
        signature:       'Don\'t Worry Be Happy!',
        organization_id: 119,
        tags:            %w(Springville Sutton Hartsville/Hartley Diaperville),
        'suspended':     true,
        'role':          'admin'
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

    result = @subject.call(ctx)
    # ap result
    assert_equal true, result.success?
    assert_equal [], result.errors
    assert_equal [
                   {
                     _id:             1,
                     url:             'http://initech.zendesk.com/api/v2/users/1.json',
                     external_id:     '74341f74-9c79-49d5-9611-87ef9b6eb75f',
                     name:            'Francisca Rasmussen',
                     alias:           'Miss Coffey',
                     created_at:      '2016-04-15T05:19:46 -10:00',
                     active:          true,
                     verified:        true,
                     shared:          false,
                     locale:          'en-AU',
                     timezone:        'Sri Lanka',
                     last_login_at:   '2013-08-04T01:03:27 -10:00',
                     email:           'coffeyrasmussen@flotonic.com',
                     phone:           '8335-422-718',
                     signature:       'Don\'t Worry Be Happy!',
                     organization_id: 119,
                     tags:            %w(Springville Sutton Hartsville/Hartley Diaperville),
                     'suspended':     true,
                     'role':          'admin'
                   }
                 ], result.formalized_objects
  end

end
