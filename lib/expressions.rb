require 'forwardable'

module Malk
  class Operator
    def initialize(args)
      args.size.times {|i| instance_variable_set("@arg#{i + 1}", args[i])}
    end
  end

  class UnaryOperator < Operator
    def self.arguments
      1
    end

    private
      def evaluate(op)
        instance_eval("#{op}@arg1.interpret")
      end
  end

  class BinaryOperator < Operator
    def self.arguments
      2
    end

    private
      def evaluate(op)
        instance_eval("@arg1.interpret #{op} @arg2.interpret")
      end
  end

  class Literal
    def initialize(args)
      @value = args.shift
    end

    def interpret
      @value
    end
  end

  class Variable
    def initialize(args)
      @identifier = args.shift.gsub("$", "").to_sym
      @ctx = args.shift
    end

    def interpret
      @ctx.fetch(@identifier)
    end
  end

  class Expression
    def initialize(expr)
      @expr = expr
    end

    def interpret
      instance_eval(@expr)
    end
  end

  class NotOperator < UnaryOperator
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("!")
    end
  end

  class AndOperator < BinaryOperator
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("&&")
    end
  end

  class OrOperator < BinaryOperator
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("||")
    end
  end

  class NandOperator < AndOperator
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      NotOperator.new([ AndOperator.new([ @arg1, @arg2 ]) ]).interpret
    end
  end

  class NorOperator < OrOperator
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      NotOperator.new([ OrOperator.new([ @arg1, @arg2 ]) ]).interpret
    end
  end

  class XorOperator < OrOperator
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("^")
    end
  end

  private_constant :Operator, :UnaryOperator, :BinaryOperator
end
