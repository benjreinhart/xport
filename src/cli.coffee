fs = require 'fs'
Path = require 'path'
nopt = require 'nopt'
xport = require './'
escodegen = require 'escodegen'

escodegenFormat =
  indent:
    style: '  '
    base: 0
  renumber: yes
  hexadecimal: yes
  quotes: 'auto'
  parentheses: no

isAbsolutePath = (path) -> /^\//.test path
resolveRelative = (relativePath) ->
  Path.resolve process.cwd(), relativePath

options = do ->
  opts =
    export: String
    extension: String
    output: String

  aliases =
    d: '--deps'
    e: '--extension'
    h: '--help'
    o: '--output'
    v: '--version'
    x: '--export'

  nopt opts, aliases, process.argv, 2

pathOpt = options.argv.remain[0]
delete options.argv

if options.help
  console.log "
  USAGE: xport OPT* path/to/templates OPT*

  xport /path/to/templates -e mustache -x App.Templates -o public/templates.js

  -d, --deps                    Do not bundle; list the files that would be bundled
  -e, --extension EXTENSION     Search for templates with extension EXTENSION
  -h, --help                    Display this help message and exit
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

if options.deps
  ((require 'readr').sync pathOpt, options).forEach (file) ->
    console.log file.path
  process.exit 0

js = escodegen.generate (xport pathOpt, options), {format: escodegenFormat}

if (outputPath = options.output)?
  unless isAbsolutePath outputPath
    outputPath = resolveRelative outputPath

  fs.writeFileSync outputPath, js
  process.exit 0

console.log js
