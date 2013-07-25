pluginDir = __dirname + '/../'
toType = (obj) -> ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()
assert = require('chai').assert;
async = require('async')


try
  jy = require('jellyjs')
catch e
  root = __dirname + '/../../../../'
  jy = require("#{root}/index.js")

describe('#Plugin::template', ->
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
  it('Should work with Module postProcess', (cb) ->
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demoPostProcess"
      folderPlugins:[{name:'template', directory:pluginDir}]
      onBeforeApplyPlugins: (cb) ->
        postProcess = jelly.getSharedObjectManager().getObject('template','postProcess').getCurrentContent()
        postProcess.TEST = (arg) ->
          return "__#{arg.TEST}__"
        cb()        
    }, (err) ->
        try
          file = jelly.getChildByIdRec('module1-file1.tpl')
          content = file.getCurrentContent()
          assert.equal(content.extension, '__template')
          assert.equal(toType(content.content), 'function')
          assert.equal(content.content(), 'TPL TEST__1__')
          cb()
        catch e
          cb(e)
    )
  )
  it('Should work with GeneralConfiguration postProcess', (cb) ->
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demoPostProcessGeneralConfig"
      folderPlugins:[{name:'template', directory:pluginDir}]
      onBeforeApplyPlugins: (cb) ->
        postProcess = jelly.getSharedObjectManager().getObject('template','postProcess').getCurrentContent()
        postProcess.TEST = (arg) ->
          return "__#{arg.TEST}__"
        cb()        
    }, (err) ->
        try
          file = jelly.getChildByIdRec('module1-file1.tpl')
          content = file.getCurrentContent()
          assert.equal(content.extension, '__template')
          assert.equal(toType(content.content), 'function')
          assert.equal(content.content(), 'TPL TEST__1____2__')
          cb()
        catch e
          cb(e)
    )
  )
  it('Partials includes should work', (cb) ->
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demoTemplateInclude"
      folderPlugins:[{name:'template', directory:pluginDir}]
      onBeforeApplyPlugins: (cb) ->
        postProcess = jelly.getSharedObjectManager().getObject('template','postProcess').getCurrentContent()
        postProcess.TEST = (arg) ->
          return "__#{arg.TEST}__"
        cb()        
    }, (err) ->
        if err?
          cb(err); cb = ->
          return
        try
          file = jelly.getChildByIdRec('module1-file2.tpl')
          content = file.getCurrentContent()
          assert.equal(content.extension, '__template')
          assert.equal(toType(content.content), 'function')
          assert.equal(content.content(), 'TEMPLATE2_BEFORE["module1-file2.tpl","module1-file1.tpl"]TPL TEST__1____2__TEMPLATE2_AFTER["module1-file2.tpl"]')

          file = jelly.getChildByIdRec('module1-file1.tpl')
          content = file.getCurrentContent()
          assert.equal(content.extension, '__template')
          assert.equal(toType(content.content), 'function')
          assert.equal(content.content(), '["module1-file1.tpl"]TPL TEST__1____2__')          
          cb()
        catch e
          cb(e)
    )
  )
  it('Sould have a \'dependencies\' property', (cb) ->
    jelly = new jy.Jelly()
    jelly.boot({
      directory:"#{__dirname}/demoTemplateInclude"
      folderPlugins:[{name:'template', directory:pluginDir}]
      onBeforeApplyPlugins: (cb) ->
        postProcess = jelly.getSharedObjectManager().getObject('template','postProcess').getCurrentContent()
        postProcess.TEST = (arg) ->
          return "__#{arg.TEST}__"
        cb()        
    }, (err) ->
        if err?
          cb(err); cb = ->
          return
        try
          file = jelly.getChildByIdRec('module1-file2.tpl')
          content = file.getLastOfProperty('dependencies')
          assert.equal(toType(content), 'array')
          assert.equal(JSON.stringify(content), '["module1-file2.tpl","module1-file1.tpl"]')
          cb()
        catch e
          cb(e)
    )
  )
)
