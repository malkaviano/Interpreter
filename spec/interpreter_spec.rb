require 'interpreter'

describe Malk::Interpreter do
  describe "#parse" do
    shared_examples "parsing an expression" do |expr, expected|
      it 'returns Array with parsed expressions' do
        expect(subject.parse expr).to eq expected
      end
    end

    expressions = [
      "not true and false",
      "not (true or false)",
      "not (true or false) and (not (false or true))",
      "$a and $xpto",
      "$a and ($xpto or $b)"
    ]

    expectations = [
      [ "not true and false" ],
      [ "true or false", "not @0" ],
      [ "true or false", "false or true", "not @1", "not @0 and @2" ],
      [ "$a and $xpto" ],
      [ "$xpto or $b", "$a and @0" ]
    ]

    expressions.size.times { |i| it_behaves_like "parsing an expression", expressions[i], expectations[i] }
  end

  describe "#tokenize" do
    shared_examples "tokenizing an expression" do |expr, expected|
      it 'returns Array with tokens' do
        expect(subject.tokenize expr).to eq expected
      end
    end

    expressions = [
      [ "not true and false" ],
      [ "not true and not false" ],
      [ "true or false", "not @0" ],
      [ "true or false", "false or true", "not @1", "not @0 and @2" ],
      [ "$a and $xpto" ],
      [ "$xpto or $b", "$a and @0" ]
    ]

    expectations = [
      [[ Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, [ Malk::Literal, false ] ]],
      [[ Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, Malk::NotOperator, [ Malk::Literal, false ] ]],
      [[ [ Malk::Literal, true ], Malk::OrOperator, [ Malk::Literal, false ] ], [ Malk::NotOperator, "@0" ]],
      [[ [ Malk::Literal, true ], Malk::OrOperator, [ Malk::Literal, false ] ], [ [ Malk::Literal, false ], Malk::OrOperator, [ Malk::Literal, true ] ], [ Malk::NotOperator,  "@1" ], [ Malk::NotOperator,  "@0", Malk::AndOperator, "@2" ]],
      [[[ Malk::Variable, "$a" ], Malk::AndOperator, [ Malk::Variable, "$xpto" ]]],
      [[[ Malk::Variable, "$xpto" ], Malk::OrOperator, [ Malk::Variable, "$b" ]], [[ Malk::Variable, "$a" ], Malk::AndOperator, "@0" ]]
    ]

    expressions.size.times  { |i| it_behaves_like "tokenizing an expression", expressions[i], expectations[i] }

  end

  describe "#build_token_queue" do
    shared_examples "building token queue" do |tokens, expected|
      it 'returns Array with classified tokens' do
        expect(subject.build_token_queue tokens).to eq expected
      end
    end

    tokens = [
      [[ Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, [ Malk::Literal, false ] ]],
      [[ [ Malk::Literal, true ], Malk::AndOperator, Malk::NotOperator, [ Malk::Literal, false ] ]],
      [[ [ Malk::Literal, false ], Malk::OrOperator, Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, [ Malk::Literal, true ] ]],
      [[ Malk::NotOperator, Malk::NotOperator, [ Malk::Literal, false ] ]],
      [[ [ Malk::Literal, true ], Malk::OrOperator, [ Malk::Literal, false ] ], [ Malk::NotOperator, "@0" ]],
      [[[ Malk::Variable, "$a" ], Malk::AndOperator, [ Malk::Variable, "$xpto" ]]],
      [[[ Malk::Variable, "$xpto" ], Malk::OrOperator, [ Malk::Variable, "$b" ]], [[ Malk::Variable, "$a" ], Malk::AndOperator, "@0" ]]
    ]

    expectations = [
      [ [ Malk::Literal, true ], Malk::NotOperator, [ Malk::Literal, false ], Malk::AndOperator ],
      [ [ Malk::Literal, true ], [ Malk::Literal, false ], Malk::NotOperator, Malk::AndOperator ],
      [ [ Malk::Literal, false ], [ Malk::Literal, true ], Malk::NotOperator, Malk::OrOperator, [ Malk::Literal, true ], Malk::AndOperator ],
      [ [ Malk::Literal, false ], Malk::NotOperator, Malk::NotOperator ],
      [ [ Malk::Literal, true ], [ Malk::Literal, false ], Malk::OrOperator, Malk::NotOperator ],
      [[ Malk::Variable, "$a" ], [ Malk::Variable, "$xpto" ], Malk::AndOperator ],
      [[ Malk::Variable, "$xpto" ], [ Malk::Variable, "$b" ], Malk::OrOperator, [ Malk::Variable, "$a" ], Malk::AndOperator ]
    ]

    tokens.size.times { |i| it_behaves_like "building token queue", tokens[i], expectations[i] }
  end

  describe "#build_expression" do
    let(:input) { [ [ Malk::Literal, false ], [ Malk::Literal, true ], Malk::NotOperator, Malk::OrOperator, [ Malk::Literal, true ], Malk::AndOperator ] }
    let(:expected) { Malk::AndOperator }

    it 'returns Malk::NotOperator' do
      expect(subject.build_expression(input).class).to be expected
    end
  end

  describe "#interpret" do
    shared_examples "interpreting an expression" do |expected|
      it 'returns #expected' do
        expect(subject.interpret(input)).to be expected
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
