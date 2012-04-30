require "test_helper"

class StableMatch::RunnerTest < MiniTest::Unit::TestCase
  def test_has_a_factory_class_method_that_automatically_runs_match
    assert{ StableMatch::Runner.respond_to? :run }
  end

  def test_accepts_args_as_named_options_or_positionally
    set1 = { 1 => { 2 => 30 } }
    set2 = { 2 => { 1 => 40 } }

    assert{ StableMatch::Runner.new( set2 , set2 ) }
    assert{ StableMatch::Runner.new( :set1 => set1 , :set2 => set2 ) }

    runner = assert{ StableMatch::Runner.new( set1 , :set2 => set2 ) }
    assert{ runner.set1 == set1 }

    runner = assert{ StableMatch::Runner.new( set2 , :set1 => set1 ) }
    assert{ runner.set2 == set2 }
  end

  def test_optionally_sets_a_custom_threshold
    set1 = { 1 => { 2 => 30 } }
    set2 = { 2 => { 1 => 40 } }
    runner = assert{ StableMatch::Runner.new( set1 , set2 , :threshold => 2 ) }
    assert{ runner.threshold == 2 }
  end

  def test_checks_that_sets_meet_criteria
    set1 = { 1 => { 2 => 30 } }
    set2 = { 2 => { 1 => 40 } }
    runner = StableMatch::Runner.new( set1 , set2 )
    assert{ runner.check! }
  end

  def test_checks_that_a_sets_preferences_match_size_of_other_set
    set1 = { 1 => { 2 => 30 , 3 => 80 } }
    set2 = { 2 => { 1 => 40 } }
    runner = StableMatch::Runner.new( set1 , set2 )
    assert "set1 contains 2 preferences while there is only one member of set2" do
      raised = false
      begin
        runner.check!
      rescue Object => e
        raised = e.is_a? ArgumentError
      end
      raised
    end
  end

  def test_checks_that_a_sets_preferences_are_included_in_other_set
    set1 = { 1 => { 2 => 30 } }
    set2 = { 2 => { 3 => 40 } }
    runner = StableMatch::Runner.new( set1 , set2 )
    assert "set2 contains a preference for 3 that does not exist" do
      raised = false
      begin
        runner.check!
      rescue Object => e
        raised = e.is_a? ArgumentError
      end
      raised
    end
  end

  def test_it_knows_when_it_has_been_checked
    set1 = { 1 => { 2 => 30 } }
    set2 = { 2 => { 1 => 40 } }
    runner = StableMatch::Runner.new( set1 , set2 )
    runner.check!
    assert{ runner.checked }
    assert{ runner.checked? }
  end
end
