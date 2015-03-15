# mysql-querier
Use simple JSON to query from MySQL, and prevent SQL-injection attacks

## Usages

    querier = require 'mysql-querier'

    userQuerier = querier 'users',
      user_id:
        number: true
      role:
        enum: ['admin', 'user']

    app.get '/user/query', (req, res) ->
      mysql.query userQuerier(req.query), (err, rows) ->
        res.json rows

## Number

Querier:

    userQuerier = querier 'users',
      user_id:
        number: true

Query:

    {}
    // SELECT * FROM `users`
    {"user_id": 42}
    // SELECT * FROM `users` WHERE (`user_id` = 42)
    {"user_id": "42"}
    // SELECT * FROM `users` WHERE (`user_id` = 42)
    {"user_id": "jysperm"}
    // ignored, SELECT * FROM `users`

## Boolean

Querier:

    userQuerier = querier 'users',
      is_admin:
        bool: true

Query:

    {"is_admin": true}
    // SELECT * FROM `users` WHERE (`is_admin` = TRUE)
    {"is_admin": "false"}
    // SELECT * FROM `users` WHERE (`is_admin` = FALSE)

## Enum

Querier:

    userQuerier = querier 'users',
      role:
        multi: true
        enum: ['admin', 'user']

Query:

    {"role": []}
    // SELECT * FROM `users`
    {"role": 'admin'}
    // SELECT * FROM `users` WHERE (`role` = 'admin')
    {"role": ["admin", "user"]}
    // SELECT * FROM `users` WHERE (`role` IN ('admin', 'user'))
    {"role": "admin, user"}
    // SELECT * FROM `users` WHERE (`role` IN ('admin', 'user'))
    {"role": "root, admin"}
    // SELECT * FROM `users` WHERE (`role` IN ('admin'))

## Enum with SQL

Querier:

    userQuerier = querier 'users',
      activity:
        multi: true
        enum_sql:
          last_day: '`updated_at` > DATE_SUB(NOW(), INTERVAL 1 DAY)'
          last_week: '`updated_at` < DATE_SUB(NOW(), INTERVAL 1 WEEK)'

Query:

    {"activity": "last_day"}
    // SELECT * FROM `users` WHERE (`updated_at` > DATE_SUB(NOW(), INTERVAL 1 DAY))
    {"activity": "last_day, last_week"}
    // SELECT * FROM `users` WHERE ((`updated_at` > DATE_SUB(NOW(), INTERVAL 1 DAY)) OR (`updated_at` < DATE_SUB(NOW(), INTERVAL 1 WEEK)))

