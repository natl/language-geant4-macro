provider = require './provider'
tooltips = require './tooltips'

module.exports =
  activate: ->
    provider.loadCompletions()

  getProvider: -> provider
