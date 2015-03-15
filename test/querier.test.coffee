querierTester = ->
  tableQuerier = querier.apply null, arguments

  return (query, sql) ->
    tableQuerier(query).should.equal sql

describe 'querier', ->
  it 'number', ->
    test = querierTester 'users',
      user_id:
        number: true

    test {}, 'SELECT * FROM `users`'

    test
      user_id: 42
    , 'SELECT * FROM `users` WHERE (`user_id` = 42)'

    test
      user_id: '42'
    , 'SELECT * FROM `users` WHERE (`user_id` = 42)'

    test
      user_id: 'jysperm'
    , 'SELECT * FROM `users`'

  it 'boolean', ->
    test = querierTester 'users',
      is_admin:
        bool: true

    test
      is_admin: true
    , 'SELECT * FROM `users` WHERE (`is_admin` = TRUE)'

    test
      is_admin: 'false'
    , 'SELECT * FROM `users` WHERE (`is_admin` = FALSE)'

  it 'enum', ->
    test = querierTester 'users',
      role:
        enum: ['admin', 'user']
        multi: true

    test
      role: []
    , 'SELECT * FROM `users`'

    test
      role: 'admin'
    , "SELECT * FROM `users` WHERE (`role` = 'admin')"

    test
      role: ['admin', 'user']
    , "SELECT * FROM `users` WHERE (`role` IN ('admin', 'user'))"

    test
      role: 'admin, user'
    , "SELECT * FROM `users` WHERE (`role` IN ('admin', 'user'))"

    test
      role: 'root, admin'
    , "SELECT * FROM `users` WHERE (`role` IN ('admin'))"

  it 'enum with sql'

  it 'datetime'

  it 'search'

  it 'sort'

  it 'pagination'
