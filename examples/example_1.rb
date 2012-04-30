require "stable_match"

class Test
  PROGRAMS = {
    'city'    => {:positions => 1, :preferences => ['garcia', 'hassan', 'eastman', 'brown', 'chen', 'davis', 'ford']},
    'general' => {:positions => 1, :preferences => ['brown', 'eastman', 'hassan', 'anderson', 'chen', 'davis', 'garcia']},
    'mercy'   => {:positions => 1, :preferences => ['chen', 'garcia', 'brown']},
    'state'   => {:positions => 1, :preferences => ['anderson', 'brown', 'eastman', 'chen', 'hassan', 'ford', 'davis', 'garcia']}
  }

  APPLICANTS = {
    'anderson' => { :positions => 1 , :preferences => ['state', 'city'] },
    'brown'    => { :positions => 1 , :preferences => ['city', 'mercy', 'state'] },
    'chen'     => { :positions => 1 , :preferences => ['city', 'mercy'] },
    'davis'    => { :positions => 1 , :preferences => ['mercy', 'city', 'general', 'state'] },
    'eastman'  => { :positions => 1 , :preferences => ['city', 'mercy', 'state', 'general'] },
    'ford'     => { :positions => 1 , :preferences => ['city', 'general', 'mercy', 'state'] },
    'garcia'   => { :positions => 1 , :preferences => ['city', 'mercy', 'state', 'general'] },
    'hassan'   => { :positions => 1 , :preferences => ['state', 'city', 'mercy', 'general' ] }
  }

  def self.main
    matcher = StableMatch.run(APPLICANTS, PROGRAMS)
    puts matcher.results_description
  end
end

Test.main
