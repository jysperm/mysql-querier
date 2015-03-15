_ = require 'underscore'
moment = require 'moment'

module.exports = (table, schema, options) ->
  return (query) ->
    where_sql = ''

    if query.order_by and query.order_by[... 1] in ['+', '-']
      desc = query.order_by[... 1] == '-'
      order_field = query.order_by[1 ...]
    else
      order_field = query.order_by

    if order_field in (options?.sortable ? [])
      order_by_sql = "ORDER BY #{escapeIdentifier order_field}#{if desc then ' DESC' else ''}"
    else
      order_by_sql = ''

    limit_sql = ''

    if _.isFinite query.limit
      limit = Math.min (options?.max_limit ? Infinity), parseInt query.limit
      limit_sql = "LIMIT #{escape limit}"
    else if options?.limit and options.max_limit < Infinity
      limit_sql = "LIMIT #{escape options.limit}"
    else
      limit_sql = ''

    if _.isFinite query.offset
      offset = parseInt query.offset

      if limit_sql
        limit_sql = "#{limit_sql} OFFSET #{escape offset}"
      else
        limit_sql = "OFFSET #{escape offset}"

    whereAnd = (condition) ->
      if where_sql
        where_sql = "#{where_sql} AND (#{condition})"
      else
        where_sql = "WHERE (#{condition})"

    _.keys(schema).forEach (field) ->
      escaped_field = escapeIdentifier field
      definition = schema[field]
      value = query[field]

      if value == undefined
        return

      if definition.string
        whereAnd "#{escaped_field} = #{escape value}"

      else if definition.number
        if _.isFinite value
          whereAnd "#{escaped_field} = #{escape parseInt value}"
        else if definition.multi
          if _.isArray value
            values = value
          else
            values = value.split(',').map (value) -> parseInt value.trim()

          values = _.compact values.map (value) ->
            if _.isFinite value
              return escape value
            else
              return null

          unless _.isEmpty values
            whereAnd "#{escaped_field} IN (#{values.join ', '})"

      else if definition.bool
        if value in ['true', 'false']
          value = value == 'true'
        else if value in ['TRUE', 'FALSE']
          value = value == 'TRUE'
        else
          value = !! value

        whereAnd "#{escaped_field} = #{escape value}"

      else if definition.enum
        if value in definition.enum
          whereAnd "#{escaped_field} = #{escape value}"
        else if definition.multi
          if _.isArray value
            values = value
          else
            values = value.split(',').map (value) -> value.trim()

          values = _.compact values.map (value) ->
            if value in definition.enum
              return escape value
            else
              return null

          unless _.isEmpty values
            whereAnd "#{escaped_field} IN (#{values.join ', '})"

      else if definition.enum_sql
        if value in _.keys definition.enum_sql
          whereAnd definition.enum_sql[value]
        else if definition.multi
          if _.isArray value
            values = value
          else
            values = value.split(',').map (value) -> value.trim()

          conditions = _.compact values.map (value) ->
            if value in _.keys definition.enum_sql
              return "(#{definition.enum_sql[value]})"
            else
              return null

          unless _.isEmpty conditions
            whereAnd conditions.join ' OR '

      else if definition.date
        [from, to] = (value ? '').split('~').map (date) ->
          if Date.parse date
            return escape new Date date
          else
            return null

        if from and to
          whereAnd "#{escaped_field} BETWEEN #{from} AND #{to}"
        else if from
          whereAnd "#{escaped_field} >= #{from}"
        else if to
          whereAnd "#{escaped_field} =< #{to}"

      else if definition.search
        conditions = definition.search.map (field) ->
          return "#{escapeIdentifier field} LIKE #{escape "%#{value}%"}"

        unless _.isEmpty conditions
          whereAnd conditions.join ' OR '

    return _.compact([
      "SELECT * FROM #{escapeIdentifier table}", where_sql, order_by_sql, limit_sql
    ]).join ' '

escapeIdentifier = (value) ->
  return "`#{value.replace(/`/g, '``')}`"

escape = (value) ->
  if value in [null, undefined]
    return 'NULL'

  else if _.isString value
    escaped = value.replace /[\0\n\r\b\t\\\'\"\x1a]/g, (char) ->
      switch char
        when '\0' then return '\\0'
        when '\n' then return '\\n'
        when '\r' then return '\\r'
        when '\b' then return '\\b'
        when '\t' then return '\\t'
        when '\x1a' then return '\\Z'
        else return '\\' + char

    return "'#{escaped}'"

  else if _.isNumber value
    return value.toFixed()

  else if _.isBoolean value
    if value
      return 'TRUE'
    else
      return 'FALSE'

  else if _.isDate value
    return escape moment(value).format 'YYYY-MM-DD HH:mm:ss.SSS'

  else
    throw new Error "Can't escape #{value}"
