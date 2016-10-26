serverurl = "http://activiti:8080/activiti-rest/service"

module.exports =
	
	url:
		#/history/historic-task-instances?processInstanceId=7036&includeProcessVariables=true
		processinslist: "#{serverurl}/runtime/process-instances"
		processdeflist: "#{serverurl}/repository/process-definitions"
		#processdeflist: "#{serverurl}/repository/process-definitions?category=http://activiti.org/test"
		runninglist: "#{serverurl}/runtime/tasks"
		queryinslist: "#{serverurl}/query/process-instances"
		deployment: (id) ->
			"#{serverurl}/repository/deployments/#{id}"
			
	username:	'kermit'
	password:	'kermit'
	promise:
		timeout:	10000 # ms