# RR [![Build Status](https://secure.travis-ci.org/rr/rr.png)](http://travis-ci.org/rr/rr)

RR (Double Ruby) is a test double framework that features a rich selection of
double techniques and a terse syntax.

To get started, install RR from the command prompt:

~~~
gem install rr
~~~


## What is a test double?

A test double is a generalization of something that replaces a real object to
make it easier to test another object. It's like a stunt double for tests. The
following are test doubles:

* Mocks
* Stubs
* Fakes
* Spies
* Proxies

*Learn more: <http://xunitpatterns.com/Test%20Double.html>*

Currently RR implements mocks, stubs, proxies, and spies. Fakes usually require
custom code, so it is beyond the scope of RR.


## Using RR with your test framework

### Test::Unit

~~~ ruby
class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
~~~

### RSpec

RR actually has two adapters, one for the newest version of RSpec (2) and
another for the older version (1). Currently RSpec targets RR's RSpec-1 adapter
and so until this is fixed you will need to specify the RSpec-2 adapter:

~~~ ruby
RSpec.configure do |config|
  config.include(RR::Adapters::RSpec2)
end
~~~

### MiniTest / MiniSpec

~~~ ruby
class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end
~~~


## Syntax between RR and other double/mock frameworks

### Terse syntax

One of the goals of RR is to make doubles more scannable. This is accomplished
by making the double declaration look as much as the actual method invocation as
possible. Here is RR compared to other mock frameworks:

~~~ ruby
# Flexmock
flexmock(User).should_receive(:find).with('42').and_return(jane)
# RSpec
User.should_receive(:find).with('42').and_return(jane)
# Mocha
User.expects(:find).with('42').returns { jane }
# rspec-mocks (using return value blocks)
User.should_receive(:find).with('42') { jane }
# RR
mock(User).find('42') { jane }
~~~

### Double injections (aka partial mocking)

RR utilizes a technique known as "double injection".

~~~ ruby
my_object = MyClass.new
mock(my_object).hello
~~~

Compare this with doing a mock in Mocha:

~~~ ruby
my_mocked_object = mock()
my_mocked_object.expects(:hello)
~~~

### Pure mock objects

If you wish to use objects for the sole purpose of being a mock, you can do so
by creating an empty object:

~~~ ruby
mock(my_mock_object = Object.new).hello
~~~

However as a shortcut you can also use #mock!:

~~~ ruby
# Create a new mock object with an empty #hello method, then retrieve that mock
# object via the #subject method
my_mock_object = mock!.hello.subject
~~~

### No #should_receive or #expects method

RR uses #method_missing to set your method expectation. This means you do not
need to use a method such as #should_receive or #expects.

~~~ ruby
# In Mocha, #expects sets the #hello method expectation:
my_object.expects(:hello)
# Using rspec-mocks, #should_receive sets the #hello method expectation:
my_object.should_receive(:hello)
# And here's how you say it using RR:
mock(my_object).hello
~~~

### #with method call is not necessary

The fact that RR uses #method_missing also makes using the #with method
unnecessary in most circumstances to set the argument expectation itself
(although you can still use it if you want):

~~~ ruby
# Mocha
my_object.expects(:hello).with('bob', 'jane')
# rspec-mocks
my_object.should_receive(:hello).with('bob', 'jane')
# RR
mock(my_object).hello('bob', 'jane')
mock(my_object).hello.with('bob', 'jane')  # same thing, just more verbose
~~~

### Using a block to set the return value

