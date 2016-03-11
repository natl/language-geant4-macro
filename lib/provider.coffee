# Default start file
provider =
  selector: '.text.geant4-macro'

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)

    new Promise (resolve) ->
      suggestion =
        text: 'someText'
        replacementPrefix: prefix
      resolve([suggestion])

  getPrefix: (editor, bufferPosition) ->
    # Whatever your prefix regex might be
    regex = /[\w0-9_-]+$/

    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

    # Match the regex to the line, and return the match
    line.match(regex)?[0] or ''
