dot = require('dot')
fs = require('fs')
dotParsing = require('./dotParsing')

dotProcessingArguments = {
  if: (arg) -> ";if (#{arg});{"
  endif: -> ";};"
  nop: ""
  postProcess: -> ""
  displayStack: () ->
    "{{=(typeof(_stack)==='undefined')? '[]':JSON.stringify(_stack)}}"
  getCurrentFile: () ->

}

_beginStackFile = (fileid) ->
  "{{;it = it || {};var _stack = ['#{fileid}'];var self = it['#{fileid}'] || {};}}"

_beginStackPartial = (fileid) ->
  "{{;_stack.push('#{fileid}');self = it['#{fileid}'] || {};}}"


_endStack =  () ->
  ""

_endStackPartial = () ->
  "{{;_stack.pop();self = out[(_stack[_stack.length - 1]||'')] || {};}}"


## process a individual file
processFile = (dot, file, dependencies, options) ->
    contentToCompile = ''
    allowedExtensions = options.allowedExtensions || ['tpl']
    try
      ct = file.getCurrentContent()
      if ct.extension == null || typeof ct.extension == 'undefined' || \
        allowedExtensions.indexOf(ct.extension) == -1
          return
      contentToCompile = \
        _beginStackFile(file.getId()) \
        + ct.content \
        + _endStack();
      output = dot.compile(contentToCompile || '', dotProcessingArguments)
      file.updateContent({
        extension:'__template',
        content:output
        dependencies: dependencies
      })
    catch e
      throw new Error("Cannot compile #{file.getId()}, #{e.message}, #{contentToCompile}")

## process an individual file called within a module or a generalconfig
## these are already parsed and added as functions
processFileModule = (dot, file, options) ->
  contentToCompile = ''
  try
    ct = file.getCurrentContent()
    contentToCompile = ct.content.toString()
    output = dot.compile(contentToCompile || '', dotProcessingArguments)
    file.updateContent({
        extension:'__template',
        content:new Function('return ' + output())()
    })
  catch e
    throw new Error("Cannot compile #{file.getId()}, #{e.message}, #{contentToCompile}")    
  ;

processModule = (dot, module, options) ->
  for file in module.getChildList()
    processFileModule(dot, file, options)
  return

processGeneralConfig = (dot, generalconfig, options) ->
  for module in generalconfig.getChildList()
    processModule(dot, module, options)
  return

module.exports = {
  load: (cb) ->
    @getSharedObjectManager().registerObject('template', 'postProcess', {});
    cb()
  oncall: (obj, params, cb) ->
    self = @
    params.pluginParameters ?= {}
    options = params.pluginParameters.template || {}
    dependencies = []
    postProcess = @getSharedObjectManager().getObject('template','postProcess').getCurrentContent()
    
    @getLogger().info("Processing file #{obj.getId()}")
    ## the postprocess helper is calling function registrer by the postProcess object
    ## this way, external plugins can be called within a method
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

    ## include a template in a other template
    dotProcessingArguments.include = (fileId) ->
      err = "[#{(self.getParent() || {getId:->{}}).getId()}]:"
      jelly = self.getParentOfClass('Jelly')
      file = jelly.getChildByIdRec(fileId)
      if file == null
        throw new Error("#{err} Cannot find fild Id '#{fileId}' on include statement")
      tplContent = file.getLastContentOfExtension('tpl')
      if tplContent == null
        throw new Error("#{err} There is no tpl content loaded for '#{fileId}' on include statement")
      dependencies.push(fileId)
      return _beginStackPartial(fileId) + tplContent.content + _endStackPartial()

    dot.templateSettings.strip = options.strip || false

    if obj.GeneralConfiguration == true
      dotParsing.setGeneralConfigFileSettings(dot.templateSettings)
      processGeneralConfig(dot, obj, options)
    else if obj.Module == true
      dotParsing.setModuleSettings(dot.templateSettings);
      processModule(dot, obj, options)      
    else if obj.File == true
      dependencies.push(obj.getId())
      dotParsing.setFileSettings(dot.templateSettings);
      processFile(dot, obj, dependencies, options)
    cb(null, obj)
  unload: (cb) ->
    cb()
}