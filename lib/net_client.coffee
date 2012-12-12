class NetClient extends require('events').EventEmitter
  constructor: (@socket) ->
    @id = "#{@socket.remoteAddress}:#{@socket.remotePort}"
    @log = => console.log '[' + @id.green + '] ' + arguments[0]
    
    ['data', 'close', 'end', 'error'].forEach (event) =>
      @socket.on(event, => @['on_' + event](arguments...))
    
    process.nextTick => @emit('message', 'connected')
  
  on_data: (data) ->
    data = JSON.parse(data.toString())
    @emit('message', data.$c, data.$d)
  
  on_close: ->
  
  on_end: (had_error) ->
    @emit('message', 'disconnected')
  
  on_error: ->
    @log 'error'
    console.log arguments

module.exports = NetClient
