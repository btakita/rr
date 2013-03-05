# RR

RR (Double Ruby) is a test double framework that features a rich selection of
double techniques and a terse syntax.

To get started, install RR from the command prompt:

~~~
gem install rr
~~~


## More Information

### Mailing Lists

* double-ruby-users@rubyforge.org
* double-ruby-devel@rubyforge.org

### Websites

* http://rubyforge.org/projects/double-ruby
* http://github.com/btakita/rr

## What is a Test Double?

A test double is a generalization of something that replaces a real
object to make it easier to test another object. Its like a stunt
double for tests. The following are test doubles:

* Mocks
* Stubs
* Fakes
* Spies
* Proxies

<http://xunitpatterns.com/Test%20Double.html>

Currently RR implements mocks, stubs, proxies, and spies. Fakes usually require
custom code, so it is beyond the scope of RR.


## Using RR

### Test::Unit

~~~ ruby
class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
~~~

### RSpec

~~~ ruby
RSpec.configure do |config|
  config.mock_framework = :rr
end
~~~

### Standalone

~~~ ruby
extend RR::Adapters::RRMethods
mock(object).method_name { :return_value }

object.method_name   # Returns :return_value

RR.verify   # Verifies the Double expectations are satisfied
~~~


## Syntax Between RR and Other Double/Mock Frameworks

### Terse Syntax

One of the goals of RR is to make doubles more scannable. This is accomplished
by making the double declaration look as much as the actual method invocation as
possible. Here is RR compared to other mock frameworks:

~~~ ruby
flexmock(User).should_receive(:find).with('42').and_return(jane)  # Flexmock
User.should_receive(:find).with('42').and_return(jane)  # RSpec
User.expects(:find).with('42').returns {jane}  # Mocha
User.should_receive(:find).with('42') {jane}  # RSpec using return value blocks
mock(User).find('42') {jane}  # RR
~~~

### Double Injections (aka Partial Mocking)

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

### Pure Mock Objects

If you wish to use objects for the sole purpose of being a mock, you can do so
by creating an empty object:

~~~ ruby
mock(my_mock_object = Object.new).hello
~~~

or by using `mock!`:

~~~ ruby
# Mocks the #hello method and retrieves that object via the #subject method
my_mock_object = mock!.hello.subject
~~~

### No `should_receive` or `expects` method

RR uses method_missing to set your method expectation. This means you do not
need to use a method such as `should_receive` or `expects`.

~~~ ruby
# In Mocha, #expects sets the #hello method expectation
my_object.expects(:hello)
# Using rspec-mocks, #should_receive sets the #hello method expectation
my_object.should_receive(:hello)
# Here's how you say it using RR
mock(my_object).hello
~~~

### #with method call is not necessary

Since RR uses method_missing, it also makes using the #with method unnecessary
in most circumstances to set the argument expectations.

~~~ ruby
# Mocha
my_object.expects(:hello).with('bob', 'jane')
# rspec-mocks
my_object.should_receive(:hello).with('bob', 'jane')
# RR
mock(my_object).hello('bob', 'jane')
~~~

### Using a block to set the return value

RR supports using a block to set the return value. RR also has the #returns
method.

~~~ ruby
# Mocha
my_object.expects(:hello).with('bob', 'jane').returns('Hello Bob and Jane')
# rspec-mocks
my_object.should_receive(:hello).with('bob', 'jane').and_return('Hello Bob and Jane')
my_object.should_receive(:hello).with('bob', 'jane') { 'Hello Bob and Jane' }   # shorter way
# RR
mock(my_object).hello('bob', 'jane').returns('Hello Bob and Jane')
mock(my_object).hello('bob', 'jane') { 'Hello Bob and Jane' }   # shorter way
~~~


## Using RR

To create a double on an object, you can use the following methods:

* mock / mock!
* stub / stub!
* dont_allow / dont_allow!
* proxy / proxy!
* instance_of / instance_of!

These methods are composable. #mock, #stub, and #dont_allow can be used by
themselves and are mutually exclusive. #proxy and #instance_of must be chained
with #mock or #stub. You can also chain #proxy and #instance_of together.

The ! (bang) version of these methods causes the subject object of the Double to
be instantiated.

### mock

\#mock replaces the method on the object with an expectation and implementation.
The expectations are a mock will be called with certain arguments a certain
number of times (the default is once). You can also set the return value of the
method invocation.

See <http://xunitpatterns.com/Mock%20Object.html> for more information on what a
mock is.

The following example sets an expectation that the view will receive a method
call to #render with the arguments `{:partial => "user_info"}` once. When the
method is called, "Information" is returned.

~~~ ruby
view = controller.template
mock(view).render(:partial => "user_info") {"Information"}
~~~

You can also allow any number of arguments to be passed into the mock. Like
this:

