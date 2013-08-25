# xport

Export your templates (or any files) to the client.

## Usage

```
USAGE: xport OPT* path/to/templates OPT*

xport /path/to/templates -e mustache -x App.Templates -o public/templates.js

-e, --extension EXTENSION     Search for templates with extension EXTENSION
-h, --help                    Display this help message and exit
-l, --list                    Do not bundle; list the files that would be bundled
-o, --output FILE             Output to FILE instead of stdout
-v, --version                 Display the current version number and exit
-x, --export NAME             Export the template object as NAME
```

## Examples

Export all mustache templates found in `process.cwd() + '/app/views'` to `public/javascripts/templates.js` and define the template object as `App.Templates`:

```
xport app/views -e mustache -o public/javascripts/templates.js -x App.Templates
```

Generates public/javascripts/templates.js with the following contents:

```javascript
(function (global) {
  var templates = {};
  templates['users/index'] = '[users/index content here]';
  templates['users/show'] = '[users/show content here]';
  App.Templates = templates;
}.call(this, this));
```

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