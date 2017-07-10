require_relative 'expressions'

module Malk
  class Interpreter
    def self.interpret(expr)
      parsed_expr = parse(expr)

      tokens = tokenize(parsed_expr)

      classified_tokens = classify(tokens)

      expression = build_expression(classified_tokens)

      expression.interpret
    end

    def self.build_expression(classified_tokens)
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

      values.pop
    end

    def self.classify(tokens)
      token_queue = []

      tokens.each do |queue|
        token_queue += classify_tokens(queue)
      end

      token_queue
    end

    def self.tokenize(parsed_expr)
      tokens = []

      parsed_expr.each do |expr|

        if expr.kind_of? Array
          tokens << tokenize(expr)
        else
          tokens << tokenize_expr(expr)
        end
      end

      tokens
    end

    def self.parse(expr)
      expression = []
      subCount = 0

      while(closeP = expr.index(")"))
        startP = expr.rindex("(", closeP)

        sliceEnd = closeP - startP + 1

        slice = expr.slice!(startP, sliceEnd)

        expression << slice.gsub("(", "").gsub(")", "")

        expr.insert(startP, "@#{subCount}")

        subCount += 1
      end

      expression << expr
    end

    def self.tokenize_expr(expr)
      tokens = []

      words = expr.split(' ')

      words.each do |word|
        case word
          when "not"
            tokens << "Malk::NotExpression"
          when "and"
            tokens << "Malk::AndExpression"
          when "nand"
            tokens << "Malk::NandExpression"
          when "or"
            tokens << "Malk::OrExpression"
          when "nor"
            tokens << "Malk::NorExpression"
          when "xor"
            tokens << "Malk::XorExpression"
          when "true", "false"
            tokens << word
          else
            tokens << word
        end
      end

      tokens
    end

    def self.classify_tokens(tokens)
      expressions = []
      nextOp = []
      literals = 0

      tokens.each do |token|
        next if token.include? "@"

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

    private_class_method :tokenize_expr, :classify_tokens
  end
end
