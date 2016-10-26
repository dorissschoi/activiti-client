rest = require('./rest.coffee')
_ = require 'lodash'
env = require './env.coffee'

req = (method, url, data) ->
	opts = 
		headers:
			Authorization:	"Basic " + new Buffer("#{env.username}:#{env.password}").toString("base64")
			'Content-Type': 'application/json'
		json: true
	rest[method] url, opts, data

module.exports =
	escape: (html) ->
		String(html).replace(/&/g, '&amp;').replace />/g, '&gt;'
		
	getProcessDefinitions: (startpage) ->
		#req "get", "#{env.url.processdeflist}?category=http://activiti.org/test&start=#{startpage}"
		req "get", "#{env.url.processdeflist}?category=http://activiti.org/test&start=1"
			.then (res) ->
				console.log "get result: #{JSON.stringify res.body}"
			.catch (err) ->
				console.log "err: #{err}"
		
		
		String(startpage).replace(/&amp;/g, '&').replace /&gt;/g, '>'
		     		     