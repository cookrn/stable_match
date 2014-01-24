# StableMatch

[![Gem Version](https://badge.fury.io/rb/stable_match.png)](http://badge.fury.io/rb/stable_match)
[![Build Status](https://travis-ci.org/cookrn/stable_match.png?branch=master)](https://travis-ci.org/cookrn/stable_match)

A generic implementation of the Stable Match class of algorithms.

## Usage

* See: `examples/example_1.rb`
* See: `test/functional/nrmp_test.rb`
* See: `test/functional/stable_marriage_test.rb`
* Run: `rake example`

The idea behind stable matching is the following: You have two sets of
data that you would like to find the most ideal matching between. Stable
matching means that candidates from either set might remain unmatched.
Unstable matching means that matches are forced even if they are not
ideal.

Your inputs are two hashes where the keys are known as 'target's to
StableMatch. Targets ideally are domain specific objects to your
application. The value in the hash for each target is an array of
preferences for the target. (See the note below about when preferences
are themselves each an Array object.)

Preferences are an ordered array of 'target's belonging to the other set
such that, the lower the index, the higher the preference. This is required
and checked at runtime. It can be an empty array, but all preferences must
belong to the other set.

The final argument that a `Candidate` object can be instantiated with is
called `match_positions` and equates to the number of matches that the
given target can acquire. This is optional and defaults to 1.

### In-Depth Example (IN PROGRESS)

Let's talk about a dog-walker example. We have two domain classes: Dog
and Walker. Let's say that the preferences will be determined by the
weight and geographic location of the dog.

```
TODO !!
FIXME !!
this needs finished
```

### Gotchas

* To match against objects that _are_ arrays, they'll need to be
  preemptively wrapped in another array when passing them a runner. See
  the NRMP test in `test/functional` for example.

## Installation

### Without Bundler

Install it yourself:

```
$ gem install stable_match
```

### With Bundler

Add this line to your application's Gemfile:

```ruby
gem 'stable_match'
```

And then execute:

```
$ bundle
```

## References

* [http://halfamind.aghion.com/the-national-resident-matching-programs-nrmp](http://halfamind.aghion.com/the-national-resident-matching-programs-nrmp)
* [http://rosettacode.org/wiki/Stable_marriage_problem#Ruby](http://rosettacode.org/wiki/Stable_marriage_problem#Ruby)
* [http://en.wikipedia.org/wiki/Stable_marriage_problem#Algorithm](http://en.wikipedia.org/wiki/Stable_marriage_problem#Algorithm)
* [http://en.wikipedia.org/wiki/National_Resident_Matching_Program](http://en.wikipedia.org/wiki/National_Resident_Matching_Program)
* [http://www.nrmp.org/res_match/about_res/algorithms.html](http://www.nrmp.org/res_match/about_res/algorithms.html)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
