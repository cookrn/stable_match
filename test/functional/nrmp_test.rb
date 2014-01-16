require 'test_helper'

class NrmpTest < StableMatch::Test
  def test_case
    programs = {
      'mercy'   => [ ['chen', 'garcia'] , 2 ],
      'city'    => [ ['garcia', 'hassan', 'eastman', 'anderson', 'brown', 'chen', 'davis', 'ford'] , 2 ],
      'general' => [ ['brown', 'eastman', 'hassan', 'anderson', 'chen', 'davis', 'garcia'] , 2 ],
      'state'   => [ ['brown', 'eastman', 'anderson', 'chen', 'hassan', 'ford', 'davis', 'garcia'] , 2 ]
    }

    applicants = {
      'anderson' => [ 'city' ],
      'brown'    => [ 'city'  , 'mercy' ],
      'chen'     => [ 'city'  , 'mercy' ],
      'davis'    => [ 'mercy' , 'city'    , 'general' , 'state'   ],
      'eastman'  => [ 'city'  , 'mercy'   , 'state'   , 'general' ],
      'ford'     => [ 'city'  , 'general' , 'mercy'   , 'state'   ],
      'garcia'   => [ 'city'  , 'mercy'   , 'state'   , 'general' ],
      'hassan'   => [ 'state' , 'city'    , 'mercy'   , 'general' ]
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

    runner = StableMatch.run applicants , programs , :asymmetric

    ## applicants
    #
      applicants_expectations.each do | applicant , expected_matches |
        candidate      = runner.candidate_set1[ applicant ]
        actual_matches = candidate.matches.map &:target
        assertion = "#{ applicant } matches #{ actual_matches }"
        assert( assertion ){ expected_matches.sort == actual_matches.sort }
      end

    ## programs
    #
      programs_expectations.each do | program , expected_matches |
        candidate      = runner.candidate_set2[ program ]
        actual_matches = candidate.matches.map &:target
        assertion = "#{ program } matches #{ actual_matches }"
        assert{ expected_matches.sort == actual_matches.sort }
      end
  end
end
