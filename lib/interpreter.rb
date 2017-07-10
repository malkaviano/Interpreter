require_relative 'expressions'

class Interpreter
  def self.build_expression(expr)
    tokens = tokenize(expr)

    classified_tokens = classify_tokens(tokens)
=begin
p expressions
p values
=end
    build_tree(classified_tokens)
  end

  def self.build_tree(classified_tokens)
    values = []

    classified_tokens.each do |token|
      if token.class == String
        values << Literal.new(token.gsub("Literal:", ""))
      else
        args = []

        token.arguments.times {|_| args << values.pop }

        values << token.new(args.reverse)
      end
    end

    values
  end

  def self.classify_tokens(tokens)
    expressions = []
    nextOp = []
    literals = 0

    tokens.each do |token|
      if !(token.include? "Expression")
        expressions << "Literal:#{token}"
        literals += 1

        if nextOp[-1]&.arguments == 1
          expressions << nextOp.pop
        end

        if nextOp[-1]&.arguments == 2 and literals == 2
          expressions << nextOp.pop

          literals = 0
        end
      else
        nextOp << Object.const_get(token)
      end
    end

    expressions << nextOp.pop if nextOp.size > 0

    expressions
  end

  def self.tokenize(expr)
    tokens = expr.split(' ')
    expressions = []

    tokens.each do |token|
      case token
        when "not"
          expressions << "NotExpression"
        when "and"
          expressions << "AndExpression"
        when "nand"
          expressions << "NandExpression"
        when "or"
          expressions << "OrExpression"
        when "nor"
          expressions << "NorExpression"
        when "xor"
          expressions << "XorExpression"
        else
          expressions << token
      end
    end

    expressions
  end
end
