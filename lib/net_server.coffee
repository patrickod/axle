net = require 'net'

class NetServer
  constructor: (opts) ->
    @clients = {}
    
    if opts.client?
      @client_factory = (socket) =>
        new opts.client(socket)
    else if opts.client_factory?
      @client_factory = opts.client_factory
    else
      throw new Error('NetServer constructor takes either a client or client_factory')
    
    @server = net.createServer (s) => @on_connection(s)
  
  on_connection: (socket) ->
    client = @client_factory(socket)
    @clients[client.id] = client
    socket.on 'close', => @on_close(client)
  
  on_close: (client) ->
    delete @clients[client.id]
  
  listen: ->
    @server.listen(arguments...)

module.exports = NetServer
