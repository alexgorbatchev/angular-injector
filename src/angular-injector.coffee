module.exports =
  annotate: (src, opts = {}) ->
    falafel = require 'falafel'
    css     = require 'cssauron-falafel'

    opts.token     ?= 'ng'
    isFunctionCall = css 'call > id'
    parents        = {}
    isInjector     = (node) -> node.name is opts.token and isFunctionCall node

    wrap = (node) ->
      return node.source() unless node.params?.length
      params = (param for param in node.params).map ({name}) -> "'#{name}'"
      "[#{params.join ', '}, #{node.source()}]"

    nodeId = (node) ->
      node.range.join '-'

    output = falafel src, (node) ->
      id = nodeId node
      if parents[id]?
        angularFn = parents[id].arguments[0]
        node.update wrap angularFn
        delete parents[id]

      else if isInjector node
        parent = node.parent
        parents[nodeId parent] = parent

    output.toString()
