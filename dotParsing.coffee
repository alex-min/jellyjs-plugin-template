module.exports = {
  setModuleSettings : (t) ->
      t.evaluate =    /\[\[([\s\S]+?\]?)\]\]/g
      t.interpolate = /\[\[=([\s\S]+?)\]\]/g
      t.encode =      /\[\[!([\s\S]+?)\]\]/g
      t.use =         /\[\[#([\s\S]+?)\]\]/g
      t.useParams =   /(^|[^\w$])def(?:\.|\[[\'\"])([\w$\.]+)(?:[\'\"]\])?\s*\:\s*([\w$\.]+|\"[^\"]+\"|\'[^\']+\'|\[[^\]]+\])/g
      t.define =      /\[\[##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\]\]/g
      t.defineParams = /^\s*([\w$]+):([\s\S]+)/
      t.conditional = /\[\[\?(\?)?\s*([\s\S]*?)\s*\]\]/g
      t.iterate =     /\[\[~\s*(?:\]\]|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\]\])/g      
  setFileSettings: (t) ->
      t.evaluate =    /\{\{([\s\S]+?\}?)\}\}/g
      t.interpolate = /\{\{=([\s\S]+?)\}\}/g
      t.encode =      /\{\{!([\s\S]+?)\}\}/g
      t.use =         /\{\{#([\s\S]+?)\}\}/g
      t.useParams =   /(^|[^\w$])def(?:\.|\[[\'\"])([\w$\.]+)(?:[\'\"]\])?\s*\:\s*([\w$\.]+|\"[^\"]+\"|\'[^\']+\'|\{[^\}]+\})/g
      t.define =      /\{\{##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\}\}/g
      t.defineParams = /^\s*([\w$]+):([\s\S]+)/
      t.conditional = /\{\{\?(\?)?\s*([\s\S]*?)\s*\}\}/g
      t.iterate =     /\{\{~\s*(?:\}\}|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\}\})/g
}