// Generated by CoffeeScript 2.0.0-beta6
void function () {
  var escodegen, escodegenFormat, fs, isAbsolutePath, js, nopt, options, outputPath, Path, pathOpt, resolveRelative, xport;
  fs = require('fs');
  Path = require('path');
  nopt = require('nopt');
  xport = require('./');
  escodegen = require('escodegen');
  escodegenFormat = {
    indent: {
      style: '  ',
      base: 0
    },
    renumber: true,
    hexadecimal: true,
    quotes: 'auto',
    parentheses: false
  };
  isAbsolutePath = function (path) {
    return /^\//.test(path);
  };
  resolveRelative = function (relativePath) {
    return Path.resolve(process.cwd(), relativePath);
  };
  options = function () {
    var aliases, opts;
    opts = {
      'export': String,
      extension: String,
      output: String
    };
    aliases = {
      d: '--deps',
      e: '--extension',
      h: '--help',
      o: '--output',
      v: '--version',
      x: '--export'
    };
    return nopt(opts, aliases, process.argv, 2);
  }();
  pathOpt = options.argv.remain[0];
  delete options.argv;
  if (options.help) {
    console.log('\n  USAGE: xport OPT* path/to/templates OPT*\n\n  xport /path/to/templates -e mustache -x App.Templates -o public/templates.js\n\n  -d, --deps                    Do not bundle; list the files that would be bundled\n  -e, --extension EXTENSION     Search for templates with extension EXTENSION\n  -h, --help                    Display this help message and exit\n  -o, --output FILE             Output to FILE instead of stdout\n  -v, --version                 Display the current version number and exit\n  -x, --export NAME             Export the template object as NAME\n  ');
    process.exit(0);
  }
  if (options.version) {
    console.log(require('../package.json').version);
    process.exit(0);
  }
  if (!(null != pathOpt)) {
    console.error('wrong number of entry paths given; expected 1');
    process.exit(1);
  }
  if (!isAbsolutePath(pathOpt))
    pathOpt = resolveRelative(pathOpt);
  if (options.deps) {
    require('readr').sync(pathOpt, options).forEach(function (file) {
      return console.log(file.path);
    });
    process.exit(0);
  }
  js = escodegen.generate(xport(pathOpt, options), { format: escodegenFormat });
  if (null != (outputPath = options.output)) {
    if (!isAbsolutePath(outputPath))
      outputPath = resolveRelative(outputPath);
    fs.writeFileSync(outputPath, js);
    process.exit(0);
  }
  console.log(js);
}.call(this);