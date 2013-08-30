module.exports = xport = (path, options = {}) ->
  xport.generate (xport.build path, options), options

xport.build = require './xport/build'
xport.generate = require './xport/generate'
