require "stable_match"

class Test
## This is a modified version of the example NRMP case
#
  PROGRAMS = {
    'city'    => { :match_positions => 1, :preferences => ['garcia', 'hassan', 'eastman', 'brown', 'chen', 'davis', 'ford']},
    'general' => { :match_positions => 3, :preferences => ['brown', 'eastman', 'hassan', 'anderson', 'chen', 'davis', 'garcia']},
    'mercy'   => { :match_positions => 1, :preferences => ['chen', 'garcia', 'brown']},
    'state'   => { :match_positions => 1, :preferences => ['anderson', 'brown', 'eastman', 'chen', 'hassan', 'ford', 'davis', 'garcia']}
  }

  APPLICANTS = {
    'anderson' => { :match_positions => 1 , :preferences => ['state', 'city'] },
    'brown'    => { :match_positions => 2 , :preferences => ['city', 'mercy', 'state'] },
    'chen'     => { :match_positions => 1 , :preferences => ['city', 'mercy'] },
    'davis'    => { :match_positions => 1 , :preferences => ['mercy', 'city', 'general', 'state'] },
    'eastman'  => { :match_positions => 1 , :preferences => ['city', 'mercy', 'state', 'general'] },
    'ford'     => { :match_positions => 1 , :preferences => ['city', 'general', 'mercy', 'state'] },
    'garcia'   => { :match_positions => 1 , :preferences => ['city', 'mercy', 'state', 'general'] },
    'hassan'   => { :match_positions => 1 , :preferences => ['state', 'city', 'mercy', 'general' ] }
  }

  def self.main
    p StableMatch.run(APPLICANTS, PROGRAMS)
  end
end

Test.main
