serverurl = "http://activiti:8080/activiti-rest/service"

module.exports =
	config:
		activiti : 
			url:  
				processinslist: "#{serverurl}/runtime/process-instances"
				processdeflist: "#{serverurl}/repository/process-definitions"
				runninglist: "#{serverurl}/runtime/tasks"
				queryinslist: "#{serverurl}/query/process-instances"
				deployment: (id) ->
					"#{serverurl}/repository/deployments/#{id}"
				historytask: "#{serverurl}/history/historic-task-instances"	
				historyproc: "#{serverurl}/history/historic-process-instances"
			username:	'kermit'
			password:	'kermit'
			promise:
				timeout:	10000 # ms				
					