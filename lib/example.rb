require_relative 'interpreter'

expressions = [
=begin
  "false nand false",
  "false nand true",
  "true nand true",
  "false nor false",
  "false nor true",
  "true nor true",
  "false xor false",
  "false xor true",
  "true xor true",
=end
  "not false and not false",
=begin
  "not false or not false",
  "not false and false",
  "not (false and false)",
  "$a and $b or not $c",
  #"{$a < 4} and ($b or $c)"
=end
]

context = { a: true, b: true, c: true }

puts "context is: #{context}"

interpreter = Malk::Interpreter.new(context)

expressions.each do |expr|
  puts "#{expr}: #{interpreter.interpret expr}"
end
=begin
puts "$a and $b: #{interpreter.interpret('$a and $b')}"

puts "changing context :a to false"

interpreter.set_value_to(:a, false)

puts "$a and $b: #{interpreter.interpret('$a and $b')}"
=end
