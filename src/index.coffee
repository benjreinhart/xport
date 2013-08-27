readr = require 'readr'
esprima = require 'esprima'

FILE_IDENTIFIER = 'files'

module.exports = (path, options = {}) ->
  files = readr.sync path, options
  buildAst files, options

buildAst = (files, options) ->
  program = esprima.parse '(function(global){}).call(this, this)'
  body = generateFunctionBody files, options
  program.body[0].expression.callee.object.body.body = body
  program

generateFunctionBody = (files, options) ->
  fileVarDeclaration = (esprima.parse "var #{FILE_IDENTIFIER} = {};").body[0]
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

  exportAssignment =
    type: 'ExpressionStatement'
    expression:
      type: 'AssignmentExpression'
      operator: '='
      left: lhsExpression
      right: {type: 'Identifier', name: FILE_IDENTIFIER}

  [fileVarDeclaration].concat(fileAssignments).concat exportAssignment

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
