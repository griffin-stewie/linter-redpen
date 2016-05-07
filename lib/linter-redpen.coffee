{CompositeDisposable} = require 'atom'

module.exports = LinterRedpen =
  PathForRedPenKey: "linter-redpen.pathForRedPen"
  PathForConfigurationXMLFileKey: "linter-redpen.pathForConfigurationXMLFile"
  LocaleForConfigurationXMLFileKey: "linter-redpen.localeForConfigurationXMLFile"
  JavaHomeKey: "linter-redpen.JAVA_HOME"

  config:
    pathForRedPen:
      title: 'Path for RedPen CLI'
      description: 'CLI version should be v1.5.4 or higher. If you prefer to use RedPen server than CLI. You can set your RedPen Server endpoint on Path for RedPen CLI fieald.'
      type: 'string'
      default: ""
      order: 10
    pathForConfigurationXMLFile:
      title: 'Path for Configuration XML File'
      description: ''
      type: 'string'
      default: ''
      order: 20
    localeForConfigurationXMLFile:
      title: 'Locale for Configuration XML File'
      description: 'uses auto detect configuration XML file'
      type: 'string'
      default: 'ja'
      enum: ['ja', 'en']
      order: 25
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
