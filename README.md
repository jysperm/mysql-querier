# mysql-querier
Use simple JSON to query from MySQL, and prevent SQL-injection Attacks

## Basic usages

Querier:

    querier = require 'mysql-querier'

    userQuerier = querier 'users',
      user_id: number: true
      role: enum: ['admin', 'user']

    app.get '/user/query', (req, res) ->
      mysql.query userQuerier(req.query), (err, rows) ->
        res.json rows

Query:

    {"user_id": 42}
    // SELECT * FROM `users` WHERE (`user_id` = 42)
    {"role": "admin"}
    // SELECT * FROM `users` WHERE (`role` = 'admin')
    {"user_id": 42, "role": "admin"}
    // SELECT * FROM `users` WHERE (`user_id` = 42) AND (`role` = 'admin')

    {"user_id": "jysperm"}
    // ignored, SELECT * FROM `users`
    {"role": "root"}
    // ignored, SELECT * FROM `users`

