require 'test_helper'

class StableMatchTest < StableMatch::Test
  def test_has_a_shortcut_method_create_and_run_a_runner
    assert{ StableMatch.respond_to? :run }
  end
end
