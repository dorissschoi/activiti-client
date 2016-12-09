Activiti client
===============
A library providing utility resutful to Activiti.
## Installation
npm install activiti-client --save
## Config
```
module.exports =
	username:	username
	password:	password
	serverurl:	"http://activiti-server/activiti-rest/service"		
```
## Usage
```
env = require('../env.coffee')
activiti = require('../index')(env)
```
## API
- activiti.definition.create <filestream>
- activiti.definition.delete <deploymentId>
- activiti.definition.diagram <deploymentId>
- activiti.definition.findbyDepId <deploymentId>
- activiti.definition.getXML <deploymentId>
- activiti.definition.list <pageno>
- activiti.instance.create: <processdefinitionId> <user>
- activiti.instance.delete <processInstanceId>
- activiti.instance.deleteHistory <processInstanceId>
- activiti.instnace.diagram <processInstanceId>
- activiti.instance.haveTask <definitionId>
- activiti.instance.list <user> <pageno>
- activiti.instance.listHistory <pageno>
- activiti.task.update <TaskId> <data>
```
--data
"action" : "complete"
"variables" : []
```
- activiti.task.listHistory <instanceId> <pageno>
			
## Tests
npm test