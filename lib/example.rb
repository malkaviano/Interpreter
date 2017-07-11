require_relative 'interpreter'

expressions = [
  "false nand false",
  "false nand true",
  "true nand true",
  "false nor false",
  "false nor true",
  "true nor true",
  "false xor false",
  "false xor true",
  "true xor true",
  "not false and not false",
  "not false or not false",
  "not false and false",
  "not (false and false)",
]

expressions.each do |expr|
  puts "#{expr}: #{Malk::Interpreter.interpret expr}"
end
