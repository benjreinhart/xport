readr = require 'readr'
esprima = require 'esprima'

TEMPLATE_IDENTIFIER = 'templates'

module.exports = (path, options = {}) ->
  files = readr.sync path, options
  buildAst files, options

buildAst = (files, options) ->
  wrapper = esprima.parse '(function(global){}).call(this, this)'
  body = generateFunctionBody files, options
  wrapper.body[0].expression.callee.object.body.body = body

  wrapper

generateFunctionBody = (files, options) ->
  templateVarDeclaration = (esprima.parse "var #{TEMPLATE_IDENTIFIER} = {};").body[0]
  templateAssigments = files.map generateExpressionNode
  exportExpression = (esprima.parse options.export ? 'AppTemplates').body[0].expression

  lhsExpression =
    if exportExpression.type is 'Identifier'
      type: 'MemberExpression'
      computed: false
      object: {type: 'Identifier', name: 'global'}
      property: {type: 'Identifier', name: exportExpression.name}
    else
      exportExpression

  exportAssignment =
    type: 'ExpressionStatement'
    expression:
      type: 'AssignmentExpression'
      operator: '='
      left: lhsExpression
      right: {type: 'Identifier', name: TEMPLATE_IDENTIFIER}

  [templateVarDeclaration].concat(templateAssigments).concat exportAssignment

generateExpressionNode = (file) ->
  type: 'ExpressionStatement'
  expression:
    type: 'AssignmentExpression'
    operator: '='
    left:
      type: 'MemberExpression'
      computed: true
      object: {type: 'Identifier', name: TEMPLATE_IDENTIFIER}
      property: {type: 'Literal', value: file.friendlyPath ? file.path}
    right:
      type: 'Literal'
      value: file.contents
