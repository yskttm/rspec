# frozen_string_literal: true

require 'rspec/support/source/token'

class RSpec::Support::Source
  RSpec.describe Token, :if => RSpec::Support::RubyFeatures.ripper_supported? do
    let(:target_token) do
      tokens.first
    end

    let(:tokens) do
      Token.tokens_from_ripper_tokens(ripper_tokens)
    end

    let(:ripper_tokens) do
      require 'ripper'
      Ripper.lex(source)
    end

    let(:source) do
      'puts :foo'
    end

    # [
    #   [[1, 0], :on_ident, "puts"],
    #   [[1, 4], :on_sp, " "],
    #   [[1, 5], :on_symbeg, ":"],
    #   [[1, 6], :on_ident, "foo"]
    # ]

    describe "#closed_by" do
      context "with a normal ruby multi line method" do
        let(:source) { "def foo\n  :bar\nend" }

        specify 'the first token is closed by the last' do
          expect(tokens.first).to be_closed_by(tokens.last)
        end
      end

      context "with a ruby one line method definition" do
        let(:source) { 'def self.foo = "bar"' }

        specify 'the first token is closed by the =' do
          expect(tokens.first).to be_closed_by(tokens[6])
        end
      end
    end

    describe '#location' do
      it 'returns a Location object with line and column numbers' do
        expect(target_token.location).to have_attributes(:line => 1, :column => 0)
      end
    end

    describe '#type' do
      it 'returns a type of the token' do
        expect(target_token.type).to eq(:on_ident)
      end
    end

    describe '#string' do
      it 'returns a source string corresponding to the token' do
        expect(target_token.string).to eq('puts')
      end
    end

    describe '#==' do
      context 'when both tokens have same Ripper token' do
        it 'returns true' do
          expect(Token.new(ripper_tokens[0]) == Token.new(ripper_tokens[0])).to be true
        end
      end

      context 'when both tokens have different Ripper token' do
        it 'returns false' do
          expect(Token.new(ripper_tokens[0]) == Token.new(ripper_tokens[1])).to be false
        end
      end
    end

    describe '#inspect' do
      it 'returns a string including class name, token type and source string' do
        expect(target_token.inspect).to eq('#<RSpec::Support::Source::Token on_ident "puts">')
      end
    end
  end
end
