fs = require 'fs'
path = require 'path'
$ = require 'jquery'

module.exports=
  selector: '.text.geant4-macro'
  theTooltip: null
  subscription: null

  initialize:  ->
    console.log("Activating Tooltips")
    # First, load in the command completions (runs asynchronously)
    @commandCompletions = {}
    fs.readFile path.resolve(__dirname, '..',
    'completions.json'), (error, content) =>
      @commandCompletions = JSON.parse(content) unless error?

    # Second, run the task to attach event listeners
    `$('body').on('hover', 'support', function () {console.log("bam");});`


  tooltipCreate: (element, command_chain) =>
    @tooltipDestroy()
    dictionary = @commandCompletions
    for command in command_chain when command in dictionary
      dictionary = dictionary[command]

    if "guidance" in dictionary
      thediv = document.createElement('div')
      @theTooltip = atom.tooltips.add(thediv,
        {title: dictionary["guidance"]})
    else
      @tooltipDestroy
      return

  tooltipDestroy: =>
    @theTooltip.dispose() if (@theTooltip)?

  close: =>
    @subscription.dispose()
