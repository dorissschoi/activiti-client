_ = require 'lodash'
assert = require('assert')

client = require('../index')
getProcessDefandDeploy = client.getProcessDefandDeploy

describe '#getProcessDefandDeploy', ->
	it 'Process Definitions and Deploy information list', (done) ->
		getProcessDefandDeploy 0
			.then (processdefList) ->
				console.log "rst: #{JSON.stringify processdefList.count}"
				assert.equal _.has(processdefList,'count'), true
		return done()
		
		
		