RR supports using a block to set the return value as opposed to a specific
method call (although again, you can use #returns if you like):

~~~ ruby
# Mocha
my_object.expects(:hello).with('bob', 'jane').returns('Hello Bob and Jane')
# rspec-mocks
my_object.should_receive(:hello).with('bob', 'jane') { 'Hello Bob and Jane' }
my_object.should_receive(:hello).with('bob', 'jane').and_return('Hello Bob and Jane')  # same thing, just more verbose
# RR
mock(my_object).hello('bob', 'jane') { 'Hello Bob and Jane' }
mock(my_object).hello('bob', 'jane').returns('Hello Bob and Jane')  # same thing, just more verbose
~~~


## Using RR

To create a double on an object, you can use the following methods:

* #mock / #mock!
* #stub / #stub!
* #dont_allow / #dont_allow!
* #proxy / #proxy!
* #instance_of / #instance_of!

These methods are composable. #mock, #stub, and #dont_allow can be used by
themselves and are mutually exclusive. #proxy and #instance_of must be chained
with #mock or #stub. You can also chain #proxy and #instance_of together.

The ! (bang) version of these methods causes the subject object of the Double to
be instantiated.

### #mock

\#mock replaces the method on the object with an expectation and implementation.
The expectations are a mock will be called with certain arguments a certain
number of times (the default is once). You can also set the return value of the
method invocation.

*Learn more: <http://xunitpatterns.com/Mock%20Object.html>*

The following example sets an expectation that the view will receive a method
call to #render with the arguments `{:partial => "user_info"}` once. When the
method is called, `"Information"` is returned.

~~~ ruby
view = controller.template
mock(view).render(:partial => "user_info") {"Information"}
~~~

You can also allow any number of arguments to be passed into the mock like
this:

~~~ ruby
mock(view).render.with_any_args.twice do |*args|
  if args.first == {:partial => "user_info"}
    "User Info"
  else
    "Stuff in the view #{args.inspect}"
  end
end
~~~

### #stub

\#stub replaces the method on the object with only an implementation. You can
still use arguments to differentiate which stub gets invoked.

*Learn more: <http://xunitpatterns.com/Test%20Stub.html>*

The following example makes the User.find method return `jane` when passed "42"
and returns `bob` when passed "99". If another id is passed to User.find, an
exception is raised.

~~~ ruby
jane = User.new
bob = User.new
stub(User).find('42') {jane}
stub(User).find('99') {bob}
stub(User).find do |id|
  raise "Unexpected id #{id.inspect} passed to me"
end
~~~

### #dont_allow (aliased to #do_not_allow, #dont_call, and #do_not_call)

\#dont_allow is the opposite of #mock -- it sets an expectation on the Double
that it will never be called. If the Double actually does end up being called, a
TimesCalledError is raised.

~~~ ruby
dont_allow(User).find('42')
User.find('42') # raises a TimesCalledError
~~~

### `mock.proxy`

`mock.proxy` replaces the method on the object with an expectation,
implementation, and also invokes the actual method. `mock.proxy` also intercepts
the return value and passes it into the return value block.

The following example makes sets an expectation that `view.render({:partial =>
"right_navigation"})` gets called once and returns the actual content of the
rendered partial template. A call to `view.render({:partial => "user_info"})`
will render the "user_info" partial template and send the content into the block
and is represented by the `html` variable. An assertion is done on the value of
`html` and `"Different html"` is returned.

~~~ ruby
view = controller.template
mock.proxy(view).render(:partial => "right_navigation")
mock.proxy(view).render(:partial => "user_info") do |html|
  html.should include("John Doe")
  "Different html"
end
~~~

You can also use `mock.proxy` to set expectations on the returned value. In the
following example, a call to User.find('5') does the normal ActiveRecord
implementation and passes the actual value, represented by the variable `bob`,
into the block. `bob` is then set with a `mock.proxy` for projects to return only
the first 3 projects. `bob` is also mocked so that #valid? returns false.

~~~ ruby
mock.proxy(User).find('5') do |bob|
  mock.proxy(bob).projects do |projects|
    projects[0..3]
  end
  mock(bob).valid? { false }
  bob
end
~~~

### `stub.proxy`

Intercept the return value of a method call. The following example verifies
`render(:partial)` will be called and renders the partial.

~~~ ruby
view = controller.template
stub.proxy(view).render(:partial => "user_info") do |html|
  html.should include("Joe Smith")
  html
end
~~~

### #any_instance_of

Allows stubs to be added to all instances of a class. It works by binding to
methods from the class itself, rather than the eigenclass. This allows all
instances (excluding instances with the method redefined in the eigenclass) to
get the change.

Due to Ruby runtime limitations, mocks will not work as expected. It's not
obviously feasible (without an ObjectSpace lookup) to support all of RR's
methods (such as mocking). ObjectSpace is not readily supported in JRuby, since
it causes general slowness in the interpreter. I'm of the opinion that test
speed is more important than having mocks on all instances of a class. If there
is another solution, I'd be willing to add it.

~~~ ruby
any_instance_of(User) do |u|
  stub(u).valid? { false }
end
# or
any_instance_of(User, :valid? => false)
# or
any_instance_of(User, :valid? => lambda { false })
~~~

### Spies

Adding a DoubleInjection to an object + method (done by #stub, #mock, or
\#dont_allow) causes RR to record any method invocations to the object + method.
Assertions can then be made on the recorded method calls.

#### Test::Unit

~~~ ruby
subject = Object.new
stub(subject).foo
subject.foo(1)
assert_received(subject) {|subject| subject.foo(1) }
assert_received(subject) {|subject| subject.bar }  # This fails
~~~

#### RSpec

~~~ ruby
subject = Object.new
stub(subject).foo
subject.foo(1)
subject.should have_received.foo(1)
subject.should have_received.bar  # This fails
~~~

### Block syntax

The block syntax has two modes:

* A normal block mode with a DoubleDefinitionCreatorProxy argument:

  ~~~ ruby
  script = MyScript.new
  mock(script) do |expect|
    expect.system("cd #{RAILS_ENV}") {true}
    expect.system("rake foo:bar") {true}
    expect.system("rake baz") {true}
  end
  ~~~

* An instance_eval mode where the DoubleDefinitionCreatorProxy is
  instance_eval'ed:

  ~~~ ruby
  script = MyScript.new
  mock(script) do
    system("cd #{RAILS_ENV}") {true}
    system("rake foo:bar") {true}
    system("rake baz") {true}
  end
  ~~~

### Double graphs

RR has a method-chaining API support for double graphs. For example, let's say
you want an object to receive a method call to #foo, and have the return value
receive a method call to #bar.

In RR, you would do:

~~~ ruby
stub(object).foo.stub!.bar { :baz }
object.foo.bar  #=> :baz
# or:
stub(object).foo { stub!.bar {:baz} }
object.foo.bar  #=> :baz
# or:
bar = stub!.bar { :baz }
stub(object).foo { bar }
object.foo.bar  #=> :baz
~~~

### Modifying doubles

Whenever you create a double by calling a method on an object you've wrapped,
you get back a special object: a DoubleDefinition. In other words:

~~~ ruby
stub(object).foo     #=> RR::DoubleDefinitions::DoubleDefinition
~~~

There are several ways you can modify the behavior of these doubles via the
DoubleDefinition API, and they are listed in this section.

Quick note: all of these methods accept blocks as a shortcut for setting the
return value at the same time. In other words, if you have something like this:

~~~ ruby
mock(object).foo { 'bar' }
~~~

you can modify the mock and keep the return value like so:

~~~ ruby
mock(object).foo.times(2) { 'bar' }
~~~

You can even flip around the block:

~~~ ruby
mock(object).foo { 'bar' }.times(2)
~~~

And as we explain below, this is just a shortcut for:

~~~ ruby
mock(object).foo.returns { 'bar' }.times(2)
~~~

#### Stubbing method implementation / return value

There are two ways here. We have already covered this usage:

~~~ ruby
stub(object).foo { 'bar' }
~~~

However, you can also use #returns if it's more clear to you:

~~~ ruby
stub(object).foo.returns { 'bar' }
~~~

Regardless, keep in mind that you're actually supplying the implementation of
the method in question here, so you can put whatever you want in this block:

~~~ ruby
stub(object).foo { |age, count|
  raise 'hell' if age < 16
  ret = yield count
  blue? ? ret : 'whatever'
}
~~~

This works for mocks as well as stubs.

#### Stubbing method implementation based on argument expectation

A double's implementation is always tied to its argument expectation. This means
that it is possible to return one value if the method is called one way and
return a second value if the method is called a second way. For example:

~~~ ruby
stub(object).foo { 'bar' }
stub(object).foo(1, 2) { 'baz' }
object.foo        #=> 'bar'
object.foo(1, 2)  #=> 'baz'
~~~

This works for mocks as well as stubs.

#### Stubbing method to yield given block

If you need to stub a method such that a block given to it is guaranteed to be
called when the method is called, then use #yields.

~~~ ruby
# This outputs: [1, 2, 3]
stub(object).foo.yields(1, 2, 3)
object.foo {|*args| pp args }
~~~

This works for mocks as well as stubs.

#### Expecting method to be called with exact argument list

There are two ways to do this. Here is the way we have shown before:

~~~ ruby
mock(object).foo(1, 2)
object.foo(1, 2)   # ok
object.foo(3)      # fails
~~~

But if this is not clear enough to you, you can use #with:

~~~ ruby
mock(object).foo.with(1, 2)
object.foo(1, 2)   # ok
object.foo(3)      # fails
~~~

As seen above, if you create an the expectation for a set of arguments and the
method is called with another set of arguments, even if *those* arguments are of
a completely different size, you will need to create another expectation for
them somehow. A simple way to do this is to #stub the method beforehand:

~~~ ruby
stub(object).foo
mock(object).foo(1, 2)
object.foo(1, 2)   # ok
object.foo(3)      # ok too
~~~

#### Expecting method to be called with any arguments

Use #with_any_args:

~~~ ruby
mock(object).foo.with_any_args
object.foo        # ok
object.foo(1)     # also ok
object.foo(1, 2)  # also ok
                  # ... you get the idea
~~~

#### Expecting method to be called with no arguments

Use #with_no_args:

~~~ ruby
mock(object).foo.with_no_args
object.foo        # ok
object.foo(1)     # fails
~~~

#### Expecting method to never be called

Use #never:

~~~ ruby
mock(object).foo.never
object.foo        # fails
~~~

You can also narrow the negative expectation to a specific set of arguments.
Of course, you will still need to set explicit expectations for any other ways
that your method could be called. For instance:

~~~ ruby
mock(object).foo.with(1, 2).never
object.foo(3, 4)  # fails
~~~

RR will complain here that this is an unexpected invocation, so we need to add
an expectation for this beforehand. We can do this easily with #stub:

~~~ ruby
stub(object).foo
~~~

So, a full example would look like:

~~~ ruby
stub(object).foo
mock(object).foo.with(1, 2).never
object.foo(3, 4)   # ok
object.foo(1, 2)   # fails
~~~

Alternatively, you can also use #dont_allow, although the same rules apply as
above:

~~~ ruby
stub(object).foo
dont_allow(object).foo.with(1, 2)
object.foo(3, 4)   # ok
object.foo(1, 2)   # fails
~~~

#### Expecting method to be called only once

Use #once:

~~~ ruby
mock(object).foo.once
object.foo
object.foo    # fails
~~~

#### Expecting method to called exact number of times

Use #times:

~~~ ruby
mock(object).foo.times(3)
object.foo
object.foo
object.foo
object.foo    # fails
~~~

#### Expecting method to be called minimum number of times

Use #at_least.

For instance, this would pass:

~~~ ruby
mock(object).foo.at_least(3)
object.foo
object.foo
object.foo
object.foo
~~~

But this would fail:

~~~ ruby
mock(object).foo.at_least(3)
object.foo
object.foo
~~~

#### Expecting method to be called maximum number of times

Use #at_most.

For instance, this would pass:

~~~ ruby
mock(object).foo.at_most(3)
object.foo
object.foo
~~~

But this would fail:

~~~ ruby
mock(object).foo.at_most(3)
object.foo
object.foo
object.foo
object.foo
~~~

#### Expecting method to be called any number of times

Use #any_times. This effectively disables the times-called expectation.

~~~ ruby
mock(object).foo.any_times
object.foo
object.foo
object.foo
...
~~~

You can also use #times + the argument invocation #any_times matcher:

~~~ ruby
mock(object).foo.times(any_times)
object.foo
object.foo
object.foo
...
~~~



### Argument wildcard matchers

RR also has several methods which you can use with argument expectations which
act as placeholders for arguments. When RR goes to verify the argument
expectation it will compare the placeholders with the actual arguments the
method was called with, and if they match then the test passes (hence
"matchers").

#### #anything

Matches any value.

~~~ ruby
mock(object).foobar(1, anything)
object.foobar(1, :my_symbol)
~~~

#### #is_a

Matches an object which `.is_a?(*Class*)`.

~~~ ruby
mock(object).foobar(is_a(Time))
object.foobar(Time.now)
~~~

#### #numeric

Matches a value which `.is_a?(Numeric)`.

~~~ ruby
mock(object).foobar(numeric)
object.foobar(99)
~~~~

#### #boolean

Matches true or false.

~~~ ruby
mock(object).foobar(boolean)
object.foobar(false)
~~~

#### #duck_type

Matches an object which responds to certain methods.

~~~ ruby
mock(object).foobar(duck_type(:walk, :talk))
arg = Object.new
def arg.walk; 'waddle'; end
def arg.talk; 'quack'; end
object.foobar(arg)
~~~

#### Ranges

Matches a number within a certain range.

~~~ ruby
mock(object).foobar(1..10)
object.foobar(5)
~~~

#### Regexps

Matches a string which matches a certain regex.

~~~ ruby
mock(object).foobar(/on/)
object.foobar("ruby on rails")
~~~

#### #hash_including

Matches a hash which contains a subset of keys and values.

~~~ ruby
mock(object).foobar(hash_including(:red => "#FF0000", :blue => "#0000FF"))
object.foobar({:red => "#FF0000", :blue => "#0000FF", :green => "#00FF00"})
~~~

#### #satisfy

Matches an argument which satisfies a custom requirement.

~~~ ruby
mock(object).foobar(satisfy {|arg| arg.length == 2 })
object.foobar("xy")
~~~

#### Writing your own argument matchers

Writing a custom argument wildcard matcher is not difficult.  See
RR::WildcardMatchers for details.

### Invocation amount wildcard matchers

#### #any_times

Only used with #times and matches any number.

~~~ ruby
mock(object).foo.times(any_times) { return_value }
object.foo
object.foo
object.foo
...
~~~


## Special thanks to

With any development effort, there are countless people who have contributed to
making it possible. We all are standing on the shoulders of giants. If you have
directly contributed to RR and I missed you in this list, please let me know and
I will add you. Thanks!

* Andreas Haller for patches
* Aslak Hellesoy for Developing RSpec
* Bryan Helmkamp for patches
* Caleb Spare for patches
* Christopher Redinger for patches
* Dan North for syntax ideas
* Dave Astels for some BDD inspiration
* Dave Myron for a bug report
* David Chelimsky for encouragement to make the RR framework, for developing the
  RSpec mock framework, syntax ideas, and patches
* Daniel Sudol for identifing performance issues with RR
* Dmitry Ratnikov for patches
* Eugene Pimenov for patches
* Evan Phoenix for patches
* Felix Morio for pairing with me
* Gabriel Horner for patches
* Gavin Miller for patches
* Gerard Meszaros for his excellent book "xUnit Test Patterns"
* James Mead for developing Mocha
* Jeff Whitmire for documentation suggestions
* Jim Weirich for developing Flexmock, the first Terse ruby mock framework in Ruby
* Joe Ferris for patches
* Matthew O'Connor for patches and pairing with me
* Michael Niessner for patches and pairing with me
* Mike Mangino (from Elevated Rails) for patches and pairing with me
* Myron Marston for bug reports
* Nick Kallen for documentation suggestions, bug reports, and patches
* Nathan Sobo for various ideas and inspiration for cleaner and more expressive code
* Parker Thompson for pairing with me
* Phil Darnowsky for patches
* Pivotal Labs for sponsoring RR development
* Steven Baker for Developing RSpec
* Tatsuya Ono for patches
* Tuomas Kareinen for a bug report

