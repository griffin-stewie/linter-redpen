Core = require('./core.coffee')
path = require('path')
Root = require('./linter-redpen.coffee')

module.exports = new class # This only needs to be a class to bind lint()

  name: 'RedPen'
  grammarScopes: Core.scopes
  scope: "file"
  lintOnFly: true

  # coffeelint: disable=no_unnecessary_fat_arrows
  lint: (TextEditor) =>
    console.log 'Linter RedPen Lint Executed'
    filePath = TextEditor.getPath()
    if filePath

      source = TextEditor.getText()
      scopeName = TextEditor.getGrammar().scopeName

      pathForRedPen = atom.config.get Root.PathForRedPenKey

      unless pathForRedPen?
        pathForRedPen = "redpen"

      if pathForRedPen.length is 0
        pathForRedPen = "redpen"

      configurationXMLPath = atom.config.get Root.PathForConfigurationXMLFileKey

      return Core.lint(source, filePath, configurationXMLPath, scopeName)
      .then (result) =>
        # console.log result
        errors = result.errors

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
