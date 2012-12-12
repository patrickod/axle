require 'colors'

net = require 'net'
http = require 'http'

DOMAINS = []
if process.env.HUB_DOMAINS?
  Array::push.apply(DOMAINS, process.env.HUB_DOMAINS.split(','))
try
  name = require(process.cwd() + '/package').name
  DOMAINS.push("#{name}.localhost.dev") if name?

class AxleClient
  constructor: (@server) ->
    @log = -> console.log '[' + 'axle'.cyan + '] ' +  arguments[0]
    
    @server.once('listening', => @on_server_listening())
  
  send: (command, data) ->
    @client.write(JSON.stringify($c: command, $d: data))
  
  connect: ->
    @client = net.connect(port: 1313)
    ['connect', 'end', 'close', 'data', 'error'].forEach (event) =>
      @client.on(event, => @['on_' + event](arguments...))
  
  on_server_listening: ->
    @connect()
  
  on_connect: ->
    @send('register', DOMAINS.map (d) => {host: d, endpoint: @server.address().port})
    @log 'Listening on ' + DOMAINS.map((d) -> d.green).join(', ')
  
  on_end: ->
    
  
  on_close: ->
    setTimeout (=> @connect()), 1000
  
  on_error: (err) ->
    console.log '[ERROR] ' + err.code
    
    # if err.code is 'ECONNREFUSED'
    #   setTimeout (=> @connect()), 1000
  
  on_data: ->
    console.log 'data'
    console.log arguments


_createServer = http.createServer
http.createServer = ->
  server = _createServer.apply(http, arguments)
  new AxleClient(server)
  server
