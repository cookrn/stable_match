require "test_helper"

class StableMarriageFunctionalTest < MiniTest::Unit::TestCase
  def test_case
    men = {
      'abe'  => { :preferences => %w(abi eve cath ivy jan dee fay bea hope gay) },
      'bob'  => { :preferences => %w(cath hope abi dee eve fay bea jan ivy gay) },
      'col'  => { :preferences => %w(hope eve abi dee bea fay ivy gay cath jan) },
      'dan'  => { :preferences => %w(ivy fay dee gay hope eve jan bea cath abi) },
      'ed'   => { :preferences => %w(jan dee bea cath fay eve abi ivy hope gay) },
      'fred' => { :preferences => %w(bea abi dee gay eve ivy cath jan hope fay) },
      'gav'  => { :preferences => %w(gay eve ivy bea cath abi dee hope jan fay) },
      'hal'  => { :preferences => %w(abi eve hope fay ivy cath jan bea gay dee) },
      'ian'  => { :preferences => %w(hope cath dee gay bea abi fay ivy jan eve) },
      'jon'  => { :preferences => %w(abi fay jan gay eve bea dee cath ivy hope) }
    }

    women = {
      'abi'  => { :preferences => %w(bob fred jon gav ian abe dan ed col hal) },
      'bea'  => { :preferences => %w(bob abe col fred gav dan ian ed jon hal) },
      'cath' => { :preferences => %w(fred bob ed gav hal col ian abe dan jon) },
      'dee'  => { :preferences => %w(fred jon col abe ian hal gav dan bob ed) },
      'eve'  => { :preferences => %w(jon hal fred dan abe gav col ed ian bob) },
      'fay'  => { :preferences => %w(bob abe ed ian jon dan fred gav col hal) },
      'gay'  => { :preferences => %w(jon gav hal fred bob abe col ed dan ian) },
      'hope' => { :preferences => %w(gav jon bob abe ian dan hal ed col fred) },
      'ivy'  => { :preferences => %w(ian col hal gav fred bob abe ed jon dan) },
      'jan'  => { :preferences => %w(ed hal gav abe bob jon col ian fred dan) }
    }

    mens_expectations = {
      'abe'  => [ 'ivy' ],
      'bob'  => [ 'cath' ],
      'col'  => [ 'dee' ],
      'dan'  => [ 'fay' ],
      'ed'   => [ 'jan' ],
      'fred' => [ 'bea' ],
      'gav'  => [ 'gay' ],
      'hal'  => [ 'eve' ],
      'ian'  => [ 'hope' ],
      'jon'  => [ 'abi' ]
    }

    womens_expectations = {
      'abi'  => [ 'jon' ],
      'bea'  => [ 'fred' ],
      'cath' => [ 'bob' ],
      'dee'  => [ 'col' ],
      'eve'  => [ 'hal' ],
      'fay'  => [ 'dan' ],
      'gay'  => [ 'gav' ],
      'hope' => [ 'ian' ],
      'ivy'  => [ 'abe' ],
      'jan'  => [ 'ed' ]
    }

    runner = StableMatch.run men , women , :strategy => :asymmetric

    ## men
    #
      mens_expectations.each do | man , expected_matches |
        candidate      = runner.candidate_set1[ man ]
        actual_matches = candidate.matches.map &:target
        assert{ expected_matches.sort == actual_matches.sort }
      end

    ## women
    #
      womens_expectations.each do | woman , expected_matches |
        candidate      = runner.candidate_set2[ woman ]
        actual_matches = candidate.matches.map &:target
        assert{ expected_matches.sort == actual_matches.sort }
      end
  end
end
