# Changelog

## 1.0.5 (2013-03-28)

* Compatibility with RSpec-2. There are now two adapters for RSpec, one that
  works with RSpec-1 and a new one that works with RSpec-2. Currently, saying
  `RSpec.configure {|c| c.mock_with(:rr) }` still uses RSpec-1; to use the new
  one, you say `RSpec.configure {|c| c.mock_framework = RR::Adapters::RSpec2 }`.
  (#66, #68, #80) [njay, james2m]
* Fix MethodMissingInjection so that `[stub].flatten` works without throwing a
  NoMethodError (undefined method #to_ary) error under Ruby 1.9 (#44)
* Raise a MiniTest::Assertion error in the MiniTest adapter so that mock
  failures appear in the output as failures rather than uncaught exceptions
  (#69) [jayferd]
* Completely remove leftover #new_instance_of method, and also remove
  mention of #new_instance_of from the README
* Fix tests so they all work and pass again

## 1.0.4 (2011-06-11)

* Fixed bug using workaround with leftover MethodMissingInjections

## 1.0.3 (2011-06-11)

* Eliminate usage of ObjectSpace._id2ref (Patch Evan Phoenix)
* Added minitest adapter (Patch Caleb Spare)
* Added instructions on installing the gem (Patch Gavin Miller)
* delete missing scratch.rb file from gemspec (Patch bonkydog)

## 1.0.2 (2010-11-01)

* Fixed Two calls recorded to a mock expecting only one call when called via
  another mock's yield block
  (http://github.com/btakita/rr/issues/closed#issue/42). Patch by Eugene Pimenov
  (http://github.com/libc).

## 1.0.1 (2010-10-30)

* Removed new_instance_of for Ruby 1.9.2 compatibility. instance_of is now an
  alias for any_instance_of.
* Compatible with Ruby 1.9.2

## 1.0.0 (2010-08-23)

* Added any_instance_of (aliased by all_instances_of), which binds methods
  directly to the class (instead of the eigenclass).
* Subclasses of a injected class do not have their methods overridden.
* any_instance_of and new_instance_of now have a block syntax

## 0.10.11 (2010-03-22)

* Added RR.blank_slate_whitelist
* Fixed class_eval method redefinition warning in jruby

## 0.10.10 (2010-02-25)

* Suite passes for Ruby 1.9.1

## 0.10.9 (2010-02-17)

* Fixed 1.8.6 bug for real

## 0.10.8 (2010-02-16)

* Fixed 1.8.6 bug

## 0.10.7 (2010-02-15)

* Fixed issue with DoubleInjections binding to objects overriding the method
  method.

## 0.10.6 (2010-02-15)

* Added MIT license
* Fixed Bug - dont_allow doesn't work when it follows stub
  (http://github.com/btakita/rr/issues#issue/20)
* Fixed exception with DoubleInjections on proxy objects
  (http://github.com/btakita/rr/issues#issue/24)
* Fixed Bug - Can't stub attribute methods on a BelongsToAssociation
  (http://github.com/btakita/rr/issues#issue/24)

## 0.10.5 (2009-12-20)

* Fixed stack overflow caused by double include in Test::Unit adapter
  [http://github.com/btakita/rr/issues#issue/16]. Identified by Dave Myron
  (http://github.com/contentfree)
* Fixed warnings (Patch by Bryan Helmkamp)

## 0.10.4 (2009-09-26)

* Handle lazily defined methods (where respond_to? returns true yet the method
  is not yet defined and the first call to method_missing defines the method).
  This pattern is used in ActiveRecord and ActionMailer.
* Fixed warning about aliasing #instance_exec in jruby.
  http://github.com/btakita/rr/issues#issue/9 (Patch by Nathan Sobo)

## 0.10.2 (2009-08-30)

* RR properly proxies subjects with private methods
  [http://github.com/btakita/rr/issues/#issue/7]. Identified by Matthew
  O'Connor.

## 0.10.1 (???)

* Fixed issue with DoubleInjection not invoking methods that are lazily created
  [http://github.com/btakita/rr/issues/#issue/4]. Identified by davidlee
  (http://github.com/davidlee)
* Fixed issue with mock.proxy and returns
  [http://github.com/btakita/rr/issues/#issue/2]. Identified by trogdoro
  (http://github.com/trogdoro)

## 0.10.0 (2009-06-01)

* Method is no longer invoked if respond_to? returns false. This was in place to
  support ActiveRecord association proxies, and is no longer needed.

## 0.9.0 (2009-04-25)

* instance_of Doubles now apply to methods invoked in the subject's #initialize
  method.

## 0.8.1 (2009-03-29)

* Fixed exception where the Subject uses method delegation via method_missing
  (e.g. certain ActiveRecord AssociationProxy methods)

##  0.8.0 (2009-03-29)

* Fixed compatability issues with Ruby 1.9
* Aliased any_number_of_times with any_times
* Better error messages for have_received and assert_received matchers (Patch by
  Joe Ferris)
* Better documentation on RR wilcard matchers (Patch by Phil Arnowsky)

## 0.7.1 (2009-01-16)

* Performance improvements

## 0.7.0 (2008-12-14)

* Added spies (Patchs by Joe Ferris, Michael Niessner & Mike Mangino)
* Added strongly typed reimplementation doubles (Patch by Michael Niessner)

## 0.6.2 (???)

* Fixed DoubleDefinition chaining edge cases

## 0.6.1 (???)

* DoubleDefinitionCreatorProxy definition eval block is instance_evaled when the
  arity is not 1. When the arity is 1, the block is yielded with the
  DoubleDefinitionCreatorProxy passed in.

## 0.6.0 (2008-10-13)

* Friendlier DoubleNotFound error message
* Implemented Double strategy creation methods (#mock, #stub, #proxy,
  #instance_of, and ! equivalents) on DoubleDefinition
* Implemented hash_including matcher (Patch by Matthew O'Conner)
* Implemented satisfy matcher (Patch by Matthew O'Conner)
* Implemented DoubleDefinitionCreator#mock!, #stub!, and #dont_allow!
* Modified api to method chain Doubles
* Fix conflict with Mocha overriding Object#verify

## 0.5.0 (???)

* Method chaining Doubles (Patch by Nick Kallen)
* Chained ordered expectations (Patch by Nick Kallen)
* Space#verify_doubles can take one or more objects with DoubleInjections to be
  verified

## 0.4.10 (2008-07-06)

* DoubleDefinitionCreatorProxy does not undef #object_id
* Fixed rdoc pointer to README

## 0.4.9 (2008-06-18)

* Proxying from RR module to RR::Space.instance

## 0.4.8 (2008-01-23)

* Fixed issue with Hash arguments

## 0.4.7 (2008-01-23)

* Improved error message

## 0.4.6 (2008-01-23)

* Added Double#verbose and Double#verbose?

## 0.4.5 (2008-01-15)

* Fixed doubles for == and #eql? methods

## 0.4.4 (2008-01-15)

* Doc improvements
* Methods that are not alphabetic, such as ==, can be doubles

## 0.4.3 (2008-01-07)

* Doc improvements
* Cleanup
* Finished renaming scenario to double

## 0.4.2 (2007-12-31)

* Renamed DoubleInsertion to DoubleInjection to be consistent with Mocha
  terminology

## 0.4.1 (2007-12-31)

* Fixed backward compatability issues with rspec
* Renamed Space#verify_double_insertions to #verify_doubles

## 0.4.0 (2007-12-30)

* Documentation improvements
* Renamed Double to DoubleInsertion
* Renamed Scenario to Double

## 0.3.11 (2007-09-06)

* Fixed [#13724] Mock Proxy on Active Record Association proxies causes error

## 0.3.10 (2007-08-18)

* Fixed [#13139] Blocks added to proxy sets the return_value and not the
  after_call callback

## 0.3.9 (2007-08-14)

* Alias probe to proxy

## 0.3.8 (2007-08-12)

* Implemented [#13009] Better error mesage from TimesCalledMatcher

## 0.3.7 (2007-08-09)

* Fixed [#12928] Reset doubles fails on Rails association proxies

## 0.3.6 (2007-08-01)

* Fixed [#12765] Issues with ObjectSpace._id2ref

## 0.3.5 (2007-07-29)

* trim_backtrace is only set for Test::Unit

## 0.3.4 (2007-07-22)

* Implemented instance_of

## 0.3.3 (2007-07-22)

* Fixed [#12495] Error Probing method_missing interaction

## 0.3.2 (2007-07-22)

* Fixed [#12486] ScenarioMethodProxy when Kernel passed into instance methods

## 0.3.1 (2007-07-22)

* Automatically require Test::Unit and Rspec adapters

## 0.3.0 (2007-07-22)

* ScenarioCreator strategy method chaining
* Removed mock_probe
* Removed stub_probe

## 0.2.5 (2007-07-21)

* mock takes method_name argument
* stub takes method_name argument
* mock_probe takes method_name argument
* stub_probe takes method_name argument
* probe takes method_name argument
* dont_allow takes method_name argument
* do_not_allow takes method_name argument

## 0.2.4 (2007-07-19)

* Space#doubles key is now the object id
* Fixed [#12402] Stubbing return value of probes fails after calling the stubbed
  method two times

## 0.2.3 (2007-07-18)

* Added RRMethods#rr_verify and RRMethods#rr_reset

## 0.2.2 (2007-07-17)

* Fixed "singleton method bound for a different object"
* Doing Method aliasing again to store original method

## 0.2.1 (2007-07-17)

* Added mock_probe
* Added stub_probe
* Probe returns the return value of the passed in block, instead of ignoring its
  return value
* Scenario#after_call returns the return value of the passed in block
* Not using method aliasing to store original method
* Renamed DoubleMethods to RRMethods
* Added RRMethods#mock_probe

## 0.1.15 (2007-07-17)

* Fixed [#12333] Rebinding original_methods causes blocks not to work

## 0.1.14 (2007-07-16)

* Introduced concept of Terminal and NonTerminal TimesCalledMatchers
* Doubles that can be called many times can be replaced
* Terminal Scenarios are called before NonTerminal Scenarios
* Error message tweaking
* Raise error when making a Scenarios with NonTerminal TimesMatcher Ordered

## 0.1.13 (2007-07-14)

* Fixed [#12290] Scenario#returns with false causes a return value of nil

## 0.1.12 (2007-07-14)

* Fixed bug where Creators methods are not removed when methods are defined on
  Object
* Fixed [#12289] Creators methods are not removed in Rails environment

## 0.1.11 (2007-07-14)

* Fixed [#12287] AtLeastMatcher does not cause Scenario to be called

## 0.1.10 (2007-07-14)

* Fixed [#12286] AnyArgumentExpectation#expected_arguments not implemented

## 0.1.9 (2007-07-14)

* Added DoubleMethods#any_times
* Added Scenario#any_number_of_times

## 0.1.8 (2007-07-14)

* TimesCalledError Message Formatted to be on multiple lines
* ScenarioNotFoundError Message includes all Scenarios for the Double
* ScenarioOrderError shows list of remaining ordered scenarios

## 0.1.7 (2007-07-14)

* Fixed [#12194] Double#reset_doubles are not clearing Ordered Scenarios bug
* Added Space#reset
* Space#reset_doubles and Space#reset_ordered_scenarios is now protected
* Added Scenario#at_least
* Added Scenario#at_most

## 0.1.6 (2007-07-10)

* [#12120] probe allows a the return value to be intercepted

## 0.1.5 (2007-07-09)

* TimesCalledExpectation says how many times were called and how many times
  called were expected on error

## 0.1.4 (2007-07-09)

* TimesCalledError prints the backtrace to where the Scenario was defined when
  being verified
* Error message includes method name when Scenario is not found

## 0.1.3 (2007-07-09)

* Fixed issue where Double#placeholder_name issues when Double method name has a
  ! or ?

## 0.1.2 (2007-07-08)

* Scenario#returns also accepts an argument
* Implemented Scenario#yields

## 0.1.1 (2007-07-08)

* Trim the backtrace for Rspec and Test::Unit
* Rspec and Test::Unit integration fixes

## 0.1.0 (2007-07-07)

* Initial Release
