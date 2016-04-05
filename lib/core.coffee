path = require 'path'
{exec} = require 'atom-linter'
Root = require './linter-redpen.coffee'
rp = require 'request-promise'
fs = require 'fs'
urljoin = require 'url-join'

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

  convertToErrors: (JSONString) ->
    result = JSON.parse(JSONString)
    console.log "Result JSON ↓"
    console.log result
    return result[0]

  lint: (source, filePath, configurationXMLPath, scopeName) ->

    pathForRedPen = atom.config.get Root.PathForRedPenKey

    unless pathForRedPen?
      pathForRedPen = "redpen"
      return @lintCommand(pathForRedPen, source, filePath, configurationXMLPath, scopeName)

    if pathForRedPen.length isnt 0
      if pathForRedPen.indexOf "http" is 0
        return @lintServer(pathForRedPen, source, filePath, configurationXMLPath, scopeName)

    pathForRedPen = "redpen"
    return @lintCommand(pathForRedPen, source, filePath, configurationXMLPath, scopeName)



  lintServer: (server, source, filePath, configurationXMLPath, scopeName) ->
    console.log "core.coffee lintCommand method called"

    inputFormat = @detectedInputFormat scopeName

    console.log "InputFormat: " + inputFormat

    args = []
    configXMLContent = null

    args = args.concat(["-r", "json2", "-f", inputFormat, filePath])

    opt =
      uri: urljoin(server, "rest/document/validate")
      method: 'POST',
      form:
        document: source,
        lang: 'ja',
        format: 'json2',
        documentParser: inputFormat,
      json: true

    if configurationXMLPath != null && configurationXMLPath.length > 0
      args = args.concat(["-c", configurationXMLPath])
      configXMLContent = fs.readFileSync configurationXMLPath
      opt.form.config = configXMLContent

    console.log "server is " + server
    console.log "args is " + args
    console.log "opt is ↓"
    console.log opt

    return rp(opt)

  lintCommand: (pathForRedPen, source, filePath, configurationXMLPath, scopeName) ->
    console.log "core.coffee lintCommand method called"

    inputFormat = @detectedInputFormat scopeName

    console.log "InputFormat: " + inputFormat

    opt =
      throwOnStdErr: false,
      timeout: 30

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
      .then (result) =>
        json = @convertToErrors result
        return Promise.resolve(json)
