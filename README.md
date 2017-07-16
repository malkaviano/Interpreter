# Interpreter [![Build Status](https://travis-ci.org/malkaviano/Interpreter.svg?branch=master)](https://travis-ci.org/malkaviano/Interpreter)

#### Simple Interpreter to parse boolean expressions, inspired by GoF design pattern. It tries to keep a fidelity to composite pattern.

### How to use:
Pass any string with boolean expressions to Interpreter#interpret, variables can be used with a $ prefix, variable value must be specified in a hash used as a context and injected into Interpreter.

### Info
* Expressions: and, or, not and derivated.
* Parentesis are accepted to define precedence.
* Case sensitive

TODO:
* Include expression code evaluation.
* Better check for mal formatted expressions
