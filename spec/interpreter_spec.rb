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
      let(:expected) { [[ "Malk::NotExpression", "true", "Malk::AndExpression", "false" ]] }

      it_behaves_like "tokenizing an expression", [ "not true and false" ]
    end

    context 'when [ "not true and not false" ] is tokenized' do
      let(:expected) { [[ "Malk::NotExpression", "true", "Malk::AndExpression", "Malk::NotExpression", "false" ]] }

      it_behaves_like "tokenizing an expression", [ "not true and not false" ]
    end

    context 'when [ "true or false", "not @0" ] is tokenized' do
      let(:expected) { [[ "true", "Malk::OrExpression", "false" ], [ "Malk::NotExpression", "@0" ]] }

      it_behaves_like "tokenizing an expression", [ "true or false", "not @0" ]
    end

    context 'when [ "true or false", "false or true", "not @1", "not @0 and @2" ] is tokenized' do
      let(:expected) { [[ "true", "Malk::OrExpression", "false" ], [ "false", "Malk::OrExpression" ,"true" ], [ "Malk::NotExpression",  "@1" ], [ "Malk::NotExpression",  "@0", "Malk::AndExpression", "@2" ]] }

      it_behaves_like "tokenizing an expression", [ "true or false", "false or true", "not @1", "not @0 and @2" ]
    end
  end

  describe "#classify" do
    shared_examples "classifying tokens" do |tokens|
      it 'returns Array with classified tokens' do
        expect(described_class.classify tokens).to eq expected
      end
    end

    context 'when [[ "Malk::NotExpression", "true", "Malk::AndExpression", "false" ]] is classifed' do
      let(:expected) { [ "Literal:true", Malk::NotExpression, "Literal:false", Malk::AndExpression ] }

      it_behaves_like "classifying tokens", [[ "Malk::NotExpression", "true", "Malk::AndExpression", "false" ]]
    end

    context 'when [[ "true", "Malk::AndExpression", "Malk::NotExpression", "false" ]] is classifed' do
      let(:expected) { [ "Literal:true", "Literal:false", Malk::NotExpression, Malk::AndExpression ] }

      it_behaves_like "classifying tokens", [[ "true", "Malk::AndExpression", "Malk::NotExpression", "false" ]]
    end

    context 'when [[ "false", "Malk::OrExpression", "Malk::NotExpression", "true", "Malk::AndExpression", "true" ]] is classifed' do
      let(:expected) { [ "Literal:false", "Literal:true", Malk::NotExpression, Malk::OrExpression, "Literal:true", Malk::AndExpression ] }

      it_behaves_like "classifying tokens", [[ "false", "Malk::OrExpression", "Malk::NotExpression", "true", "Malk::AndExpression", "true" ]]
    end

    context 'when [[ "Malk::NotExpression", "Malk::NotExpression", "false" ]] is classifed' do
      let(:expected) { [ "Literal:false", Malk::NotExpression, Malk::NotExpression ] }

      it_behaves_like "classifying tokens", [[ "Malk::NotExpression", "Malk::NotExpression", "false" ]]
    end

    context 'when [[ "true", "Malk::OrExpression", "false" ], [ "Malk::NotExpression", "@0" ]] is classifed' do
      let(:expected) { [ "Literal:true", "Literal:false", Malk::OrExpression, Malk::NotExpression ] }

      it_behaves_like "classifying tokens", [[ "true", "Malk::OrExpression", "false" ], [ "Malk::NotExpression", "@0" ]]
    end
  end

  describe "#build_expression" do
    context 'when [ "Literal:false", "Literal:true", Malk::NotExpression, Malk::OrExpression, "Literal:true", Malk::AndExpression ] is passed' do
      let(:input) { [ "Literal:false", "Literal:true", Malk::NotExpression, Malk::OrExpression, "Literal:true", Malk::AndExpression ] }
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
