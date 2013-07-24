dot = require('dot')
fs = require('fs')

dotProcessingArguments = {
  if: (arg) -> ";if (#{arg});{"
  endif: -> ";};"
  nop: ""
  postProcess: -> ""
}

processFile = (dot, file) ->
      ct = file.getCurrentContent()
      output = dot.compile(ct.content || '', dotProcessingArguments)
      file.updateContent({
        extension:'__template',
        content:output
      })

processFileModule = (dot, file) ->
  ct = file.getCurrentContent()
  output = dot.compile(ct.content.toString() || '', dotProcessingArguments)
  file.updateContent({
      extension:'__template',
      content:new Function('return ' + output())()
  })
  ;

processModule = (dot, obj, cb) ->
  for file in obj.getChildList()
    processFileModule(dot, file)
  cb()

module.exports = {
  load: (cb) ->
    @getSharedObjectManager().registerObject('template', 'postProcess', {});
    cb()
  oncall: (obj, params, cb) ->
    postProcess = @getSharedObjectManager().getObject('template','postProcess').getCurrentContent()
    dotProcessingArguments.postProcess = (name, args) ->
      if typeof postProcess[name] == 'undefined' || postProcess[name] == null
        throw new Error("Unable to process #{name} on postProcess")
        return

      if typeof postProcess[name] != 'function'
        throw new Error("Invalid function (#{typeof postProcess[name]}) given as argument on postProces")
        return
      try
        return postProcess[name](args) || ''
      catch e
        throw new Error("Error encountered when executing #{name} as an argument on template postProcess")


    t = dot.templateSettings
    t.strip = false;
    if obj.Module == true
      t.evaluate =    /\[\[([\s\S]+?\]?)\]\]/g
      t.interpolate = /\[\[=([\s\S]+?)\]\]/g
      t.encode =      /\[\[!([\s\S]+?)\]\]/g
      t.use =         /\[\[#([\s\S]+?)\]\]/g
      t.useParams =   /(^|[^\w$])def(?:\.|\[[\'\"])([\w$\.]+)(?:[\'\"]\])?\s*\:\s*([\w$\.]+|\"[^\"]+\"|\'[^\']+\'|\[[^\]]+\])/g
      t.define =      /\[\[##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\]\]/g
      t.defineParams = /^\s*([\w$]+):([\s\S]+)/
      t.conditional = /\[\[\?(\?)?\s*([\s\S]*?)\s*\]\]/g
      t.iterate =     /\[\[~\s*(?:\]\]|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\]\])/g      
      processModule(dot, obj, cb)      
      return
    if obj.File == true
      t.evaluate =    /\{\{([\s\S]+?\}?)\}\}/g
      t.interpolate = /\{\{=([\s\S]+?)\}\}/g
      t.encode =      /\{\{!([\s\S]+?)\}\}/g
      t.use =         /\{\{#([\s\S]+?)\}\}/g
      t.useParams =   /(^|[^\w$])def(?:\.|\[[\'\"])([\w$\.]+)(?:[\'\"]\])?\s*\:\s*([\w$\.]+|\"[^\"]+\"|\'[^\']+\'|\{[^\}]+\})/g
      t.define =      /\{\{##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\}\}/g
      t.defineParams = /^\s*([\w$]+):([\s\S]+)/
      t.conditional = /\{\{\?(\?)?\s*([\s\S]*?)\s*\}\}/g
      t.iterate =     /\{\{~\s*(?:\}\}|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\}\})/g      
    try
      processFile(dot, obj)
      cb(null, obj)
    catch e
      cb(e)
  unload: (cb) ->
    cb()
}