~~~ ruby
mock(view).render.with_any_args.twice do |*args|
  if args.first == {:partial => "user_info}
    "User Info"
  else
    "Stuff in the view #{args.inspect}"
  end
end
~~~

### stub

\#stub replaces the method on the object with only an implementation. You can
still use arguments to differentiate which stub gets invoked.

See <http://xunitpatterns.com/Test%20Stub.html> for more information on what a
stub is.

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

### dont_allow (aliased with do_not_allow, dont_call, and do_not_call)

dont_allow sets an expectation on the Double that it will never be called. If
the Double actually does end up being called, a TimesCalledError is raised.

~~~ ruby
dont_allow(User).find('42')
User.find('42') # raises a TimesCalledError
~~~

### mock.proxy

mock.proxy replaces the method on the object with an expectation,
implementation, and also invokes the actual method. mock.proxy also intercepts
the return value and passes it into the return value block.

The following example makes sets an expectation that `view.render({:partial =>
"right_navigation"})` gets called once and returns the actual content of the
rendered partial template. A call to `view.render({:partial => "user_info"})`
will render the user_info partial template and send the content into the block
and is represented by the `html` variable. An assertion is done on the html and
"Different html" is returned.

~~~ ruby
view = controller.template
mock.proxy(view).render(:partial => "right_navigation")
mock.proxy(view).render(:partial => "user_info") do |html|
  html.should include("John Doe")
  "Different html"
end
~~~

You can also use mock.proxy to set expectations on the returned value. In the
following example, a call to User.find('5') does the normal ActiveRecord
implementation and passes the actual value, represented by the variable `bob`,
into the block. `bob` is then set with a mock.proxy for projects to return only
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

### stub.proxy

Intercept the return value of a method call. The following example verifies
render partial will be called and renders the partial.

~~~ ruby
view = controller.template
stub.proxy(view).render(:partial => "user_info") do |html|
  html.should include("Joe Smith")
  html
end
~~~

### any_instance_of

Allows stubs to be added to all instances of a class. It works by binding to
methods from the class itself, rather than the eigenclass. This allows all
instances (excluding instances with the method redefined in the eigenclass) to
get the change.

Due to Ruby runtime limitations, mocks will not work as expected. It's not
obviously feasible (without an ObjectSpace lookup) to support all of RR's
methods (such as mocking). ObjectSpace is not readily supported in jRuby, since
it causes general slowness in the interpreter. I'm of the opinion that test
speed is more important than having mocks on all instances of a class. If there
is another solution, I'd be willing to add it.

~~~ ruby
any_instance_of(User) do |u|
  stub(u).valid? {false}
end
# or
any_instance_of(User, :valid? => false)
# or
any_instance_of(User, :valid? => lambda { false })
~~~

### new_instance_of

Stubs the new method of the class and allows doubles to be bound to new instances.

Mocks can be used, because new instances are deterministically bound.

~~~ ruby
new_instance_of(User) do |u|
  mock(u).valid? { false }
end
# Deprecated syntax
mock.instance_of(User).valid? { false }
~~~

### Spies

Adding a DoubleInjection to an Object + Method (done by stub, mock, or
dont_allow) causes RR to record any method invocations to the Object + method.
Assertions can then be made on the recorded method calls.

#### Test::Unit

~~~ ruby
subject = Object.new
stub(subject).foo
subject.foo(1)
assert_received(subject) {|subject| subject.foo(1)}
assert_received(subject) {|subject| subject.bar} # This fails
~~~

#### RSpec

~~~ ruby
subject = Object.new
stub(subject).foo
subject.foo(1)
subject.should have_received.foo(1)
subject.should have_received.bar # this fails
~~~

### Block Syntax

The block syntax has two modes

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

### Block Syntax with explicit DoubleDefinitionCreatorProxy argument


### Double Graphs

RR has a method-chaining API support for double graphs. For example, let's say
you want an object to receive a method call to #foo, and have the return value
receive a method call to #bar.

In RR, you would do:

~~~ ruby
stub(object).foo.stub!.bar {:baz}
object.foo.bar # :baz
# or
stub(object).foo {stub!.bar {:baz}}
object.foo.bar # :baz
# or
bar = stub!.bar {:baz}
stub(object).foo {bar}
object.foo.bar # :baz
~~~

### Argument Wildcard matchers

#### anything

~~~ ruby
mock(object).foobar(1, anything)
object.foobar(1, :my_symbol)
~~~

#### is_a

~~~ ruby
mock(object).foobar(is_a(Time))
object.foobar(Time.now)
~~~

#### numeric

~~~ ruby
mock(object).foobar(numeric)
object.foobar(99)
~~~~

#### boolean

~~~ ruby
mock(object).foobar(boolean)
object.foobar(false)
~~~

#### duck_type

~~~ ruby
mock(object).foobar(duck_type(:walk, :talk))
arg = Object.new
def arg.walk; 'waddle'; end
def arg.talk; 'quack'; end
object.foobar(arg)
~~~

#### Ranges

~~~ ruby
mock(object).foobar(1..10)
object.foobar(5)
~~~

#### Regexps

~~~ ruby
mock(object).foobar(/on/)
object.foobar("ruby on rails")
~~~

#### hash_including

~~~ ruby
mock(object).foobar(hash_including(:red => "#FF0000", :blue => "#0000FF"))
object.foobar({:red => "#FF0000", :blue => "#0000FF", :green => "#00FF00"})
~~~

#### satisfy

~~~ ruby
mock(object).foobar(satisfy {|arg| arg.length == 2})
object.foobar("xy")
~~~

#### Writing your own Argument Matchers

Writing a custom argument wildcard matcher is not difficult.  See
RR::WildcardMatchers for details.

### Invocation Amount Wildcard Matchers

#### any_times

~~~ ruby
mock(object).method_name(anything).times(any_times) {return_value}
~~~


## Special Thanks To

With any development effort, there are countless people who have contributed to
making it possible. We all are standing on the shoulders of giants. If you have
directly contributed to RR and I missed you in this list, please let me know and
I will add you. Thanks!

* Andreas Haller for patches
* Aslak Hellesoy for Developing Rspec
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
* Steven Baker for Developing Rspec
* Tatsuya Ono for patches
* Tuomas Kareinen for a bug report
