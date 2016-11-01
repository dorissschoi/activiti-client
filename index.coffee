rest = require('./rest.coffee')
_ = require 'lodash'
env = require('./env')

req = (method, url, data, opts) ->
	#console.log "url result: #{url}"
	if _.isUndefined opts
		opts = 
			headers:
				Authorization:	"Basic " + new Buffer("#{env.username}:#{env.password}").toString("base64")
				'Content-Type': 'application/json'
			json: true
	rest[method] url, opts, data

getDeploymentDetails = (procDef) ->
	req 'get', env.url.deployment procDef.deploymentId
		.then (result) ->
			procDef.deploymentDetails = result.body
			return procDef
		
getProcDefDiagram = (contentUrl) ->
	opts = 
		headers:
			Authorization:	"Basic " + new Buffer("#{env.username}:#{env.password}").toString("base64")
			'Content-Type': 'image/png'
	req "get", contentUrl, {}, opts
						
module.exports =

	#Process Definition
	getProcessDefandDeploy: (startpage) ->
		req "get", "#{env.url.processdeflist}&start=#{startpage}"
			.then (defList) ->
				
				Promise.all _.map defList.body.data, getDeploymentDetails
					.then (result) ->
						val =
							count:		defList.body.total
							results:	result
						return val
			.catch (err) ->
				console.log "err: #{err}"
				return err
		
	getDefinitionDiagram: (deploymentId) ->
		req 'get', "#{env.url.deployment deploymentId}/resources"
			.then (processdefList) ->
				result = _.findWhere(processdefList.body,{type: 'resource'})
				getProcDefDiagram "#{env.url.deployment deploymentId}/resourcedata/#{result.id}"
			.then (stream) ->
				return stream.raw
			.catch (err) ->
				console.log "err: #{err}"
				return err
			

				     		     