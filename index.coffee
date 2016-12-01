rest = require('./rest.coffee')
_ = require 'underscore'
#sails = require('./env.coffee') for test 


req = (method, url, data, opts) ->
	#console.log "url result: #{url}"
	if _.isUndefined opts
		opts = 
			headers:
				Authorization:	"Basic " + new Buffer("#{sails.config.activiti.username}:#{sails.config.activiti.password}").toString("base64")
				'Content-Type': 'application/json'
			json: true
	rest[method] url, opts, data
		
getDiagram = (url) ->
	opts = 
		headers:
			Authorization:	"Basic " + new Buffer("#{sails.config.activiti.username}:#{sails.config.activiti.password}").toString("base64")
			'Content-Type': 'image/png'
	req 'get', url, {}, opts

getXML = (url) ->
	opts = 
		headers:
			Authorization:	"Basic " + new Buffer("#{sails.config.activiti.username}:#{sails.config.activiti.password}").toString("base64")
		parse: 'XML'
		
	req 'get', url, {}, opts
		
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
	req 'get', sails.config.activiti.url.deployment procDef.deploymentId
		.then (result) ->
			procDef.deploymentDetails = result.body
			return procDef	

getInstanceDetail = (record) ->
	req 'get', "#{sails.config.activiti.url.runninglist}?processInstanceId=#{record.id}"
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
			req 'get', "#{sails.config.activiti.url.deployment deploymentId}/resources"
				.then (processdefList) ->
					result = _.findWhere(processdefList.body,{type: 'resource'})
					getDiagram "#{sails.config.activiti.url.deployment deploymentId}/resourcedata/#{result.id}"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "def diagram err: #{err}"
					return err

		deployXML: (data) ->
			opts = 
				headers:
					Authorization:	"Basic " + new Buffer("#{sails.config.activiti.username}:#{sails.config.activiti.password}").toString("base64")
					'Content-Type': 'multipart/form-data'
				multipart: true
						
			req 'post', "#{sails.config.activiti.url.deployment ''}", data, opts

		delDeployment: (deploymentId) ->
			req 'delete', sails.config.activiti.url.deployment deploymentId
				
					
		downloadXML: (deploymentId) ->
			req 'get', "#{sails.config.activiti.url.deployment deploymentId}/resources"
				.then (processdefList) ->
					result = _.findWhere(processdefList.body,{type: 'processDefinition'})
					getXML "#{sails.config.activiti.url.deployment deploymentId}/resourcedata/#{result.id}"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "downloadXML err: #{err}"
					return err

		getID: (depId) ->
			req 'get', "#{sails.config.activiti.url.processdeflist}?deploymentId=#{depId}&sort=id"
												
		list: (pageno) ->
			
			req 'get', "#{sails.config.activiti.url.processdeflist}?category=http://activiti.org/test&start=#{pageno}"
				.then (defList) ->
					Promise.all _.map defList.body.data, getDeploymentDetail
					.then (result) ->
						val =
							count:		defList.body.total
							results:	result
						return val
				.catch (err) ->
					console.log "list err: #{err}"
					return err
					
	instance:
		#complete 
		update: (taskId, data) ->
			req 'post', "#{sails.config.activiti.url.runninglist}/#{taskId}", data
			
		delete: (procInsId) ->
			req 'delete', "#{sails.config.activiti.url.processinslist}/#{procInsId}"
		
		delhistoryProc: (procInsId) ->
			req 'delete', "#{sails.config.activiti.url.historyproc}/#{procInsId}"
			
		diagram: (procInsId) ->
			getDiagram "#{sails.config.activiti.url.processinslist}/#{procInsId}/diagram"
				.then (stream) ->
					return stream.raw
				.catch (err) ->
					console.log "ins diagram err: #{err}"
					return err

		haveTask: (defId) ->
			data =
				processDefinitionId: defId			
			req 'post', sails.config.activiti.url.queryinslist, data
		
		historyProclist: (pageno, procInsId) ->
			req 'get', "#{sails.config.activiti.url.historyproc}?includeProcessVariables=true&finished=true&start=#{pageno}"
				.then (result) ->
					val =
						count:		result.body.total
						results:	result.body.data
					return val
				.catch (err) ->
					console.log "historyProclist err: #{err}"
					return err

		historyTasklist: (pageno, procInsId) ->
			req 'get', "#{sails.config.activiti.url.historytask}?processInstanceId=#{procInsId}&includeTaskLocalVariables=true&includeProcessVariables=true&start=#{pageno}"
				.then (result) ->
					val =
						count:		result.body.total
						results:	result.body.data
					return val
				.catch (err) ->
					console.log "historyTasklist err: #{err}"
					return err
			
		list: (pageno, user) ->
			req 'get', "#{sails.config.activiti.url.processinslist}?includeProcessVariables=true&start=#{pageno}"
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
					return err
		#start			
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
			req 'post', sails.config.activiti.url.processinslist, data
				.then (rst) ->
					return rst				
				.catch (err) ->
					console.log "start err: #{err}"
					return err
		
						     		     