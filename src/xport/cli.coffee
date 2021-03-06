fs = require 'fs'
Path = require 'path'
nopt = require 'nopt'
xport = require '../'

isAbsolutePath = (path) -> /^\//.test path
resolveRelative = (relativePath) ->
  Path.resolve process.cwd(), relativePath

options = do ->
  opts =
    deps: [String, Array]
    export: String
    extension: String
    output: String

  aliases =
    d: '--deps'
    e: '--extension'
    m: '--minify'
    o: '--output'
    x: '--export'

  nopt opts, aliases, process.argv, 2

pathOpt = options.argv.remain[0]
delete options.argv

if options.help
  console.log "
  USAGE: xport OPT* path/to/files OPT*

  xport app/views -e mustache -x App.Templates -o public/templates.js

  -e, --extension EXTENSION     Only bundle files with extension EXTENSION
  -d, --deps DEPENDENCY:ARG     For use with --amd flag; specify dependencies and
                                their corresponding argument identifiers
  -m, --minify                  Minify the compiled JavaScript
  -o, --output FILE             Output to FILE instead of stdout
  -x, --export NAME             Export the files object as NAME; if --amd flag
                                is specified, then the module id will be NAME
  --amd                         Export an AMD compatible module
  --commonjs                    Export a CommonJS compatible module
  --help                        Display this help message and exit
  --list                        Do not bundle; list the files that would be bundled
  --version                     Display the current version number and exit
  "

  process.exit 0

if options.version
  console.log (require '../../package.json').version
  process.exit 0

unless pathOpt?
  console.error 'wrong number of entry paths given; expected 1'
  process.exit 1

if options.list
  paths = (require 'readr').getPathsSync pathOpt, options
  console.log JSON.stringify paths, null, 4
  process.exit 0

js = xport pathOpt, options

if (outputPath = options.output)?
  unless isAbsolutePath outputPath
    outputPath = resolveRelative outputPath

  fs.writeFileSync outputPath, js
  process.exit 0

console.log js
