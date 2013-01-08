events = require 'events'

parse_endpoint = (endpoint) ->
  if parseInt(endpoint).toString() is endpoint.toString()
    target_host = 'localhost'
    target_port = parseInt(endpoint)
  else
    [target_host, target_port] = endpoint.split(':')
    target_port = if target_port? then parseInt(target_port) else 80
  
  {host: target_host, port: target_port}

class RoutePredicate
  constructor: (@host, @endpoint) ->
    @target = parse_endpoint(@endpoint)
    
  matches: (host) ->
    @host is host

class WildcardRoutePredicate extends RoutePredicate
  constructor: ->
    super
    @rx = new RegExp('^' + @host.replace(/\./g, '\\.').replace(/\*/g, '.*') + '$')
    
  matches: (host) ->
    @rx.test(host)

class Axle extends events.EventEmitter
  constructor: (@port) ->
    throw new Error('Axle must take a port that is a number') unless port? and parseInt(port).toString() is port.toString()
    
    @log = -> console.log '[' + 'axle'.cyan + '] ' +  arguments[0]
  
  initialize: ->
    return if @server?
    
    @server = require('http').createServer()
    @server.on 'listening', => @emit('listening', @server.address())
    @server.on 'error', (err) => @emit('error', err)
    
    @routes = []
    @distribute = require('distribute')(@server)
    @distribute.use (req, res, next) =>
      try
        [host, _x] = req.headers.host.split(':')
      
        for e in @routes
          if e.matches(host)
            @emit('route:match', host, e.target)
            return next(e.target.port, e.target.host)
        
        @emit('route:miss', host)
        next()
      catch e
        next(e)
  
  start: ->
    return if @server?
    @initialize()
    @server.listen(@port)
  
  stop: ->
    @server.close()
    delete @server
  
  remove: (route) ->
    @routes = @routes.filter (r) =>
      if r.host is route.host and r.endpoint is route.endpoint
        @emit('route:remove', r)
        return false
      true
  
  serve: (host, endpoint) ->
    if host.indexOf('*') isnt -1
      @routes.push(new WildcardRoutePredicate(host, endpoint))
    else
      @routes.push(new RoutePredicate(host, endpoint))
    @emit('route:add', {host: host, endpoint: endpoint})

module.exports = Axle
