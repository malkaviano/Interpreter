module OperatorExpression
  def arguments
    @arguments
  end
end

module UnaryExpression
  def evaluate(op)
    instance_eval("#{op}@arg.interpret")
  end
end

module BinaryExpression
  def init(args)
    @arg1 = args[0]
    @arg2 = args[1]
  end

  def evaluate(op)
    instance_eval("@arg1.interpret #{op} @arg2.interpret")
  end
end

class Literal
  include Comparable

  def initialize(arg)
    @arg = arg
  end

  def interpret
    !(@arg.include? "false")
  end
end

class NotExpression
  extend OperatorExpression
  include UnaryExpression

  @arguments = 1

  def initialize(args)
    @arg = args[0]
  end

  def interpret
    evaluate("!")
  end
end

class AndExpression
  extend OperatorExpression
  include BinaryExpression

  @arguments = 2

  def initialize(args)
    init args
  end

  def interpret
    evaluate("&&")
  end
end

class NandExpression
  extend OperatorExpression
  include BinaryExpression

  @arguments = 2

  def initialize(args)
    @arg1 = args[0]
    @arg2 = args[1]
  end

  def interpret
    NotExpression(AndExpression(@arg1, @arg2))
  end
end

class OrExpression
  extend OperatorExpression
  include BinaryExpression

  @arguments = 2

  def initialize(args)
    @arg1 = args[0]
    @arg2 = args[1]
  end

  def interpret
    evaluate("||")
  end
end
