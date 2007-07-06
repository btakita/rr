dir = File.dirname(__FILE__)

require "rr/double"
require "rr/mock_creator"
require "rr/stub_creator"
require "rr/probe_creator"
require "rr/scenario"
require "rr/space"

require "rr/scenario_not_found_error"
require "rr/scenario_order_error"

require "rr/expectations/argument_equality_expectation"
require "rr/expectations/any_argument_expectation"
require "rr/expectations/times_called_expectation"
require "rr/expectations/wildcard_matchers/anything"
require "rr/expectations/wildcard_matchers/is_a"
require "rr/expectations/wildcard_matchers/numeric"

require "rr/extensions/double_methods"
