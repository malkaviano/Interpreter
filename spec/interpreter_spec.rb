require 'interpreter'

describe Malk::Interpreter do
  describe "#parse" do
    shared_examples "parsing an expression" do |expr|
      it 'returns Array with parsed expressions' do
        expect(described_class.parse expr).to eq expected
      end
    end

    context 'when "not true and false" is tokenized' do
      let(:expected) { [ "not true and false" ] }

      it_behaves_like "parsing an expression", "not true and false"
    end

    context 'when "not (true or false)" is tokenized' do
      let(:expected) { [ "true or false", "not @0" ] }

      it_behaves_like "parsing an expression", "not (true or false)"
    end

    context 'when "not (true or false) and (not (false or true))" is tokenized' do
      let(:expected) { [ "true or false", "false or true", "not @1", "not @0 and @2" ] }

      it_behaves_like "parsing an expression", "not (true or false) and (not (false or true))"
    end
  end

  describe "#tokenize" do
    shared_examples "tokenizing an expression" do |expr|
      it 'returns Array with tokens' do
        expect(described_class.tokenize expr).to eq expected
      end
    end

    context 'when [ "not true and false" ] is tokenized' do
      let(:expected) { [[ "Malk::NotExpression", "Malk::Boolean%true", "Malk::AndExpression", "Malk::Boolean%false" ]] }

      it_behaves_like "tokenizing an expression", [ "not true and false" ]
    end

    context 'when [ "not true and not false" ] is tokenized' do
      let(:expected) { [[ "Malk::NotExpression", "Malk::Boolean%true", "Malk::AndExpression", "Malk::NotExpression", "Malk::Boolean%false" ]] }

      it_behaves_like "tokenizing an expression", [ "not true and not false" ]
    end

    context 'when [ "true or false", "not @0" ] is tokenized' do
      let(:expected) { [[ "Malk::Boolean%true", "Malk::OrExpression", "Malk::Boolean%false" ], [ "Malk::NotExpression", "@0" ]] }

      it_behaves_like "tokenizing an expression", [ "true or false", "not @0" ]
    end

    context 'when [ "true or false", "false or true", "not @1", "not @0 and @2" ] is tokenized' do
      let(:expected) { [[ "Malk::Boolean%true", "Malk::OrExpression", "Malk::Boolean%false" ], [ "Malk::Boolean%false", "Malk::OrExpression" ,"Malk::Boolean%true" ], [ "Malk::NotExpression",  "@1" ], [ "Malk::NotExpression",  "@0", "Malk::AndExpression", "@2" ]] }

      it_behaves_like "tokenizing an expression", [ "true or false", "false or true", "not @1", "not @0 and @2" ]
    end
  end

  describe "#classify" do
    shared_examples "classifying tokens" do |tokens|
      it 'returns Array with classified tokens' do
        expect(described_class.classify tokens).to eq expected
      end
    end

    context 'when [[ "Malk::NotExpression", "Malk::Boolean%true", "Malk::AndExpression", "Malk::Boolean%false" ]] is classifed' do
      let(:expected) { [ "Malk::Boolean%true", Malk::NotExpression, "Malk::Boolean%false", Malk::AndExpression ] }

      it_behaves_like "classifying tokens", [[ "Malk::NotExpression", "Malk::Boolean%true", "Malk::AndExpression", "Malk::Boolean%false" ]]
    end

    context 'when [[ "Malk::Boolean%true", "Malk::AndExpression", "Malk::NotExpression", "Malk::Boolean%false" ]] is classifed' do
      let(:expected) { [ "Malk::Boolean%true", "Malk::Boolean%false", Malk::NotExpression, Malk::AndExpression ] }

      it_behaves_like "classifying tokens", [[ "Malk::Boolean%true", "Malk::AndExpression", "Malk::NotExpression", "Malk::Boolean%false" ]]
    end

    context 'when [[ "Malk::Boolean%false", "Malk::OrExpression", "Malk::NotExpression", "Malk::Boolean%true", "Malk::AndExpression", "Malk::Boolean%true" ]] is classifed' do
      let(:expected) { [ "Malk::Boolean%false", "Malk::Boolean%true", Malk::NotExpression, Malk::OrExpression, "Malk::Boolean%true", Malk::AndExpression ] }

      it_behaves_like "classifying tokens", [[ "Malk::Boolean%false", "Malk::OrExpression", "Malk::NotExpression", "Malk::Boolean%true", "Malk::AndExpression", "Malk::Boolean%true" ]]
    end

    context 'when [[ "Malk::NotExpression", "Malk::NotExpression", "Malk::Boolean%false" ]] is classifed' do
      let(:expected) { [ "Malk::Boolean%false", Malk::NotExpression, Malk::NotExpression ] }

      it_behaves_like "classifying tokens", [[ "Malk::NotExpression", "Malk::NotExpression", "Malk::Boolean%false" ]]
    end

    context 'when [[ "Malk::Boolean%true", "Malk::OrExpression", "Malk::Boolean%false" ], [ "Malk::NotExpression", "@0" ]] is classifed' do
      let(:expected) { [ "Malk::Boolean%true", "Malk::Boolean%false", Malk::OrExpression, Malk::NotExpression ] }

      it_behaves_like "classifying tokens", [[ "Malk::Boolean%true", "Malk::OrExpression", "Malk::Boolean%false" ], [ "Malk::NotExpression", "@0" ]]
    end
  end

  describe "#build_expression" do
    context 'when [ "Malk::Boolean%false", "Malk::Boolean%true", Malk::NotExpression, Malk::OrExpression, "Malk::Boolean%true", Malk::AndExpression ] is passed' do
      let(:input) { [ "Malk::Boolean%false", "Malk::Boolean%true", Malk::NotExpression, Malk::OrExpression, "Malk::Boolean%true", Malk::AndExpression ] }
      let(:expected) { Malk::AndExpression }
      it 'returns Malk::NotExpression' do
        expect(described_class.build_expression(input).class).to be expected
      end
    end
  end

  describe "#interpret" do
    shared_examples "interpreting an expression" do |expected|
      it 'returns #expected' do
        expect(described_class.interpret(input)).to be expected
      end
    end

    context 'when expression "false or not true and true"' do
      let(:input) { "false or not true and true" }

      it_behaves_like "interpreting an expression", false
    end

    context 'when expression "not (true or false) and (not (false or true))"' do
      let(:input) { "not (true or false) or (not (false and true))" }

      it_behaves_like "interpreting an expression", true
    end
  end
end
