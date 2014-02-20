Feature: define diffable matcher

  When a matcher is defined as diffable, the output will
  include a diff of the submitted objects when the objects
  are more than simple primitives.

  Scenario: define a diffable matcher
    Given a file named "diffable_matcher_spec.rb" with:
      """ruby
      RSpec::Matchers.define :be_just_like do |expected|
        match do |actual|
          actual == expected
        end

        diffable
      end

      describe "two\nlines" do
        it { should be_just_like("three\nlines") }
      end
      """
    When I run `rspec ./diffable_matcher_spec.rb`
    Then it should fail with:
      """
             expected "two\nlines" to be just like "three\nlines"
             Diff:
             @@ -1,3 +1,3 @@
             -three
             +two
              lines
      """
