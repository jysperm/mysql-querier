# mysql-querier
Use simple JSON to query from MySQL, and prevent SQL-injection attacks

## Example

    querier = require 'mysql-querier'

    userQuerier = querier 'users',
      user_id:
        number: true
      role:
        enum: ['admin', 'user']

    app.get '/user/query', (req, res) ->
      mysql.query userQuerier(req.query), (err, rows) ->
        res.json rows

## String

Querier:

    userQuerier = querier 'users',
      name:
        string: true

Query:

    {}
    // SELECT * FROM `users`
    {"name": "jysperm"}
    // SELECT * FROM `users` WHERE (`name` = 'jysperm')
    {"name": "jysperm's blog"}
    // SELECT * FROM `users` WHERE (`name` = 'jysperm\'s blog')

## Number

Querier:

    userQuerier = querier 'users',
      user_id:
        number: true

Query:

    {"user_id": 42}
    {"user_id": "42"}
    // SELECT * FROM `users` WHERE (`user_id` = 42)
    {"user_id": "jysperm"}
    // SELECT * FROM `users`

Querier:

    userQuerier = querier 'users',
      user_id:
        multi: true
        number: true

Query:

    {"user_id": [1, 2]}
    // SELECT * FROM `users` WHERE (`user_id` IN (1, 2))
    {"user_id": "3, 4, jysperm"}
    // SELECT * FROM `users` WHERE (`user_id` IN (3, 4))

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

## Datetime

Querier:

    userQuerier = querier 'users',
      created_at:
        date: true

Query:

    {"created_at": "2015-03-01~2015-03-30"}
    // SELECT * FROM `users` WHERE (`created_at` BETWEEN '2015-03-01 00:00:00.000' AND '2015-03-30 00:00:00.000')
    {"created_at": "2015-03-01~"}
    // SELECT * FROM `users` WHERE (`created_at` >= '2015-03-01 00:00:00.000')
    {"created_at": "~2015-03-30"}
    // SELECT * FROM `users` WHERE (`created_at` =< '2015-03-30 00:00:00.000')
    {"created_at": "invalid~date"}
    {}
    // SELECT * FROM `users`

## Search

Querier:

    userQuerier = querier 'users',
      search:
        search: ['username', 'bio']

Query:

    {"search": "jysperm"}
    // SELECT * FROM `users` WHERE (`username` LIKE '%jysperm%' OR `bio` LIKE '%jysperm%')

## Sort

Querier:

    userQuerier = querier 'users',
      role:
        enum: ['admin', 'user']
    ,
      sortable: ['followers', 'user_id']

Query:

    {"role": "admin", "order_by": "followers"}
    // SELECT * FROM `users` WHERE (`role` = 'admin') ORDER BY `followers`
    {"order_by": "-user_id"}
    // SELECT * FROM `users` ORDER BY `user_id` DESC
    {"order_by": "role"}
    // SELECT * FROM `users`

## Pagination

Querier:

    userQuerier = querier 'users',
      role:
        enum: ['admin', 'user']
    ,
      max_limit: 30

Query:

    {"limit": 10}
    // SELECT * FROM `users` LIMIT 10
    {"limit": 10, "offset": 20}
    // SELECT * FROM `users` LIMIT 10 OFFSET 20
    {}
    {"limit": 50}
    // SELECT * FROM `users` LIMIT 30

## Fields & Count

Querier:

    userQuerier = querier 'users',
      role:
        enum: ['admin', 'user']
    ,
      fields: ['username', 'role']

Query:

    {}
    // SELECT `username`, `role` FROM `users`
    {"count:*": true}
    // SELECT COUNT(*) FROM `users`
