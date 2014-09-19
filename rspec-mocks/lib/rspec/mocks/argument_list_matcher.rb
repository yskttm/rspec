# We intentionally do not use the `RSpec::Support.require...` methods
# here so that this file can be loaded individually, as documented
# below.
require 'rspec/mocks/argument_matchers'
require 'rspec/support/fuzzy_matcher'

module RSpec
  module Mocks
    # Wrapper for matching arguments against a list of expected values. Used by
    # the `with` method on a `MessageExpectation`:
    #
    #     expect(object).to receive(:message).with(:a, 'b', 3)
    #     object.message(:a, 'b', 3)
    #
    # Values passed to `with` can be literal values or argument matchers that
    # match against the real objects .e.g.
    #
    #     expect(object).to receive(:message).with(hash_including(:a => 'b'))
    #
    # Can also be used directly to match the contents of any `Array`. This
    # enables 3rd party mocking libs to take advantage of rspec's argument
    # matching without using the rest of rspec-mocks.
    #
    #     require 'rspec/mocks/argument_list_matcher'
    #     include RSpec::Mocks::ArgumentMatchers
    #
    #     arg_list_matcher = RSpec::Mocks::ArgumentListMatcher.new(123, hash_including(:a => 'b'))
    #     arg_list_matcher.args_match?(123, :a => 'b')
    #
    # This class is immutable.
    #
    # @see ArgumentMatchers
    class ArgumentListMatcher
      # @private
      attr_reader :expected_args

      # @api public
      # @param [Array] expected_args a list of expected literals and/or argument matchers
      #
      # Initializes an `ArgumentListMatcher` with a collection of literal
      # values and/or argument matchers.
      #
      # @see ArgumentMatchers
      # @see #args_match?
      def initialize(*expected_args)
        @expected_args = expected_args
      end

      # @api public
      # @param [Array] args
      #
      # Matches each element in the `expected_args` against the element in the same
      # position of the arguments passed to `new`.
      #
      # @see #initialize
      def args_match?(*args)
        Support::FuzzyMatcher.values_match?(matchers_for(args), args)
      end

      # Value that will match all argument lists.
      #
      # @private
      MATCH_ALL = new(ArgumentMatchers::AnyArgsMatcher.new)

      # Singleton instance of AnyArgMatcher to save on memory.
      # It's immutable and thus safe to re-use many times.
      # @private
      ANYTHING  = ArgumentMatchers::AnyArgMatcher.new

    private

      def matchers_for(actual_args)
        return [] if expected_args.one? && ArgumentMatchers::NoArgsMatcher === expected_args.first

        any_args_index = expected_args.index { |arg| ArgumentMatchers::AnyArgsMatcher === arg }
        return expected_args unless any_args_index

        replace_any_args_with_splat_of_anything(any_args_index, actual_args.count)
      end

      def replace_any_args_with_splat_of_anything(before_count, actual_args_count)
        any_args_count  = actual_args_count   - expected_args.count + 1
        after_count     = expected_args.count - before_count        - 1

        any_args = 1.upto(any_args_count).map { ANYTHING }
        expected_args.first(before_count) + any_args + expected_args.last(after_count)
      end
    end
  end
end
