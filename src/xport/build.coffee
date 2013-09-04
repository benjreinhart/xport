readr = require 'readr'
esprima = require 'esprima'

FILE_IDENTIFIER = 'files'

module.exports = (path, options = {}) ->
  files = readr.sync path, options
  (if options.amd then buildAmdProgram else buildProgram)(files, options)

buildProgram = (files, options) ->
  program = esprima.parse "(function(global, #{FILE_IDENTIFIER}){}).call(this, this, {})"
  program.body[0].expression.callee.object.body.body = (generateFunctionBody files, options)
  program

buildAmdProgram = (files, options) ->
  program = esprima.parse 'define()'
  callExpression = program.body[0].expression

  if options.export
    callExpression.arguments.push
      type: 'Literal'
      value: options.export

  if options.deps
    deps = (dep.split /:/ for dep in options.deps)
    callExpression.arguments.push
      type: 'ArrayExpression'
      elements: (deps.map (dep) -> {type: 'Literal', value: dep[0]})
    moduleDefinitionArgs = (deps.map (dep) -> dep[1] ? dep[0]).join ', '

  moduleDefinition = (esprima.parse "(function(#{moduleDefinitionArgs ? ''}){var #{FILE_IDENTIFIER} = {};});").body[0].expression
  moduleDefinitionBody = (files.map generateFileAssignmentNode).concat
    type: 'ReturnStatement'
    argument: {type: 'Identifier', name: FILE_IDENTIFIER}

  moduleDefinition.body.body.push moduleDefinitionBody...
  callExpression.arguments.push moduleDefinition

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
