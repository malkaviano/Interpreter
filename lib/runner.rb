require_relative 'interpreter'

string = "false or not true and true"

expr = Interpreter.build_expression string

p expr
