querierTester = ->
  tableQuerier = querier.apply null, arguments

  return (query, sql) ->
    tableQuerier(query).should.equal sql

describe 'querier', ->
  it 'string', ->
    test = querierTester 'users',
      name:
        string: true

    test {}, 'SELECT * FROM `users`'

    test
      name: 'jysperm'
    , "SELECT * FROM `users` WHERE (`name` = 'jysperm')"

    test
      name: "jysperm's blog"
    , "SELECT * FROM `users` WHERE (`name` = 'jysperm\\'s blog')"

  it 'number', ->
    test = querierTester 'users',
      user_id:
        number: true

    test
      user_id: 42
    , 'SELECT * FROM `users` WHERE (`user_id` = 42)'

    test
      user_id: '42'
    , 'SELECT * FROM `users` WHERE (`user_id` = 42)'

    test
      user_id: 'jysperm'
    , 'SELECT * FROM `users`'

    test = querierTester 'users',
      user_id:
        multi: true
        number: true

    test
      user_id: [1, 2]
    , 'SELECT * FROM `users` WHERE (`user_id` IN (1, 2))'

    test
      user_id: '3, 4, jysperm'
    , 'SELECT * FROM `users` WHERE (`user_id` IN (3, 4))'

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
