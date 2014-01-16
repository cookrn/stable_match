require 'test_helper'

class StableMatch::Util::InitializeWithDefaultsTest < StableMatch::Test
  def test_can_be_included_in_a_class
    assert do
      Class.new do
        include StableMatch::Util::InitializeWithDefaults
      end
    end
  end

  def test_class_with_override_sets_defaults
    klass =
      assert do
        Class.new do
          include StableMatch::Util::InitializeWithDefaults

          attr_accessor :wut

          def initialize_defaults!
            @wut ||= :wut
          end
        end
      end

    assert( 'default is set' ){ :wut == klass.new.wut }
  end

  def test_class_still_respects_initialize
    klass =
      assert do
        Class.new do
          include StableMatch::Util::InitializeWithDefaults

          attr_accessor :wut

          def initialize
            @wut = :initialized
          end

          def initialize_defaults!
            @wut ||= :wut
          end
        end
      end

    assert( 'things get initialized' ){ :initialized == klass.new.wut }
  end
end
