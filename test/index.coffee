_ = require 'lodash'
assert = require('assert')

activiticlient = require('../index')

describe '#Process Definition list and deploy info', ->
	it 'Process Definition list and deploy info', (done) ->
		activiticlient.definition.list 0
			.then (rst) ->
				console.log "rst: #{JSON.stringify rst.count}"
				assert.equal _.has(rst,'count'), true
		return done()
		
		
describe '#Process Definition diagram', ->
	it 'Process Definition diagram', (done) ->
		activiticlient.definition.diagram 0
			.then (rst) ->
				assert.equal !_.isNull(rst), true
		return done()

describe '#Process instance list and detail info', ->
	it 'Process instance list and detail info', (done) ->
		activiticlient.instance.list 0
			.then (rst) ->
				console.log "rst: #{JSON.stringify rst.count}"
				assert.equal _.has(rst,'count'), true
		return done()	
		
describe '#Process instance diagram', ->
	it 'Process instance diagram', (done) ->
		activiticlient.instance.diagram 0
			.then (rst) ->
				assert.equal !_.isNull(rst), true
		return done()		