dot = require('dot')
fs = require('fs')
dotParsing = require('./dotParsing')

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

processModule = (dot, obj) ->
  for file in obj.getChildList()
    processFileModule(dot, file)

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


    dot.templateSettings.strip = false

    if obj.Module == true
      dotParsing.setModuleSettings(dot.templateSettings);
      processModule(dot, obj)      
    else if obj.File == true
      dotParsing.setFileSettings(dot.templateSettings);
      processFile(dot, obj)
    cb(null, obj)
  unload: (cb) ->
    cb()
}