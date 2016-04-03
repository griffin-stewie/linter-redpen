{CompositeDisposable} = require 'atom'

module.exports = LinterRedpen =
  PathForRedPenKey: "linter-redpen.pathForRedPen"
  PathForConfigurationXMLFileKey: "linter-redpen.pathForConfigurationXMLFile"
  JavaHomeKey: "linter-redpen.JAVA_HOME"

  config:
    pathForRedPen:
      title: 'Path for RedPen CLI'
      description: 'Requires v1.5.4 or higher'
      type: 'string'
      default: ""
      order: 10
    pathForConfigurationXMLFile:
      title: 'Path for Configuration XML File'
      description: ''
      type: 'string'
      default: ''
      order: 20
    JAVA_HOME:
      title: 'JAVA_HOME Path'
      description: ''
      type: 'string'
      default: ''
      order: 30

  activate: (state) ->
    console.log "Linter Redpen Activate"
    require('atom-package-deps').install('linter-redpen')

  provideLinter: ->
    console.log "Linter Redpen provideLinter"
    return require('./plus-linter.coffee')
