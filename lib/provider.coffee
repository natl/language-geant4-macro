fs = require 'fs'
path = require 'path'

endOfCommand = /\/$|\/[a-zA-Z0-9]+$/
wholeCommand = /^\/[a-zA-Z0-9\/]*$/
unit = /\ [a-zA-Z0-9]+$/

module.exports =
  selector: '.text.geant4-macro'

  getSuggestions: ({editor, bufferPosition}) ->
    suggestions = null
    prefix = @getPrefix(editor, bufferPosition)
    if @isCommand is true
      suggestions = @getCommandCompletions({editor, bufferPosition}, prefix)
    else if @isUnit is true
      suggestions = @getConstCompletions(prefix)
    else
      suggestions = null
    suggestions

  getPrefix: (editor, bufferPosition) ->
    @resetMatches()
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    spl = line.split(' ')
    line = spl[spl.length - 1]

    if line.match(endOfCommand) != null and line.match(/^\//) != null
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

  getConstCompletions: (prefix) ->
    suggestions = []
    for value in @constantCompletions["units"]
      if equalStringStarts(prefix, value) and (prefix != value)
        suggestion =
          text: value
          type: "constant"
        suggestions.push(suggestion)

    for value in @constantCompletions["bool"]
      if equalStringStarts(prefix, value) and (prefix != value)
        suggestion =
          text: value
          type: "keyword"
        suggestions.push(suggestion)
    suggestions

  getCommandCompletions: ({editor, bufferPosition}, prefix) ->
    suggestions = []
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    spl = line.split(' ')
    line = spl[spl.length - 1]  # Seperate at spaces
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
    for value in values when validPrefix(prefix, value)
      if (equalStringStarts(prefix, value) or (prefix == ""))
        try
          desc = thisLevel[value]['guidance']
          type = 'function'
          if desc == undefined
            type = 'class'
            desc = ''
        catch error
          desc = ''
          type = 'class'
        suggestion =
          text: value
          type: type
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
    @constantCompletions = {}
    fs.readFile path.resolve(__dirname, '..', 'constants.json'), (error, content) =>
      @constantCompletions = JSON.parse(content) unless error?
      return

equalStringStarts = (str1, str2) ->
  for ii in [0..str1.length-2]
    if str1[ii] != str2[ii]
      return false
  return true

validPrefix = (prefix, value) ->
  isGuidance = (prefix == "guidance")
  isParams = (prefix == "params")
  isValue = (prefix == value)
  if isGuidance or isParams or isValue
    return false
  else
    return true
