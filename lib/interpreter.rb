require_relative 'expressions'

module Malk
  class Interpreter
    def set_value_to(var_name, value)
      @ctx[var_name.to_sym] = value
    end

    def get_value_for(var_name)
      @ctx[var_name.to_sym]
    end

    def initialize(ctx = {})
      @ctx = ctx
    end

    def interpret(expr)
      parsed_expr = parse(expr)

      tokens = tokenize(parsed_expr)

      reordered = build_token_queue(tokens)

      expression = build_expression(reordered)

      expression.interpret
    end

    def build_expression(tokens)
      stack = []

      tokens.each do |token|

        if !token.kind_of?(Array) && token.ancestors.include?(Operator)
          params = []

          token.arguments.times {|_| params << stack.pop }

          stack << token.new(params.reverse)

        else
          c = token.shift

          params = token << @ctx

          stack << c.new(params)

        end
      end

      stack.pop
    end

    def build_token_queue(tokens)
      token_queue = []

      tokens.each do |queue|
        token_queue += reorder(queue)
      end

      token_queue
    end

    def tokenize(parsed_expr)
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

    def parse(expr)
      string = expr.dup

      expression = []
      subCount = 0

      while(closeP = string.index(")"))
        startP = string.rindex("(", closeP)

        sliceEnd = closeP - startP + 1

        slice = string.slice!(startP, sliceEnd)

        expression << slice.gsub("(", "").gsub(")", "")

        string.insert(startP, "@#{subCount}")

        subCount += 1
      end

      expression << string
    end

    def tokenize_expr(expr)
      tokens = []

      words = expr.split(' ')

      words.each do |word|
        case
        when word.include?("not")
          tokens << Malk::NotOperator
        when word.include?("nand")
          tokens << Malk::NandOperator
        when word.include?("and")
          tokens << Malk::AndOperator
        when word.include?("nor")
          tokens << Malk::NorOperator
        when word.include?("xor")
          tokens << Malk::XorOperator
        when word.include?("or")
          tokens << Malk::OrOperator
        when word.include?("@")
          tokens << word
        when word.include?("{")

        when word.include?("$")
          tokens << [ Malk::Variable, word ]
        else
          tokens << [ Malk::Literal, (word == "true") ]
        end
      end

      tokens
    end

    def reorder(tokens)
      expressions = []
      nextOp = []
      values = 0

      tokens.each do |token|
        next if token.kind_of? String

        if !token.kind_of?(Array) && token.ancestors.include?(Operator)
          nextOp << token
        else
          expressions << token
          values += 1

          if nextOp[-1]&.arguments == 1
            expressions << nextOp.pop
          end

          if nextOp[-1]&.arguments == 2 and values == 2
            expressions << nextOp.pop

            values = 0
          end
        end
      end

      expressions << nextOp.pop if nextOp.size > 0

      expressions
    end

    private :tokenize_expr, :reorder
  end
end
