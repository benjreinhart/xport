readr = require 'readr'
esprima = require 'esprima'

FILE_IDENTIFIER = 'files'

module.exports = (path, options = {}) ->
  files = readr.sync path, options

  program = esprima.parse "(function(global, #{FILE_IDENTIFIER}){}).call(this, this, {})"
  program.body[0].expression.callee.object.body.body = (generateFunctionBody files, options)
  program

generateFunctionBody = (files, options) ->
  fileAssignments = files.map generateFileAssignmentNode
  exportExpression = (esprima.parse (getLHSExportExpression options)).body[0].expression

  lhsExpression =
    if exportExpression.type is 'Identifier'
      type: 'MemberExpression'
      computed: false
      object: {type: 'Identifier', name: 'global'}
      property: {type: 'Identifier', name: exportExpression.name}
    else
      exportExpression

  fileAssignments.concat
    type: 'ExpressionStatement'
    expression:
      type: 'AssignmentExpression'
      operator: '='
      left: lhsExpression
      right: {type: 'Identifier', name: FILE_IDENTIFIER}

generateFileAssignmentNode = (file) ->
  type: 'ExpressionStatement'
  expression:
    type: 'AssignmentExpression'
    operator: '='
    left:
      type: 'MemberExpression'
      computed: true
      object: {type: 'Identifier', name: FILE_IDENTIFIER}
      property: {type: 'Literal', value: file.friendlyPath ? file.path}
    right:
      type: 'Literal'
      value: file.contents

getLHSExportExpression = (options) ->
  if options.commonjs then 'module.exports' else options.export
