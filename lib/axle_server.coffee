require 'colors'

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

class Axle
  constructor: (port) ->
    throw new Error('Axle must take a port that is a number') unless port? and parseInt(port).toString() is port.toString()
    
    @log = -> console.log '[' + 'axle'.cyan + '] ' +  arguments[0]
    
    @server = require('http').createServer().listen(port)
    
    @routes = []
    @distribute = require('distribute')(@server)
    
    @distribute.use (req, res, next) =>
      [host, _x] = req.headers.host.split(':')
      
      for e in @routes
        if e.matches(host)
          console.log '[' + 'axle'.cyan + '] Routing ' + host.yellow + ' to ' + "#{e.target.host}:#{e.target.port}".green
          return next(e.target.port, e.target.host)
      
      @log 'No route for ' + host.red
      next()
  
  remove: (route) ->
    @routes = @routes.filter (r) =>
      if r.host is route.host and r.endpoint is route.endpoint
        @log 'Removed'.red + ' route ' + r.host + ' => ' + r.endpoint
        return false
      true
  
  serve: (host, endpoint) ->
    if host.indexOf('*') isnt -1
      @routes.push(new WildcardRoutePredicate(host, endpoint))
    else
      @routes.push(new RoutePredicate(host, endpoint))
    @log 'Added'.green + ' route ' + host + ' => ' + endpoint

module.exports = Axle
