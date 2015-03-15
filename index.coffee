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
      definition = schema[field]
      value = query[field]

      if value == undefined
        return

      if definition.bool
        if value in ['true', 'false']
          value = value == 'true'
        else if value in ['TRUE', 'FALSE']
          value = value == 'TRUE'
        else
          value = !! value

        whereAnd "`#{field}` = #{escape value}"

      else if definition.number
        if _.isFinite value
          whereAnd "`#{field}` = #{escape parseInt value}"

      else if definition.enum
        if value in definition.enum
          whereAnd "`#{field}` = #{escape value}"
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
            whereAnd "`#{field}` IN (#{values.join ', '})"

      # date
      # enum_sql
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
    return moment(value).format 'YYYY-MM-DD HH:mm:ss.SSS'

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
