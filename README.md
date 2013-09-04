# xport

Export files to the client as JavaScript strings. Great for bundling templates/views and making them easily accessible to client side JavaScript.

## Install

`npm install -g xport`

## Usage

```
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
```

## Examples

Export all mustache templates found in `process.cwd() + '/app/views'` to `public/javascripts/templates.js` and define the template object as `App.Templates`:

```
xport app/views -e mustache -o public/javascripts/templates.js -x App.Templates
```

Generates public/javascripts/templates.js with the following contents:

```javascript
(function (global, files) {
  files['users/index'] = '[users/index content here]';
  files['users/show'] = '[users/show content here]';
  App.Templates = files;
}.call(this, this, {}));
```

<hr />

Do the same as the above but export a [CommonJS compatible module](http://wiki.commonjs.org/wiki/CommonJS) (i.e. for use with [browserify](https://github.com/substack/node-browserify) or [commonjs-everywhere](https://github.com/michaelficarra/commonjs-everywhere)):

```
xport app/views --commonjs -e mustache -o public/javascripts/templates.js
```

Generates public/javascripts/templates.js with the following contents:

```javascript
(function (global, files) {
  files['users/index'] = '[users/index content here]';
  files['users/show'] = '[users/show content here]';
  module.exports = files;
}.call(this, this, {}));
```

<hr />

Do the same as the above but export an [AMD compatible module](http://requirejs.org/docs/api.html#define) and include a couple of dependencies.

```
xport app/views --amd -e mustache -x app-templates --deps my-module:myModule --deps module-two:module2 -o public/javascripts/templates.js
```

Generates public/javascripts/templates.js with the following contents:

```javascript
define('app-templates', [
  'my-module',
  'module-two'
], function (myModule, module2) {
  var files = {};
  files['users/index'] = '[users/index content here]';
  files['users/show'] = '[users/show content here]';
  return files;
});
```

With the `--amd` flag, dependencies and module id (`-x` option in this context) are optional. Dependencies' function argument is the value after the colon. For example, `myModule` is the function argument when given a dependency named `my-module`: `--deps my-module:myModule`. If the function argument name is the same as the module id, the colon can be left off.


## License

(The MIT License)

Copyright (c) 2013 Ben Reinhart

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.