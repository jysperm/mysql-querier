createQuerierTester = ->
  tableQuerier = querier.apply null, arguments

  return (query, sql) ->
    tableQuerier(query).should.equal sql

describe 'querier', ->
  it 'basic usages', ->
    test = createQuerierTester 'users',
      user_id: number: true
      role: enum: ['admin', 'user']

    test
      user_id: 42
    , 'SELECT * FROM `users` WHERE (`user_id` = 42)'

    test
      role: 'admin'
    , "SELECT * FROM `users` WHERE (`role` = 'admin')"

    test
      user_id: 42
      role: 'admin'
    , "SELECT * FROM `users` WHERE (`user_id` = 42) AND (`role` = 'admin')"

    test
      user_id: 'jysperm'
    , 'SELECT * FROM `users`'

    test
      role: 'root'
    , 'SELECT * FROM `users`'
