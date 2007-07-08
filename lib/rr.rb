dir = File.dirname(__FILE__)

require "rr/double"

require "rr/mock_creator"
require "rr/stub_creator"
require "rr/probe_creator"
require "rr/do_not_allow_creator"

require "rr/scenario"
require "rr/space"

require "rr/errors/rr_error"
require "rr/errors/scenario_not_found_error"
require "rr/errors/scenario_order_error"
require "rr/errors/argument_equality_error"

require "rr/expectations/argument_equality_expectation"
require "rr/expectations/any_argument_expectation"
require "rr/expectations/times_called_expectation"
require "rr/expectations/wildcard_matchers/anything"
require "rr/expectations/wildcard_matchers/is_a"
require "rr/expectations/wildcard_matchers/numeric"
require "rr/expectations/wildcard_matchers/boolean"
require "rr/expectations/wildcard_matchers/duck_type"
require "rr/expectations/wildcard_matchers/regexp"
require "rr/expectations/wildcard_matchers/range"

require "rr/extensions/double_methods"
