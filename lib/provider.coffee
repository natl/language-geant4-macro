fs = require 'fs'
path = require 'path'
endOfCommand = /\/$|\/[a-zA-Z0-9]+$/
wholeCommand = /^\/[a-zA-Z0-9\/]+/
unit = /\ [a-zA-Z0-9]+$/

module.exports =
  selector: '.text.geant4-macro'

  getSuggestions: ({editor, bufferPosition}) ->
    suggestions = null
    prefix = @getPrefix(editor, bufferPosition)
    if @isCommand
      suggestions = @getCommandCompletions({editor, bufferPosition}, prefix)
    if @isUnit
      suggestions = @getUnitCompletions(prefix)
    else
      suggestions = null
    suggestions

  getPrefix: (editor, bufferPosition) ->
    @resetMatches()
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    if line.match(endOfCommand) != null
      @isCommand = true
      line.match(endOfCommand)[0].split('/')[1]
    else if line.match(unit) != null
      @isUnit = true
      line.match(unit)[0].split(' ')[1]
    else
      ''

  resetMatches: ->
    @isCommand = false
    @isUnit = false

  getUnitCompletions: (prefix) ->
    suggestions = []
    for value in @unitCompletions["units"]
      if equalStringStarts(prefix, value) and (prefix != value)
        suggestion =
          text: value
          type: "constant"
        suggestions.push(suggestion)
    suggestions

  getCommandCompletions: ({editor, bufferPosition}, prefix) ->
    suggestions = []
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    line = line.match(wholeCommand)[0]
    prev = line.split('/')
    prev = prev[1..prev.length-2]
    n = prev.length
    thisLevel = @commandCompletions
    for p in prev
      thisLevel = thisLevel[p]
      if thisLevel == undefined
        return suggestions

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
    return suggestions

  loadCompletions: ->
    @loadCommandCompletions()
    @loadUnitCompletions()

  loadCommandCompletions: ->
    @commandCompletions = {}
    fs.readFile path.resolve(__dirname, '..', 'completions.json'), (error, content) =>
      @commandCompletions = JSON.parse(content) unless error?
      return

  loadUnitCompletions: ->
    @unitCompletions = {}
    fs.readFile path.resolve(__dirname, '..', 'units.json'), (error, content) =>
      @unitCompletions = JSON.parse(content) unless error?
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
