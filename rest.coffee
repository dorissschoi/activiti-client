http = require 'needle'
Promise = require 'bluebird'
	
module.exports =
				
	get: (url, opts) ->
		new Promise (fulfill, reject) ->
			http.get url, opts, (err, res) ->
				#console.log "result:  #{JSON.stringify res.body}"
				if err
					return reject err
				fulfill res
	
	post: (url, opts, data) ->
		new Promise (fulfill, reject) ->
			http.post url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res

	put: (url, opts, data) ->
		new Promise (fulfill, reject) ->
			http.put url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res
					
	delete: (url, opts) ->
		new Promise (fulfill, reject) ->
			http.delete url, {}, opts, (err, res) ->
				if err
					return reject err
				fulfill res