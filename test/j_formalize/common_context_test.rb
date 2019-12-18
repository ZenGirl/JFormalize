require_relative '../test_helper'

require 'minitest/autorun'

require_relative '../../lib/j_formalize/interactor/common_context'

class CommonContextTest < Minitest::Test

  # -------------------------------------------------------------------
  class TestClass
    include JFormalize::Interactor

    def call
      context.world = 'hello'
      add_muppet
    end

    def add_muppet
      context.muppet = 'gonzo'
    end
  end

  def test_class_saves_context
    result = TestClass.call(hello: 'world')
    assert_equal 'hello', result.world
    assert_equal 'world', result.hello
    assert_equal 'gonzo', result.muppet
  end

  # -------------------------------------------------------------------
  class FailWithExceptionClass
    include JFormalize::Interactor

    def call
      context.fail!(message: 'whoops')
    end
  end

  def test_fails_hard
    result = assert_raises(JFormalize::Interactor::Failure) do
      FailWithExceptionClass.call!(kermit: 'is a muppet')
    end
    assert_equal 'is a muppet', result.context.kermit
    assert_equal 'whoops', result.context.message
    assert_equal true, result.context.failure?
    assert_equal false, result.context.success?
  end

  # -------------------------------------------------------------------
  class FailWithoutExceptionClass
    include JFormalize::Interactor

    def call
      context.message = 'whoops'
      context.fail(message: 'No exception')
    end
  end

  def test_fails_soft
    result = FailWithoutExceptionClass.call(kermit: 'is a muppet')
    assert_equal true, result.failure?
    assert_equal false, result.success?
  end

  # -------------------------------------------------------------------
  class Interactor1
    include JFormalize::Interactor

    def call
      context.handled ||= []
      context.handled << 'Interactor1'
    end
  end
  class Interactor2
    include JFormalize::Interactor

    def call
      context.handled ||= []
      context.handled << 'Interactor2'
    end
  end
  class TestOrganizer
    include JFormalize::Interactor::Organizer

    organize Interactor1, Interactor2
  end

  def test_organizes
    result = TestOrganizer.call
    ap result
    assert_equal ['Interactor1','Interactor2'], result.handled
  end

end
