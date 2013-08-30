// Generated by CoffeeScript 2.0.0-beta6
void function () {
  var files, fs, isAbsolutePath, js, nopt, options, outputPath, Path, pathOpt, resolveRelative, xport;
  fs = require('fs');
  Path = require('path');
  nopt = require('nopt');
  xport = require('../');
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
      c: '--commonjs',
      e: '--extension',
      h: '--help',
      l: '--list',
      o: '--output',
      v: '--version',
      x: '--export'
    };
    return nopt(opts, aliases, process.argv, 2);
  }();
  pathOpt = options.argv.remain[0];
  delete options.argv;
  if (options.help) {
    console.log('\n  USAGE: xport OPT* path/to/files OPT*\n\n  xport app/views -e mustache -x App.Templates -o public/templates.js\n\n  -c, --commonjs                Export a commonjs compatible module\n  -e, --extension EXTENSION     Only bundle files with extension EXTENSION\n  -h, --help                    Display this help message and exit\n  -l, --list                    Do not bundle; list the files that would be bundled\n  -o, --output FILE             Output to FILE instead of stdout\n  -v, --version                 Display the current version number and exit\n  -x, --export NAME             Export the files object as NAME\n  ');
    process.exit(0);
  }
  if (options.version) {
    console.log(require('../../package.json').version);
    process.exit(0);
  }
  if (!(null != pathOpt)) {
    console.error('wrong number of entry paths given; expected 1');
    process.exit(1);
  }
  if (!isAbsolutePath(pathOpt))
    pathOpt = resolveRelative(pathOpt);
  if (options.list) {
    files = require('readr').sync(pathOpt, options).reduce(function (memo, file) {
      memo.push({
        path: file.path,
        friendlyPath: file.friendlyPath
      });
      return memo;
    }, []);
    console.log(JSON.stringify(files, null, 4));
    process.exit(0);
  }
  js = xport(pathOpt, options);
  if (null != (outputPath = options.output)) {
    if (!isAbsolutePath(outputPath))
      outputPath = resolveRelative(outputPath);
    fs.writeFileSync(outputPath, js);
    process.exit(0);
  }
  console.log(js);
}.call(this);