readr = require 'readr'
xport = require '../'
sinon = require 'sinon'
{expect} = require 'chai'

getExpectedJS = (expectedLhsExpression) ->
  "(function (global, files) {
  files['views/index'] = '<html></html>';
  #{expectedLhsExpression} = files;
}.call(this, this, {}));"

describe 'xport', ->

  beforeEach ->
    sinon.stub readr, 'sync', ->
      [
        path: '/path/to/app/views/index.mustache'
        contents: '<html></html>'
        friendlyPath: 'views/index'
      ]

  afterEach ->
    readr.sync.restore()

  it 'is a valid JS program', ->
    exported = "My.Application['templ-lates']"
    actualJS = xport '/path/to/app', {extension: 'mustache', export: exported}
    expect(actualJS).to.equal (getExpectedJS exported)

  describe 'commonjs', ->
    it 'is exported as commonjs if the commonjs option is true', ->
      actualJS = xport '/path/to/app', {extension: 'mustache', commonjs: true}
      expect(actualJS).to.equal (getExpectedJS 'module.exports')

    it 'takes precedence over an export option', ->
      actualJS = xport '/path/to/app', {extension: 'mustache', commonjs: true, export: "My.Application['templ-lates']"}
      expect(actualJS).to.equal (getExpectedJS 'module.exports')
