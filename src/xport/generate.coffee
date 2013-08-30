esmangle = require 'esmangle'
escodegen = require 'escodegen'

defaultEscodegenFormat =
  indent:
    style: '  '
    base: 0
  quotes: 'auto'
  renumber: true
  hexadecimal: true
  parentheses: false

module.exports = (ast, options = {}) ->
  minify = options.minify
  delete options.minify

  if minify
    ast = esmangle.mangle (esmangle.optimize ast), destructive: true
    format = escodegen.FORMAT_MINIFY
  else
    format = options
    for own key, value of defaultEscodegenFormat
      format[key] ?= value

  escodegen.generate ast, {format}
