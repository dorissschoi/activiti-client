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
		
getDiagram = (contentUrl) ->
	opts = 
		headers:
			Authorization:	"Basic " + new Buffer("#{env.username}:#{env.password}").toString("base64")
			'Content-Type': 'image/png'
	req 'get', contentUrl, {}, opts

taskFilter = (task, username) ->
	ret = []
	_.each task.body.data, (record) ->
		myproc = _.union( 
			_.where(record.variables, {name: "createdBy", value: username}),
			_.where(record.variables, {name: "ao", value: username}),
			_.where(record.variables, {name: "ro", value: username}) 
		)
		nextHandler = _.findWhere(record.variables, {name: "nextHandler"})
		createdAt = _.findWhere(record.variables, {name: "createdAt"})
		_.extend record,
			nextHandler: nextHandler.value
			createdAt: createdAt.value					
		if myproc.length > 0
			_.extend record,
				includeMe: true
		ret.push record
	return ret
	
getDeploymentDetail = (procDef) ->
	req 'get', env.url.deployment procDef.deploymentId
		.then (result) ->
			procDef.deploymentDetails = result.body
			return procDef	

getInstanceDetail = (record) ->
	req 'get', "#{env.url.runninglist}?processInstanceId=#{record.id}"
		.then (tasks) ->
			task = tasks.body.data
			if _.isArray task
				task = task[0]
				
			_.extend record,
				name: task.name	
				createTime: task.createTime
			return record
											
module.exports =

	definition:
		diagram: (deploymentId) ->	
			req 'get', "#{env.url.deployment deploymentId}/resources"
				.then (processdefList) ->
					result = _.findWhere(processdefList.body,{type: 'resource'})
					getDiagram "#{env.url.deployment deploymentId}/resourcedata/#{result.id}"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "err: #{err}"
					return err
					
		list: (pageno) ->
			req 'get', "#{env.url.processdeflist}&start=#{pageno}"
				.then (defList) ->
					Promise.all _.map defList.body.data, getDeploymentDetail
					.then (result) ->
						val =
							count:		defList.body.total
							results:	result
						return val
				.catch (err) ->
					console.log "err: #{err}"
					return err
					
	instance:
		completeTask: (taskId, user) ->
			data =
				action: 'complete'
				variables: [{name: 'completedBy', value: user}]
			req 'post', "#{env.url.runninglist}/#{taskId}", data
		
		delete: (procInsId) ->
			req 'delete', "#{env.url.processinslist}/#{procInsId}"
		
		diagram: (procInsId) ->
			getDiagram "#{env.url.processinslist}/#{procInsId}/diagram"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "err: #{err}"
					return err
					
		historyTasklist: (pageno, procInsId) ->
			req 'get', "#{env.url.historytask}?processInstanceId=#{procInsId}&includeProcessVariables=true&start=#{pageno}"
				.then (result) ->
					val =
						count:		result.body.total
						results:	result.body.data
					return val
				.catch (err) ->
					console.log "err: #{err}"
					return err
			
		list: (pageno, user) ->
			req 'get', "#{env.url.processinslist}?includeProcessVariables=true&start=#{pageno}"
				.then (task) ->
					ret = taskFilter task, user.username
					Promise.all  _.map ret, getInstanceDetail
					.then (result) ->
						val =
							count:		task.body.total
							results:	result
						return val
				.catch (err) ->
					console.log "err: #{err}"
					return err
					
		start: (processdefID, user) ->
			data = 
				processDefinitionId: processdefID
				variables: [
					name: 'createdBy'
					value: user.username
				, 
					name: 'nextHandler'
					value: user.username
				,
					name: 'createdAt'
					type: 'date'
					value: new Date	
				]
			req 'post', env.url.processinslist, data
				.then (rst) ->
					return rst				
				.catch (err) ->
					console.log "err: #{err}"
					return err
		
						     		     