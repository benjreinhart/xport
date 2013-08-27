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

expectedDefaultJS = "(function (global) {
  var templates = {};
  templates['views/index'] = '<html></html>';
  global.AppTemplates = templates;
}.call(this, this));"

expectedJSWithExportOption = "(function (global) {
  var templates = {};
  templates['views/index'] = '<html></html>';
  My.Application['templ-lates'] = templates;
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

    it 'is a js program that assigns file contents to a variable', ->
      program = xport '/path/to/app', {extension: 'mustache'}
      expect(escodegen.generate program, {format: escodegenFormat}).to.equal expectedDefaultJS

    it 'accepts an export option', ->
      program = xport '/path/to/app', {extension: 'mustache', export: "My.Application['templ-lates']"}
      expect(escodegen.generate program, {format: escodegenFormat}).to.equal expectedJSWithExportOption
