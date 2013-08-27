fs = require 'fs'
Path = require 'path'
nopt = require 'nopt'
xport = require './'
escodegen = require 'escodegen'

escodegenFormat =
  indent:
    style: '  '
    base: 0
  quotes: 'auto'
  renumber: true
  hexadecimal: true
  parentheses: false

isAbsolutePath = (path) -> /^\//.test path
resolveRelative = (relativePath) ->
  Path.resolve process.cwd(), relativePath

options = do ->
  opts =
    export: String
    extension: String
    output: String

  aliases =
    c: '--commonjs'
    e: '--extension'
    h: '--help'
    l: '--list'
    o: '--output'
    v: '--version'
    x: '--export'

  nopt opts, aliases, process.argv, 2

pathOpt = options.argv.remain[0]
delete options.argv

if options.help
  console.log "
  USAGE: xport OPT* path/to/templates OPT*

  xport app/views -e mustache -x App.Templates -o public/templates.js

  -c, --commonjs                Export a commonjs compatible module
  -e, --extension EXTENSION     Search for templates with extension EXTENSION
  -h, --help                    Display this help message and exit
  -l, --list                    Do not bundle; list the files that would be bundled
  -o, --output FILE             Output to FILE instead of stdout
  -v, --version                 Display the current version number and exit
  -x, --export NAME             Export the template object as NAME
  "

  process.exit 0

if options.version
  console.log (require '../package.json').version
  process.exit 0

unless pathOpt?
  console.error 'wrong number of entry paths given; expected 1'
  process.exit 1

unless isAbsolutePath pathOpt
  pathOpt = resolveRelative pathOpt

if options.list
  templates = ((require 'readr').sync pathOpt, options).reduce ((memo, file) ->
    memo.push {path: file.path, friendlyPath: file.friendlyPath}
    memo
  ), []
  console.log (JSON.stringify templates, null, 4)
  process.exit 0

js = escodegen.generate (xport pathOpt, options), {format: escodegenFormat}

if (outputPath = options.output)?
  unless isAbsolutePath outputPath
    outputPath = resolveRelative outputPath

  fs.writeFileSync outputPath, js
  process.exit 0

console.log js
