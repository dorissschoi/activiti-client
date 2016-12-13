rest = require('./rest.coffee')
_ = require 'underscore'
					
module.exports  = (opts = {}) ->	
	req = (method, url, data, headeropts) ->
		console.log "url: #{url}"
		if _.isUndefined headeropts
			headeropts = 
				headers:
					Authorization:	"Basic " + new Buffer("#{opts.username}:#{opts.password}").toString("base64")
					'Content-Type': 'application/json'
				json: true
		rest[method] url, headeropts, data

	getDeploymentDetail = (procDef) ->
		req 'get', "#{opts.serverurl}/repository/deployments/#{procDef.deploymentId}"
			.then (result) ->
				procDef.deploymentDetails = result.body
				return procDef	

	getInstanceDetail = (record) ->
		req 'get', "#{opts.serverurl}/runtime/tasks?processInstanceId=#{record.id}"
			.then (tasks) ->
				task = tasks.body.data
				if _.isArray task
					task = task[0]
					
				_.extend record,
					name: task.name	
					createTime: task.createTime
				return record

	getXML = (url) ->
		opts = 
			headers:
				Authorization:	"Basic " + new Buffer("#{opts.username}:#{opts.password}").toString("base64")
			parse: 'XML'
			
		req 'get', url, {}, opts
	
	#
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
				
	getDiagram = (url) ->
		headeropts = 
			headers:
				Authorization:	"Basic " + new Buffer("#{opts.username}:#{opts.password}").toString("base64")
				'Content-Type': 'image/png'
		req 'get', url, {}, headeropts
					
	definition:
		create: (fs) ->
			data = 
				file: { file: fs, content_type: 'multipart/form-data' }
			headeropts = 
				headers:
					Authorization:	"Basic " + new Buffer("#{sails.config.activiti.username}:#{sails.config.activiti.password}").toString("base64")
					'Content-Type': 'multipart/form-data'
				multipart: true
						
			req 'post', "#{opts.serverurl}/repository/deployments/", data, headeropts

		findbyDepId: (deploymentId) ->
			req 'get', "#{opts.serverurl}/repository/process-definitions?deploymentId=#{deploymentId}&sort=id"

		delete: (deploymentId) ->
			req 'delete', "#{opts.serverurl}/repository/deployments/#{deploymentId}"
					
		diagram: (deploymentId) ->	
			req 'get', "#{opts.serverurl}/repository/deployments/#{deploymentId}/resources"
				.then (processdefList) ->
					result = _.findWhere(processdefList.body,{type: 'resource'})
					getDiagram "#{opts.serverurl}/repository/deployments/#{deploymentId}/resourcedata/#{result.id}"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "def diagram err: #{err}"
					Promise.reject err
																					
		list: (pageno) ->
			req 'get', "#{opts.serverurl}/repository/process-definitions?category=http://activiti.org/test&start=#{pageno}"
				.then (defList) ->
					Promise.all _.map defList.body.data, getDeploymentDetail
					.then (result) ->
						val =
							count:		defList.body.total
							results:	result
						return val
				.catch (err) ->
					console.log "list err: #{err}"
					Promise.reject err
					
		getXML: (deploymentId) ->
			req 'get', "#{opts.serverurl}/repository/deployments/#{deploymentId}/resources"
				.then (processdefList) ->
					result = _.findWhere(processdefList.body,{type: 'processDefinition'})
					getXML "#{opts.serverurl}/repository/deployments/#{deploymentId}/resourcedata/#{result.id}"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "downloadXML err: #{err}"
					Promise.reject err
					
	instance:
		#Start a process instance
		create: (processdefID, user) ->
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
			req 'post', "#{opts.serverurl}/runtime/process-instances", data
				.then (rst) ->
					return rst				
				.catch (err) ->
					console.log "start err: #{err}"
					Promise.reject err
				
		delete: (procInsId) ->
			req 'delete', "#{opts.serverurl}/runtime/process-instances/#{procInsId}"

		deleteHistory: (procInsId) ->
			req 'delete', "#{opts.serverurl}/history/historic-process-instances/#{procInsId}"

		diagram: (procInsId) ->
			getDiagram "#{opts.serverurl}/runtime/process-instances/#{procInsId}/diagram"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "ins diagram err: #{err}"
					Promise.reject err	

		haveTask: (defId) ->
			data =
				processDefinitionId: defId			
			req 'post', "#{opts.serverurl}/query/process-instances", data
										
		#user involved instance
		listUser: (user, pageno) ->
			req 'get', "#{opts.serverurl}/runtime/process-instances?includeProcessVariables=true&start=#{pageno}"
				.then (task) ->
					ret = taskFilter task, user.username
					Promise.all  _.map ret, getInstanceDetail
					.then (result) ->
						val =
							count:		task.body.total
							results:	result
						return val
				.catch (err) ->
					console.log "list err: #{err}"
					Promise.reject err			

		list: (pageno) ->
			req 'get', "#{opts.serverurl}/runtime/process-instances?includeProcessVariables=true&start=#{pageno}"
				.then (task) ->
					Promise.all  _.map task.body.data, getInstanceDetail
					.then (result) ->
						val =
							count:		task.body.total
							results:	result
						console.log "listall : #{JSON.stringify val}"	
						return val
				.catch (err) ->
					console.log "listall err: #{err}"
					Promise.reject err		
					
		listHistory: (pageno) ->
			req 'get', "#{opts.serverurl}/history/historic-process-instances?includeProcessVariables=true&finished=true&start=#{pageno}"
				.then (result) ->
					val =
						count:		result.body.total
						results:	result.body.data
					return val
				.catch (err) ->
					console.log "historyProclist err: #{err}"
					Promise.reject err
										
	task:
		update: (taskId, data) ->
			req 'post', "#{opts.serverurl}/runtime/tasks/#{taskId}", data

		listHistory: (procInsId, pageno) ->
			req 'get', "#{opts.serverurl}/history/historic-task-instances?processInstanceId=#{procInsId}&includeTaskLocalVariables=true&includeProcessVariables=true&start=#{pageno}"
				.then (result) ->
					val =
						count:		result.body.total
						results:	result.body.data
					return val
				.catch (err) ->
					console.log "historyTasklist err: #{err}"
					Promise.reject err			
									     		     