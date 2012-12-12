require 'colors'

net = require 'net'
http = require 'http'
portfinder = require 'portfinder'

class AxleClient
  constructor: (@server) ->
    @log = -> console.log '[' + 'axle'.cyan + '] ' +  arguments[0]
    
    @server.once('listening', => @on_server_listening())
    @server.on('error', => @on_server_error(arguments...))
  
  send: (command, data) ->
    @client.write(JSON.stringify($c: command, $d: data))
  
  connect: ->
    @client = net.connect(port: 1313)
    ['connect', 'end', 'close', 'data', 'error'].forEach (event) =>
      @client.on(event, => @['on_' + event](arguments...))
  
  on_server_listening: ->
    @log 'Listening on port ' + @server.address().port.toString().green
    @connect()
  
  on_server_error: (err) ->
    if err.code is 'EADDRINUSE'
      portfinder.getPort (e, port) =>
        return console.error(e.stack) if e?
        @server.listen(port)
  
  on_connect: ->
    @send('register', AxleClient.DOMAINS.map (d) => {host: d, endpoint: @server.address().port})
    @log 'Listening on ' + AxleClient.DOMAINS.map((d) -> d.green).join(', ')
  
  on_end: ->
    
  
  on_close: ->
    setTimeout (=> @connect()), 1000
  
  on_error: (err) ->
    @log 'Error connecting to axle: ' + err.code.red
  
  on_data: ->
    console.log 'data'
    console.log arguments


_createServer = http.createServer
http.createServer = ->
  server = _createServer.apply(http, arguments)
  new AxleClient(server)
  server

module.exports = AxleClient
