pluginDir = __dirname + '/../'
toType = (obj) -> ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()
assert = require('chai').assert;
async = require('async')


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
  it('Should transform everything into templates', (cb) ->
    jelly = new jy.Jelly()
    jelly.setRootDirectory("#{__dirname}/demo")
    async.series([
      (cb) -> jelly.readJellyConfigurationFile( (err) -> cb(err,null)),
      (cb) -> jelly.readAllGeneralConfigurationFiles( (err) -> cb(err,null))
      (cb) ->
        jelly.getPluginDirectoryList().readPluginFromPath(pluginDir, 'template', (err, dt) ->
          cb(err)
        )
      (cb) -> jelly.applyPluginsSpecified(true, (err) -> cb(err))
      (cb) ->
        try
          file = jelly.getChildByIdRec('module1-file1.tpl')
          content = file.getCurrentContent()
          assert.equal(content.extension, '__template')
          assert.equal(toType(content.content), 'function')
          assert.equal(content.content(), 'TPL TEST')
          cb()
        catch e
          cb(e)
    ], (err) ->
      cb(err)
    )
  )
  it('Should throw an error when the postProcess is invalid', (cb) ->
    new jy.Jelly().boot({
      directory:"#{__dirname}/demoPostProcess"
      folderPlugins:[{name:'template', directory:pluginDir}]
    }, (err) ->
      if err
        cb()
      else
        cb(new Error("no errors detected"));
    )
  )
  it('Should transform everything into templates', (cb) ->
    jelly = new jy.Jelly()
    jelly.setRootDirectory("#{__dirname}/demoPostProcess")
    async.series([
      (cb) -> jelly.readJellyConfigurationFile( (err) -> cb(err,null)),
      (cb) -> jelly.readAllGeneralConfigurationFiles( (err) -> cb(err,null))
      (cb) ->
        jelly.getPluginDirectoryList().readPluginFromPath(pluginDir, 'template', (err, dt) ->
          cb(err)
        )
      (cb) ->
        postProcess = jelly.getSharedObjectManager().getObject('template','postProcess').getCurrentContent()
        postProcess.TEST = ->
          return "__1__"
        cb()
      (cb) -> jelly.applyPluginsSpecified(true, (err) -> cb(err))
      (cb) ->
        try
          file = jelly.getChildByIdRec('module1-file1.tpl')
          content = file.getCurrentContent()
          assert.equal(content.extension, '__template')
          assert.equal(toType(content.content), 'function')
          assert.equal(content.content(), 'TPL TEST__1__')
          cb()
        catch e
          cb(e)
    ], (err) ->
      cb(err)
    )
  )  
)
