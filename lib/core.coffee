path = require 'path'
{exec} = require 'atom-linter'
Root = require('./linter-redpen.coffee')

module.exports =
  scopes: [
    'source.gfm'
    'source.asciidoc'
    'text.html.textile'
    'text.plain'
    'text.plain.null-grammar'
    'plain'
  ]

  detectedInputFormat: (scopeName) ->
    switch scopeName
      when 'source.gfm' then "markdown"
      when 'text.html.textile' then "wiki"
      when 'source.asciidoc' then "asciidoc"
      else "plain"

  lint: (filePath, configurationXMLPath, scopeName) ->
    console.log "core.coffee lint method called"

    inputFormat = @detectedInputFormat scopeName

    console.log "InputFormat: " + inputFormat

    opt = {
      "throwOnStdErr" : false
      }

    pathForRedPen = atom.config.get Root.PathForRedPenKey

    unless pathForRedPen?
      pathForRedPen = "redpen"

    if pathForRedPen.length is 0
      pathForRedPen = "redpen"

    args = []

    if configurationXMLPath != null && configurationXMLPath.length > 0
      args = args.concat(["-c", configurationXMLPath])

    args = args.concat(["-r", "json2", "-f", inputFormat, filePath])

    command = pathForRedPen

    javaHome = atom.config.get Root.JavaHomeKey
    unless javaHome?
      command = "export JAVA_HOME='#{javaHome}'; #{pathForRedPen}"

    console.log "command is " + command
    console.log "args is " + args
    console.log "opt is " + opt

    return exec(command, args, opt)
