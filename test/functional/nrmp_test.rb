require "test_helper"

class NationalResidentMatchingProgramFunctionalTest < MiniTest::Unit::TestCase
  def test_case
    programs = {
      'mercy'   => { :match_positions => 2, :preferences => ['chen', 'garcia']},
      'city'    => { :match_positions => 2, :preferences => ['garcia', 'hassan', 'eastman', 'anderson', 'brown', 'chen', 'davis', 'ford']},
      'general' => { :match_positions => 2, :preferences => ['brown', 'eastman', 'hassan', 'anderson', 'chen', 'davis', 'garcia']},
      'state'   => { :match_positions => 2, :preferences => ['brown', 'eastman', 'anderson', 'chen', 'hassan', 'ford', 'davis', 'garcia']}
    }

    applicants = {
      'anderson' => { :match_positions => 1 , :preferences => ['city'] },
      'brown'    => { :match_positions => 1 , :preferences => ['city', 'mercy'] },
      'chen'     => { :match_positions => 1 , :preferences => ['city', 'mercy'] },
      'davis'    => { :match_positions => 1 , :preferences => ['mercy', 'city', 'general', 'state'] },
      'eastman'  => { :match_positions => 1 , :preferences => ['city', 'mercy', 'state', 'general'] },
      'ford'     => { :match_positions => 1 , :preferences => ['city', 'general', 'mercy', 'state'] },
      'garcia'   => { :match_positions => 1 , :preferences => ['city', 'mercy', 'state', 'general'] },
      'hassan'   => { :match_positions => 1 , :preferences => ['state', 'city', 'mercy', 'general' ] }
    }

    programs_expectations = {
      'mercy'   => [ 'chen' ],
      'city'    => [ 'garcia' , 'eastman' ],
      'general' => [ 'davis' ],
      'state'   => [ 'ford' , 'hassan' ]
    }

    applicants_expectations = {
      'anderson' => [],
      'brown'    => [],
      'chen'     => [ 'mercy' ],
      'davis'    => [ 'general' ],
      'eastman'  => [ 'city' ],
      'ford'     => [ 'state' ],
      'garcia'   => [ 'city' ],
      'hassan'   => [ 'state' ]
    }

    runner = StableMatch.run applicants , programs , :strategy => :asymmetric

    ## applicants
    #
      applicants_expectations.each do | applicant , expected_matches |
        candidate      = runner.candidate_set1[ applicant ]
        actual_matches = candidate.matches.map &:target
        assert{ expected_matches.sort == actual_matches.sort }
      end

    ## programs
    #
      programs_expectations.each do | program , expected_matches |
        candidate      = runner.candidate_set2[ program ]
        actual_matches = candidate.matches.map &:target
        assert{ expected_matches.sort == actual_matches.sort }
      end
  end
end
