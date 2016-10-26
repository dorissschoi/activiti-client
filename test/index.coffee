should = require('chai').should()
client = require('../index')
escape = client.escape
unescape = client.unescape
getProcessDefinitions = client.getProcessDefinitions

#env = require '../../activiti.coffee'

describe '#escape', ->
	it 'converts & into &amp;', ->
		escape('&').should.equal('&amp;')


describe '#getProcessDefinitions', ->
	it 'converts &amp; into &', ->
		getProcessDefinitions('&amp;').should.equal('&')
