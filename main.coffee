dot = require('dot')

module.exports = {
  load: (cb) ->
    cb()
  oncall: (obj, params, cb) ->
    if obj.File != true
      cb(new Error("The template plugin can only be applied to Files"))
      return
    try
      ct = obj.getCurrentContent()
      output = dot.compile(ct.content || '')
      obj.updateContent({
        extension:'__template',
        content:output
      })
      cb(null, obj)
    catch e
      cb(e)
  unload: (cb) ->
    cb()
}