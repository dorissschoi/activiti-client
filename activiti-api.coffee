

module.exports =
  change: (html) ->
    return String(html).replace /a/g, 'A'
    
  unchange: (html) ->
    return html