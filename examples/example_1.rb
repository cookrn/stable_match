require "stable_match"

class Test
## This is a modified version of the example NRMP case
#
  PROGRAMS = {
    'city'    => ['garcia', 'hassan', 'eastman', 'brown', 'chen', 'davis', 'ford'],
    'general' => [ ['brown', 'eastman', 'hassan', 'anderson', 'chen', 'davis', 'garcia'] , 3 ],
    'mercy'   => [ ['chen', 'garcia', 'brown'] , 2 ],
    'state'   => ['anderson', 'brown', 'eastman', 'chen', 'hassan', 'ford', 'davis', 'garcia']
  }

  APPLICANTS = {
    'anderson' => ['state', 'city'],
    'brown'    => ['city', 'mercy', 'state'],
    'chen'     => ['city', 'mercy'],
    'davis'    => ['mercy', 'city', 'general', 'state'],
    'eastman'  => ['city', 'mercy', 'state', 'general'],
    'ford'     => ['city', 'general', 'mercy', 'state'],
    'garcia'   => ['city', 'mercy', 'state', 'general'],
    'hassan'   => ['state', 'city', 'mercy', 'general' ]
  }

  def self.main
    p StableMatch.run(APPLICANTS, PROGRAMS)
  end
end

Test.main
