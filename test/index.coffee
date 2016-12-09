env = require('../env.coffee')
activiti = require('../index')(env)
expect = require('chai').expect

describe '#Process Definition list ', ->
	it 'Process Definition list ', (done) ->
		activiti.definition.list(0).then (rst) ->
			#console.log "rst: #{JSON.stringify rst.count}"
			expect(rst.results).to.exist
			done()
		return		
						
	
					