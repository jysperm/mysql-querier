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
        multi: true
        enum: ['admin', 'user']

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

  it 'enum with sql', ->
    test = querierTester 'users',
      activity:
        multi: true
        enum_sql:
          last_day: '`updated_at` > DATE_SUB(NOW(), INTERVAL 1 DAY)'
          last_week: '`updated_at` < DATE_SUB(NOW(), INTERVAL 1 WEEK)'

    test
      activity: 'last_day'
    , 'SELECT * FROM `users` WHERE (`updated_at` > DATE_SUB(NOW(), INTERVAL 1 DAY))'

    test
      activity: 'last_day, last_week'
    , 'SELECT * FROM `users` WHERE ((`updated_at` > DATE_SUB(NOW(), INTERVAL 1 DAY)) OR (`updated_at` < DATE_SUB(NOW(), INTERVAL 1 WEEK)))'

  it 'datetime'

  it 'search'

  it 'sort'

  it 'pagination'
