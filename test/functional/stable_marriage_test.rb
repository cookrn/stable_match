require 'test_helper'

class StableMarriageTest < StableMatch::Test
  def test_case
    men = {
      'abe'  => %w(abi eve cath ivy jan dee fay bea hope gay),
      'bob'  => %w(cath hope abi dee eve fay bea jan ivy gay),
      'col'  => %w(hope eve abi dee bea fay ivy gay cath jan),
      'dan'  => %w(ivy fay dee gay hope eve jan bea cath abi),
      'ed'   => %w(jan dee bea cath fay eve abi ivy hope gay),
      'fred' => %w(bea abi dee gay eve ivy cath jan hope fay),
      'gav'  => %w(gay eve ivy bea cath abi dee hope jan fay),
      'hal'  => %w(abi eve hope fay ivy cath jan bea gay dee),
      'ian'  => %w(hope cath dee gay bea abi fay ivy jan eve),
      'jon'  => %w(abi fay jan gay eve bea dee cath ivy hope)
    }

    women = {
      'abi'  => %w(bob fred jon gav ian abe dan ed col hal),
      'bea'  => %w(bob abe col fred gav dan ian ed jon hal),
      'cath' => %w(fred bob ed gav hal col ian abe dan jon),
      'dee'  => %w(fred jon col abe ian hal gav dan bob ed),
      'eve'  => %w(jon hal fred dan abe gav col ed ian bob),
      'fay'  => %w(bob abe ed ian jon dan fred gav col hal),
      'gay'  => %w(jon gav hal fred bob abe col ed dan ian),
      'hope' => %w(gav jon bob abe ian dan hal ed col fred),
      'ivy'  => %w(ian col hal gav fred bob abe ed jon dan),
      'jan'  => %w(ed hal gav abe bob jon col ian fred dan)
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

    runner = StableMatch.run men , women , :asymmetric

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
