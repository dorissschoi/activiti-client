module.exports =
  escape: (html) ->
    String(html).replace(/&/g, '&amp;').replace />/g, '&gt;'
  unescape: (html) ->
    String(html).replace(/&amp;/g, '&').replace /&gt;/g, '>'