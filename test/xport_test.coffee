readr = require 'readr'
xport = require '../'
sinon = require 'sinon'
{expect} = require 'chai'
escodegen = require 'escodegen'

escodegenFormat =
  indent:
    style: '  '
    base: 0
  quotes: 'auto'
  renumber: true
  hexadecimal: true
  parentheses: false

getExpectedJS = (expectedLhsExpression = 'global.AppTemplates') ->
  "(function (global) {
  var templates = {};
  templates['views/index'] = '<html></html>';
  #{expectedLhsExpression} = templates;
}.call(this, this));"


describe 'xport', ->
  describe 'AST', ->
    beforeEach ->
      sinon.stub readr, 'sync', ->
        [
          path: '/path/to/app/views/index.mustache'
          contents: '<html></html>'
          friendlyPath: 'views/index'
        ]

    afterEach ->
      readr.sync.restore()

    it 'is exported as the export option if provided', ->
      program = xport '/path/to/app', {extension: 'mustache'}
      expect(escodegen.generate program, {format: escodegenFormat}).to.equal getExpectedJS()

      exported = "My.Application['templ-lates']"
      program = xport '/path/to/app', {extension: 'mustache', export: exported}
      expect(escodegen.generate program, {format: escodegenFormat}).to.equal (getExpectedJS exported)

    describe 'commonjs', ->
      it 'is exported as commonjs if the commonjs option is true', ->
        program = xport '/path/to/app', {extension: 'mustache', commonjs: true}
        expect(escodegen.generate program, {format: escodegenFormat}).to.equal (getExpectedJS 'module.exports')

      it 'takes precedence over an export option', ->
        program = xport '/path/to/app', {extension: 'mustache', commonjs: true, export: "My.Application['templ-lates']"}
        expect(escodegen.generate program, {format: escodegenFormat}).to.equal (getExpectedJS 'module.exports')
