module.exports =
  annotate: (src, opts = {}) ->
    falafel = require 'falafel'
    css     = require 'cssauron-falafel'

    opts.token     ?= 'ng'
    isFunctionCall = css 'call > id'
    found          = false
    chunks         = src.split ''
    isInjector     = (node) -> node.name is opts.token and isFunctionCall node

    source = (node) ->
      [start, end] = node.range
      chunks.slice(start, end).join ''

    replace = (node, replacement) ->
      [start, end] = node.range
      chunks[start] = replacement
      chunks[i] = '' for i in [start + 1...end]

    wrap = (node) ->
      params = (param for param in node.params).map ({name}) -> "'#{name}'"
      "[#{params.join ', '}, #{source node}]"

    falafel src, (node) ->
      if isInjector node
        callExpression = node.parent
        angularFn = callExpression.arguments[0]
        replace callExpression, wrap angularFn
        found = true

    src = chunks.join '' if found
    src
