escodegen = require 'escodegen'

defaultEscodegenFormat =
  indent:
    style: '  '
    base: 0
  quotes: 'auto'
  renumber: true
  hexadecimal: true
  parentheses: false

module.exports = (ast, format = {}) ->
  for own key, value of defaultEscodegenFormat
    format[key] ?= value
  escodegen.generate ast, {format}
