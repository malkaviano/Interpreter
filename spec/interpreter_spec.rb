require 'interpreter'

describe Interpreter do
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
      let(:expected) { [[ "NotExpression", "true", "AndExpression", "false" ]] }

      it_behaves_like "tokenizing an expression", [ "not true and false" ]
    end

    context 'when [ "not true and not false" ] is tokenized' do
      let(:expected) { [[ "NotExpression", "true", "AndExpression", "NotExpression", "false" ]] }

      it_behaves_like "tokenizing an expression", [ "not true and not false" ]
    end

    context 'when [ "true or false", "not @0" ] is tokenized' do
      let(:expected) { [[ "true", "OrExpression", "false" ], [ "NotExpression", "@0" ]] }

      it_behaves_like "tokenizing an expression", [ "true or false", "not @0" ]
    end

    context 'when [ "true or false", "false or true", "not @1", "not @0 and @2" ] is tokenized' do
      let(:expected) { [[ "true", "OrExpression", "false" ], [ "false", "OrExpression" ,"true" ], [ "NotExpression",  "@1" ], [ "NotExpression",  "@0", "AndExpression", "@2" ]] }

      it_behaves_like "tokenizing an expression", [ "true or false", "false or true", "not @1", "not @0 and @2" ]
    end
  end

  describe "#classify" do
    shared_examples "classifying tokens" do |tokens|
      it 'returns Array with classified tokens' do
        expect(described_class.classify tokens).to eq expected
      end
    end

    context 'when [[ "NotExpression", "true", "AndExpression", "false" ]] is classifed' do
      let(:expected) { [ "Literal:true", NotExpression, "Literal:false", AndExpression ] }

      it_behaves_like "classifying tokens", [[ "NotExpression", "true", "AndExpression", "false" ]]
    end

    context 'when [[ "true", "AndExpression", "NotExpression", "false" ]] is classifed' do
      let(:expected) { [ "Literal:true", "Literal:false", NotExpression, AndExpression ] }

      it_behaves_like "classifying tokens", [[ "true", "AndExpression", "NotExpression", "false" ]]
    end

    context 'when [[ "false", "OrExpression", "NotExpression", "true", "AndExpression", "true" ]] is classifed' do
      let(:expected) { [ "Literal:false", "Literal:true", NotExpression, OrExpression, "Literal:true", AndExpression ] }

      it_behaves_like "classifying tokens", [[ "false", "OrExpression", "NotExpression", "true", "AndExpression", "true" ]]
    end

    context 'when [[ "NotExpression", "NotExpression", "false" ]] is classifed' do
      let(:expected) { [ "Literal:false", NotExpression, NotExpression ] }

      it_behaves_like "classifying tokens", [[ "NotExpression", "NotExpression", "false" ]]
    end

    context 'when [[ "true", "OrExpression", "false" ], [ "NotExpression", "@0" ]] is classifed' do
      let(:expected) { [ "Literal:true", "Literal:false", OrExpression, NotExpression ] }

      it_behaves_like "classifying tokens", [[ "true", "OrExpression", "false" ], [ "NotExpression", "@0" ]]
    end
  end

  describe "#build_expression" do
    context 'when [ "Literal:false", "Literal:true", NotExpression, OrExpression, "Literal:true", AndExpression ] is passed' do
      let(:input) { [ "Literal:false", "Literal:true", NotExpression, OrExpression, "Literal:true", AndExpression ] }
      let(:expected) { AndExpression }
      it 'returns NotExpression' do
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
