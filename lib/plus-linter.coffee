Core = require('./core.coffee')
path = require('path')
Root = require('./linter-redpen.coffee')

module.exports = new class # This only needs to be a class to bind lint()
  
  name: 'RedPen'
  grammarScopes: Core.scopes
  scope: "file"
  lintOnFly: true

  parse: (JSONString) ->
    result = JSON.parse(JSONString)
    console.log "Result JSON ↓"
    console.log result
    return result[0].errors

  # coffeelint: disable=no_unnecessary_fat_arrows
  lint: (TextEditor) =>
    console.log 'Linter RedPen Lint Executed'
    filePath = TextEditor.getPath()
    if filePath
      scopeName = TextEditor.getGrammar().scopeName

      configurationXMLPath = atom.config.get Root.PathForConfigurationXMLFileKey

      return Core.lint(filePath, configurationXMLPath, scopeName)
      .then (result) =>
        errors = @parse result

        msgs = []
        for lineError in errors
          # console.log lineError
          for e in lineError.errors
            start = [e.position.start.line - 1, e.position.start.offset]
            end = [e.position.end.line - 1, e.position.end.offset]
            range = [start, end]
            msgs.push {
              type: 'Error'
              text: e.message
              filePath: filePath
              range: range
            }

        console.log msgs

        return Promise.resolve(msgs)

    return Promise.resolve([])
