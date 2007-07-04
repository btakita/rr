#require "spec/mocks"
#
#module Spec
#  module Plugins
#    module MockFramework
#      include Spec::Mocks::SpecMethods
#      def setup_mocks_for_rspec
#        $rspec_mocks ||= Spec::Mocks::Space.new
#      end
#      def verify_mocks_for_rspec
#        $rspec_mocks.verify_all
#      end
#      def teardown_mocks_for_rspec
#        $rspec_mocks.reset_all
#      end
#    end
#  end
#end
