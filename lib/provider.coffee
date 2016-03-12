fs = require 'fs'
path = require 'path'
endOfCommand = /\/$|\/[a-zA-Z0-9]+$/
wholeCommand = /\/[a-zA-Z0-9\/]+/

module.exports =
  selector: '.text.geant4-macro'

  getSuggestions: ({editor, bufferPosition}) ->
    suggestions = null
    prefix = @getPrefix(editor, bufferPosition)
    if @isCommand
      suggestions = @getCommandCompletions({editor, bufferPosition}, prefix)
    else
      suggestions = null
    suggestions

  getPrefix: (editor, bufferPosition) ->
    @resetMatches()
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    if line.match(endOfCommand) != null
      @isCommand = true
      line.match(endOfCommand)[0].split('/')[1]
    else
      ''

  resetMatches: ->
    @isCommand = false

  getCommandCompletions: ({editor, bufferPosition}, prefix) ->
    suggestions = []
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    try
      line = line.match(wholeCommand)[0]
      prev = line.split('/')
      prev = prev[1..prev.length-2]
      n = prev.length
      thisLevel = @completions
      for p in prev
        thisLevel = thisLevel[p]
    catch error
      thisLevel = @completions

    values = Object.keys(thisLevel)
    for value in values
      if validPrefix(prefix, value) and (equalStringStarts(prefix, value) or (prefix == ""))
        try
          desc = thisLevel[value]['guidance']
        catch error
          desc = 'No guidance'
        suggestion =
          text: value
          type: 'value'
          description: desc
        suggestions.push(suggestion)
    suggestions

  loadCompletions: ->
    @completions = {}
    fs.readFile path.resolve(__dirname, '..', 'completions.json'), (error, content) =>
      @completions = JSON.parse(content) unless error?
      return

equalStringStarts = (str1, str2) ->
  for ii in [0..str1.length-2]
    if str1[ii] != str2[ii]
      return false
  return true

validPrefix = (str1, value) ->
  isGuidance = (str1 == "guidance")
  isParams = (str1 == "params")
  isValue = (str1 == value)
  if isGuidance or isParams or isValue
    return false
  else
    return true
