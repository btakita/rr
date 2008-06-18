dir = File.dirname(__FILE__)
require "#{dir}/rr/errors/rr_error"
require "#{dir}/rr/errors/double_definition_error"
require "#{dir}/rr/errors/double_not_found_error"
require "#{dir}/rr/errors/double_order_error"
require "#{dir}/rr/errors/argument_equality_error"
require "#{dir}/rr/errors/times_called_error"

require "#{dir}/rr/space"
require "#{dir}/rr/double_injection"
require "#{dir}/rr/hash_with_object_id_key"

require "#{dir}/rr/double_definition_creator_proxy"

require "#{dir}/rr/double_definition_creator"

require "#{dir}/rr/double"
require "#{dir}/rr/double_definition"
require "#{dir}/rr/double_definition_builder"
require "#{dir}/rr/double_matches"

require "#{dir}/rr/expectations/argument_equality_expectation"
require "#{dir}/rr/expectations/any_argument_expectation"
require "#{dir}/rr/expectations/times_called_expectation"

require "#{dir}/rr/wildcard_matchers/anything"
require "#{dir}/rr/wildcard_matchers/is_a"
require "#{dir}/rr/wildcard_matchers/numeric"
require "#{dir}/rr/wildcard_matchers/boolean"
require "#{dir}/rr/wildcard_matchers/duck_type"
require "#{dir}/rr/wildcard_matchers/regexp"
require "#{dir}/rr/wildcard_matchers/range"

require "#{dir}/rr/times_called_matchers/terminal"
require "#{dir}/rr/times_called_matchers/non_terminal"
require "#{dir}/rr/times_called_matchers/times_called_matcher"
require "#{dir}/rr/times_called_matchers/any_times_matcher"
require "#{dir}/rr/times_called_matchers/integer_matcher"
require "#{dir}/rr/times_called_matchers/range_matcher"
require "#{dir}/rr/times_called_matchers/proc_matcher"
require "#{dir}/rr/times_called_matchers/at_least_matcher"
require "#{dir}/rr/times_called_matchers/at_most_matcher"

require "#{dir}/rr/adapters/rr_methods"

require "#{dir}/rr/adapters/rspec"
require "#{dir}/rr/adapters/test_unit"

module RR
  class << self
    def method_missing(method_name, *args, &block)
      RR::Space.instance.__send__(method_name, *args, &block)
    end
  end  
end
