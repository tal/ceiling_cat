redis = require 'redis'
express = require 'express'
client = null

app = module.exports = express.createServer();

ns = "ceilcat"

TTL = 15

app.configure ->
  app.use(express.static(__dirname + '/public'))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.logger())

  app.enable('jsonp callback')
  client = redis.createClient()

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
  app.use(express.errorHandler())

current_users_for_key = (key, cb) ->
  result = {ok:true, peeps:[], ttl: TTL, key: key}
  client.keys "#{ns}:#{key}:*", (err, replies) ->
    if err
      result.ok = false
      result.error = err
      cb(result)
    else
      multi = client.multi()
      for reply in replies
        multi.get reply, (err, val) ->
          [cc,key,usr] = reply.split(':')
          result.peeps.push
            name: usr
            value: val
      
      multi.exec (err, vals) ->
        cb(result)
  

app.get /^\/ceiling_cat\/saw\/?(.+)$/, (req,res) ->
  key = req.params.key || req.params[0] || req.query.key
  current_users_for_key key, (result) ->
    res.json(result)
  

app.all '/ceiling_cat/sees/:usr', (req,res) ->
  usr = req.params.usr
  key = req.params.key || req.query.key
  data = req.params.data || req.query.data || new Date().getTime()
  expires_in = req.params.ttl || TTL
  key = "#{ns}:#{key}:#{usr}"
  client.set key,  data, (err, replies) ->
    current_users_for_key req.params.key, (result) ->
      result.ttl = expires_in
      if err
        result.ok = false
        result.error = err
      else
        client.expire key, expires_in
      res.json(result)
  
app.listen(4574)