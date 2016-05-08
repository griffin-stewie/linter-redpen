{exec} = require 'atom-linter'
Root = require './linter-redpen.coffee'
rp = require 'request-promise'
fs = require 'fs'
urljoin = require 'url-join'

module.exports =
  scopes: [
    'source.gfm'
    'source.asciidoc'
    'text.tex.latex'
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
      when 'text.tex.latex' then "latex"
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

  resolveConfigLocation: (configurationXMLPath, targetFilePath) ->
    defaultConfigName = "redpen-conf"
    pathCandidates = []
    locale = atom.config.get Root.LocaleForConfigurationXMLFileKey
    console.log "Locale: " + locale

    REDPEN_HOME = process.env["REDPEN_HOME"]

    path = require 'path'

    if configurationXMLPath != null && configurationXMLPath.length > 0
      pathCandidates.push(configurationXMLPath)

    pathToTargetFileDir = path.dirname(targetFilePath)
    pathCandidates.push(path.join(pathToTargetFileDir, defaultConfigName + ".xml"))
    pathCandidates.push(path.join(pathToTargetFileDir, defaultConfigName + "-" + locale + ".xml"))

    for dir in atom.project.getDirectories()
      projPath = dir.getRealPathSync()
      pathCandidates.push(path.join(projPath, defaultConfigName + ".xml"))
      pathCandidates.push(path.join(projPath, defaultConfigName + "-" + locale + ".xml"))

    if REDPEN_HOME?
      pathCandidates.push(path.join(REDPEN_HOME, defaultConfigName + ".xml"))
      pathCandidates.push(path.join(REDPEN_HOME, defaultConfigName + "-" + locale + ".xml"))
      pathCandidates.push(path.join(REDPEN_HOME, "conf", defaultConfigName + ".xml"))
      pathCandidates.push(path.join(REDPEN_HOME, "conf", defaultConfigName + "-" + locale + ".xml"))

    resolved = @resolve(pathCandidates)
    console.log "resolved ConfigXML Path: " + resolved
    return resolved

  resolve: (pathCandidates) ->
    console.log pathCandidates
    for path in pathCandidates
      if fs.existsSync(path) and fs.statSync(path).isFile()
        return path

    return null

  lintServer: (server, source, filePath, configurationXMLPath, scopeName) ->
    console.log "core.coffee lintServer method called"

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

    xmlPath = @resolveConfigLocation(configurationXMLPath, filePath)
    if xmlPath != null && xmlPath.length > 0
      args = args.concat(["-c", xmlPath])
      configXMLContent = fs.readFileSync xmlPath
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
      timeout: 30 * 1000,
      throwOnStdErr: false

    args = []

    xmlPath = @resolveConfigLocation(configurationXMLPath, filePath)
    if xmlPath != null && xmlPath.length > 0
      args = args.concat(["-c", xmlPath])

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
