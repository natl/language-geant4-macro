provider = require './provider'
Tooltips = require './tooltips'

module.exports =
  tooltips: null

  activate: ->
    provider.loadCompletions()
    @tooltips = new Tooltips()

  getProvider: -> provider
