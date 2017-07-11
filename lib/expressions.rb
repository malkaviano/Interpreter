require 'forwardable'

module Malk
  class UnaryExpression
    def self.arguments
      1
    end

    def initialize(args)
      @arg = args[0]
    end

    private
      def evaluate(op)
        instance_eval("#{op}@arg.interpret")
      end
  end

  class BinaryExpression
    def self.arguments
      2
    end

    def initialize(args)
      @arg1 = args[0]
      @arg2 = args[1]
    end

    private
      def evaluate(op)
        instance_eval("@arg1.interpret #{op} @arg2.interpret")
      end
  end

  class Literal
    def value
      @arg
    end

    def initialize(arg)
      @arg = arg
    end
  end

  class Boolean < Literal
    def interpret
      !(@arg.include? "false")
    end

    def ==(other)
      return nil unless other.kind_of? Boolean

      value == other.value
    end
  end

  class NotExpression < UnaryExpression
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("!")
    end
  end

  class AndExpression < BinaryExpression
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("&&")
    end
  end

  class OrExpression < BinaryExpression
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("||")
    end
  end

  class NandExpression < AndExpression
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      NotExpression.new([ AndExpression.new([ @arg1, @arg2 ]) ]).interpret
    end
  end

  class NorExpression < OrExpression
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      NotExpression.new([ OrExpression.new([ @arg1, @arg2 ]) ]).interpret
    end
  end

  class XorExpression < OrExpression
    extend SingleForwardable

    def_delegator :superclass, :arguments

    def interpret
      evaluate("^")
    end
  end

  private_constant :Literal, :UnaryExpression, :BinaryExpression
end
