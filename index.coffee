_ = require 'underscore'
moment = require 'moment'

module.exports = (table, schema, options) ->
  return (query) ->
    where_sql = ''

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

      # search
      # sort
      # pagination

    return "SELECT * FROM #{escapeIdentifier table} #{where_sql}".trim()

escapeIdentifier = (value) ->
  return "`#{value.replace(/`/g, '``')}`"

escape = (value) ->
  if value in [null, undefined]
    return 'NULL'

  if _.isBoolean value
    if value
      return 'TRUE'
    else
      return 'FALSE'

  if _.isNumber value
    return value.toFixed()

  if _.isDate value
    return escape moment(value).format 'YYYY-MM-DD HH:mm:ss.SSS'

  if _.isString value
    escaped = value.replace /[\0\n\r\b\t\\\'\"\x1a]/g, (char) ->
      switch char
        when '\0'
          return '\\0'
        when '\n'
          return '\\n'
        when '\r'
          return '\\r'
        when '\b'
          return '\\b'
        when '\t'
          return '\\t'
        when '\x1a'
          return '\\Z'
        else
          return '\\' + char

    return "'#{escaped}'"

  throw new Error "Can't escape #{value}"
