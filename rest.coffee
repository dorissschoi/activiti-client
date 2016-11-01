http = require 'needle'
Promise = require 'bluebird'
env = require './env.coffee'

options = 
	timeout:	env.promise.timeout
	
module.exports =
				
	get: (url, opts) ->
		new Promise (fulfill, reject) ->
			http.get url, opts, (err, res) ->
				#console.log "result:  #{JSON.stringify res.body}"
				if err
					return reject err
				fulfill res
	