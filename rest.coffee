http = require 'needle'
Promise = require 'bluebird'
env = require './env.coffee'

options = 
	timeout:	env.promise.timeout
	
module.exports =
				
	get: (url, opts) ->
		console.log "get..."
		console.log "req:  #{JSON.stringify opts}"
		console.log "url:  #{url}"
		new Promise (fulfill, reject) ->
			http.get url, opts, (err, res) ->
				console.log "result:  #{JSON.stringify res.body}"
				if err
					return reject err
				fulfill res
	###			
	post: (token, url, opts, data) ->
		new Promise (fulfill, reject) ->
			if _.isUndefined opts
				opts = _.extend options, sails.config.http.opts,
					headers:
						Authorization:	"Bearer #{token}"
						
			http.post url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res

	delete: (token, url, opts) ->
		new Promise (fulfill, reject) ->
			if _.isUndefined opts
				opts = _.extend options, sails.config.http.opts,
					headers:
						Authorization:	"Bearer #{token}"
						
			http.delete url, {}, opts, (err, res) ->
				if err
					return reject err
				fulfill res
									
	push: (token, roster, msg) ->
		param =
			roster: roster
			msg:	msg
		data = _.mapValues sails.config.push.data, (value) ->
			_.template value, param
		@post token, sails.config.push.url, 
			users:	[roster.createdBy.email]
			data:	data
	###			
