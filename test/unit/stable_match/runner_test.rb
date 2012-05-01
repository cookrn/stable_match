require "test_helper"

class StableMatch::RunnerTest < MiniTest::Unit::TestCase
  def setup
    @set1 = { 1 => { :preferences => [ 2 ] } }
    @set2 = { 2 => { :preferences => [ 1 ] } }
  end

## Runner::run
#
  def test_has_a_factory_class_method_that_automatically_runs_match
    runner = assert{ StableMatch::Runner.run @set1 , @set2 }
    assert{ runner.checked? }
    assert{ runner.built? }
  end

## Runner#initialize
#
  def test_accepts_args_as_named_options_or_positionally
    assert{ StableMatch::Runner.new( @set1 , @set2 ) }
    assert{ StableMatch::Runner.new( :set1 => @set1 , :set2 => @set2 ) }

    runner = assert{ StableMatch::Runner.new( @set1 , :set2 => @set2 ) }
    assert{ runner.set1 == @set1 }

    runner = assert{ StableMatch::Runner.new( @set2 , :set1 => @set1 ) }
    assert{ runner.set2 == @set2 }
  end

## Runner#build!
#
  def test_build_creates_candidate_sets_from_each_raw_set
    runner = build_runner
    assert{ runner.build! }

    assert{ !runner.candidate_set1.empty? }
    assert{ runner.candidate_set1[ @set1.keys.first ] }

    assert{ !runner.candidate_set2.empty? }
    assert{ runner.candidate_set2[ @set2.keys.first ] }
  end

  def test_build_adds_to_list_of_candidates
    runner = build_runner
    assert{ runner.candidates.empty? }
    assert{ runner.build! }
    assert{ !runner.candidates.empty? }
  end

  def test_build_replaces_candidates_preferences_with_candidates
    runner = build_runner.tap { | r | r.build! }
    assert{ runner.candidate_set1.values.first.preferences.all? { | c | c.is_a? StableMatch::Candidate } }
  end

  def test_build_marks_runner_as_built
    runner = build_runner
    assert{ runner.build! }
    assert{ runner.built }
    assert{ runner.built? }
  end

## Runner#check!
#
  def test_checks_that_sets_meet_criteria
    runner = build_runner
    assert{ runner.check! }
    assert{ runner.checked }
    assert{ runner.checked? }
  end

  def test_checks_that_a_sets_preferences_are_included_in_other_set
    set1 = { 1 => { :preferences => [ 2 ] } }
    set2 = { 2 => { :preferences => [ 1 , 3 ] } }
    runner = StableMatch::Runner.new set1 , set2

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

## Runner#remaining_candidates
#
  def test_remaining_candidates_rejects_candidates_that_have_filled_match_positions
    runner = build_prepared_runner
    original_size = runner.remaining_candidates.size
    runner.candidates.first.tap { | c | c.propose_to_next_preference }
    assert{ original_size > runner.remaining_candidates.size }
  end

  def test_remaining_candidates_rejects_candidates_that_have_made_all_possible_proposals
    runner = build_prepared_runner
    original_size = runner.remaining_candidates.size
    runner.candidates.first.tap { | c | c.preference_position = c.preferences.size - 1 }
    assert{ original_size > runner.remaining_candidates.size }
  end

## Runner#run
#
  def test_has_a_run_loop
    assert{ build_runner.respond_to? :run }
  end

private

  def build_runner
    assert{ StableMatch::Runner.new( @set1 , @set2 ) }
  end

  def build_prepared_runner
    runner = build_runner
    assert{ runner.check! }
    assert{ runner.build! }
    runner
  end
end
