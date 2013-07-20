pluginDir = __dirname + '/../'
toType = (obj) -> ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()
assert = require('chai').assert;


try
  jy = require('jellyjs')
catch e
  root = __dirname + '/../../../../'
  jy = require("#{root}/index.js")

describe('#Plugin::routing', ->
  it('Should load the plugin', (cb) ->
    jelly = new jy.Jelly()
    jelly.getPluginDirectoryList().readPluginFromPath(pluginDir, 'template', (err, dt) ->
      cb(err)
    )
  )
)
