should = require('chai').should()
scapegoat = require('../index')
escape = scapegoat.escape
unescape = scapegoat.unescape
#env = require '../../activiti.coffee'

describe '#escape', ->
	it 'converts & into &amp;', ->
		escape('&').should.equal('&amp;')
  
describe '#unescape', ->
	it 'converts &amp; into &', ->
		unescape('&amp;').should.equal('&')

