process.env.NODE_ENV = 'test'
process.env.TZ = 'UTC'

chai = require 'chai'
_ = require 'underscore'

_.extend global,
  querier: require '../index'
  expect: chai.expect
  _: _

chai.should()
chai.config.includeStack = true
