fs = require 'fs'
path = require 'path'
# HoverEvent = require('./hover-event')

class Tooltips
  scope: 'text.geant4-macro'
  scopeName: "text geant4-macro"
  theTooltip: null
  subscription: null
  hoverEvent: null

  constructor: ->
    # @hoverEvent = new hoverEvent(@scope, ".support.function")
    console.log("Activating Tooltips")
    # First, load in the command completions (runs asynchronously)
    @commandCompletions = {}
    fs.readFile path.resolve(__dirname, '..',
    'completions.json'), (error, content) =>
      @commandCompletions = JSON.parse(content) unless error?

    atom.views.getView(atom.workspace).addEventListener 'mousemove', (evt) =>
      @mouseMove(evt)

  mouseMove: (evt) =>
    isScope = (evt.path[1].className == @scopeName)
    isFunction = (evt.path[0].className == "support function")
    if isScope && isFunction
      @tooltipCreate(evt)
    else if @theTooltip?
      @tooltipDestroy()

  tooltipCreate: (evt) =>
    # console.log(evt.path)
    # console.log(evt.path[1])
    path = []
    for node in evt.path[1].childNodes
      hasScope = (node.className == "support class")
      hasFunction = (node.className == "support function")
      console.log(node.className)
      console.log(hasScope)
      console.log(hasFunction)
      if hasScope || hasFunction
        # don't forget regex to remove trailing spaces
        path.push(node.textContent.replace(/\s+/g, ''))

    @tooltipDestroy()
    dictionary = @commandCompletions
    for command in path
      dictionary = dictionary[command]
      return if (dictionary == undefined)

    if dictionary.guidance != undefined
      text = dictionary.guidance
      if dictionary.params.length > 0
        text = text + "<ol>"
        for param in dictionary.params
          text = text + "<li>"
          text = text + param.name + " " if param.name?
          text = text + "type: " + param.type + " " if param.type?
          text = text + "default: " + param.default + " " if param.default?
          text = text + "(optional)" if param.omit == "True"
          text = text + "</li>"
        text = text + "</ol>"
      console.log(text)
      @theTooltip = atom.tooltips.add(evt.path[0],
        {title: text, trigger: "manual", placement: "bottom",
        template: '<div class="tooltip" role="tooltip">
                   <div class="tooltip-arrow"></div>
                   <div class="tooltip-inner" style="max-width: 300px !important; white-space: normal !important; text-align: left"></div></div>'})


  tooltipDestroy: =>
    @theTooltip.dispose() if (@theTooltip)?

  close: =>
    @subscription.dispose()
    @hoverEvent.destroy()


module.exports = Tooltips
