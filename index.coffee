exports.start_client = ->
  domains = []
  if process.env.AXLE_DOMAINS?
    Array::push.apply(domains, process.env.AXLE_DOMAINS.split(','))
  try
    name = require(process.cwd() + '/package').name
    domains.push("#{name}.localhost.dev") if name?
  
  AxleClient = require './lib/axle_client'
  AxleClient.DOMAINS = domains

exports.start_server = ->
  AxleServer = require './lib/axle_server'
  NetServer = require './lib/net_server'
  NetClient = require './lib/net_client'

  class AxleProtocol
    constructor: (@axle, socket) ->
      @client = new NetClient(socket)
      @client.on 'message', (command, data) =>
        @['on_' + command](data) if @['on_' + command]?
  
    on_connected: ->
    
  
    on_disconnected: ->
      if @routes?
        @axle.remove(r) for r in @routes
  
    on_register: (data) ->
      @routes = if Array.isArray(data) then data else [data]
    
      for r in @routes
        @axle.serve(r.host, r.endpoint)

  axle = new AxleServer(process.env.PORT || 3000)
  tcp_server = new NetServer(client_factory: (socket) -> new AxleProtocol(axle, socket)).listen(1313)
