require 'interpreter'

describe Malk::Interpreter do
  let(:interpreter) { Malk::Interpreter.new }

  describe "#parse" do
    shared_examples "parsing an expression" do |expr, expected|
      context "with '#{expr}'" do
        it "returns #{expected}" do
          expect(interpreter.parse expr).to eq expected
        end
      end
    end

    expressions = {
      "not true and false" => [ "not true and false" ],
      "not (true or false)" => [ "true or false", "not @0" ],
      "not (true or false) and (not (false or true))" => [ "true or false", "false or true", "not @1", "not @0 and @2" ],
      "$a and $xpto" => [ "$a and $xpto" ],
      "$a and ($xpto or $b)" => [ "$xpto or $b", "$a and @0" ]
    }

    expressions.each { |k, v| it_behaves_like "parsing an expression", k, v }
  end

  describe "#tokenize" do
    shared_examples "tokenizing an expression" do |expr, expected|
      context "with #{expr}" do
        it "returns #{expected}" do
          expect(interpreter.tokenize expr).to eq expected
        end
      end
    end

    expressions = {
      [ "not true and false" ] =>
        [
          [ Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, [ Malk::Literal, false ]]
        ],
      [ "not true and not false" ] =>
        [
          [ Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, Malk::NotOperator, [ Malk::Literal, false ]]
        ],
      [ "true or false", "not @0" ] =>
        [
          [[ Malk::Literal, true ], Malk::OrOperator, [ Malk::Literal, false ]],
          [ Malk::NotOperator, "@0" ]
        ],
      [ "true or false", "false or true", "not @1", "not @0 and @2" ] =>
        [
          [[ Malk::Literal, true ], Malk::OrOperator, [ Malk::Literal, false ]],
          [[ Malk::Literal, false ], Malk::OrOperator, [ Malk::Literal, true ]],
          [ Malk::NotOperator,  "@1" ],
          [ Malk::NotOperator,  "@0", Malk::AndOperator, "@2" ]
        ],
      [ "$a and $xpto" ] =>
        [
          [[ Malk::Variable, "$a" ], Malk::AndOperator, [ Malk::Variable, "$xpto" ]]
        ],
      [ "$xpto or $b", "$a and @0" ] =>
        [
          [[ Malk::Variable, "$xpto" ], Malk::OrOperator, [ Malk::Variable, "$b" ]],
          [[ Malk::Variable, "$a" ], Malk::AndOperator, "@0" ]
        ]
    }

    expressions.each  { |k, v| it_behaves_like "tokenizing an expression", k, v }

  end

  describe "#build_token_queue" do
    shared_examples "building token queue" do |tokens, expected|
      context "with #{tokens}" do
        it "returns #{expected}" do
          expect(interpreter.build_token_queue tokens).to eq expected
        end
      end
    end

    tokens = {
      [[ Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, [ Malk::Literal, false ]]] =>
        [[ Malk::Literal, true ], Malk::NotOperator, [ Malk::Literal, false ], Malk::AndOperator ],
      [[[ Malk::Literal, true ], Malk::AndOperator, Malk::NotOperator, [ Malk::Literal, false ]]] =>
        [[ Malk::Literal, true ], [ Malk::Literal, false ], Malk::NotOperator, Malk::AndOperator ],
      [[[ Malk::Literal, false ], Malk::OrOperator, Malk::NotOperator, [ Malk::Literal, true ], Malk::AndOperator, [ Malk::Literal, true ]]] =>
        [[ Malk::Literal, false ], [ Malk::Literal, true ], Malk::NotOperator, Malk::OrOperator, [ Malk::Literal, true ], Malk::AndOperator ],
      [[ Malk::NotOperator, Malk::NotOperator, [ Malk::Literal, false ]]] =>
       [[ Malk::Literal, false ], Malk::NotOperator, Malk::NotOperator ],
      [[[ Malk::Literal, true ], Malk::OrOperator, [ Malk::Literal, false ]], [ Malk::NotOperator, "@0" ]] =>
        [[ Malk::Literal, true ], [ Malk::Literal, false ], Malk::OrOperator, Malk::NotOperator ],
      [[[ Malk::Variable, "$a" ], Malk::AndOperator, [ Malk::Variable, "$xpto" ]]] =>
        [[ Malk::Variable, "$a" ], [ Malk::Variable, "$xpto" ], Malk::AndOperator ],
      [[[ Malk::Variable, "$xpto" ], Malk::OrOperator, [ Malk::Variable, "$b" ]], [[ Malk::Variable, "$a" ], Malk::AndOperator, "@0" ]] =>
        [[ Malk::Variable, "$xpto" ], [ Malk::Variable, "$b" ], Malk::OrOperator, [ Malk::Variable, "$a" ], Malk::AndOperator ]
    }

    tokens.each { |k, v| it_behaves_like "building token queue", k, v }
  end

  describe "#interpret" do
    shared_examples "interpreting an expression" do |expr, expected|
      context "with expression #{expr}" do
        it "returns #{expected}" do
          expect(interpreter.interpret(expr)).to be expected
        end
      end
    end

    expressions = {
      "false nand false" => true,
      "false nand true" => true,
      "true nand true" => false,
      "false nor false" => true,
      "false nor true" => false,
      "true nor true" => false,
      "false xor false" => false,
      "false xor true" => true,
      "true xor true" => false,
      "not false and not false" => true,
      "not false or not false" => true,
      "not false and false" => false,
      "not (false and false)" => true
    }

    expressions.each { |k, v| it_behaves_like "interpreting an expression", k, v }

    context "with context { a: true, b: false }" do
      let(:interpreter) { Malk::Interpreter.new({ a: true, b: false }) }

      expressions = {
        "$a and $b" => false,
        "$a or $b" => true
      }

      expressions.each { |k, v| it_behaves_like "interpreting an expression", k, v }
    end
  end
end
