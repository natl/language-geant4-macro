{Emitter} = require 'event-kit'

class HoverEvent
  constructor: ->
     @emitter = new Emitter

  onDidChangeName: (callback) ->
     @emitter.on 'did-change-name', callback

  setName: (name) ->
     if name isnt @name
       @name = name
       @emitter.emit 'did-change-name', name
     @name

  destroy: ->
    @emitter.dispose()
