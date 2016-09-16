provider = require './provider'
tooltips = require './tooltips'

module.exports =
  activate: ->
    provider.loadCompletions()
    tooltips.initialize()

  getProvider: -> provider

  deactivite: ->
    tooltips.close()
