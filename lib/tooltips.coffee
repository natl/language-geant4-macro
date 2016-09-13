{CompositeDisposable} = require 'atom'

module.exports =
  selector: '.text.geant4-macro'
  subscriptions: new CompositeDisposable
  theTooltip: null

  activate: =>
    @commandCompletions = {}
    fs.readFile path.resolve(__dirname, '..',
    'completions.json'), (error, content) =>
      @commandCompletions = JSON.parse(content) unless error?
    # @subscriptions add # add a watcher for text changes to get new class occurrences
    return

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

  deactivate: =>
    @subscriptions.dispose()
