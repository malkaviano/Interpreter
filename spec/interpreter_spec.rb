require 'interpreter'

describe Interpreter do
  describe "#tokenize" do
    shared_examples "tokenizing an expression" do |expr|
      it 'returns Array with tokens' do
        expect(described_class.tokenize expr).to eq expected
      end
    end

    context "when 'not true and false' is tokenized" do
      let(:expected) { ["NotExpression", "true", "AndExpression", "false"] }

      it_behaves_like "tokenizing an expression", "not true and false"
    end

    context "when 'not true and not false' is tokenized" do
      let(:expected) { ["NotExpression", "true", "AndExpression", "NotExpression", "false"] }

      it_behaves_like "tokenizing an expression", "not true and not false"
    end
  end

  describe "#classify_tokens" do
    shared_examples "classifying tokens" do |tokens|
      it 'returns Array with classified tokens' do
        expect(described_class.classify_tokens tokens).to eq expected
      end
    end

    context 'when [ "NotExpression", "true", "AndExpression", "false" ] is classifed' do
      let(:expected) { [ "Literal:true", NotExpression, "Literal:false", AndExpression ] }

      it_behaves_like "classifying tokens", [ "NotExpression", "true", "AndExpression", "false" ]
    end

    context 'when [ "true", "AndExpression", "NotExpression", "false" ] is classifed' do
      let(:expected) { [ "Literal:true", "Literal:false", NotExpression, AndExpression ] }

      it_behaves_like "classifying tokens", [ "true", "AndExpression", "NotExpression", "false" ]
    end

    context 'when [ "false", "OrExpression", "NotExpression", "true", "AndExpression", "true" ] is classifed' do
      let(:expected) { [ "Literal:false", "Literal:true", NotExpression, OrExpression, "Literal:true", AndExpression ] }

      it_behaves_like "classifying tokens", [ "false", "OrExpression", "NotExpression", "true", "AndExpression", "true" ]
    end

    context 'when [ "NotExpression", "NotExpression", "false" ] is classifed' do
      let(:expected) { [ "Literal:false", NotExpression, NotExpression ] }

      it_behaves_like "classifying tokens", [ "NotExpression", "NotExpression", "false" ]
    end
  end
end
