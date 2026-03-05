use "peg"


primitive _TName is Label fun text(): String => "Name"
primitive _TPipe is Label fun text(): String => "Pipe"
primitive _TFilter is Label fun text(): String => "Filter"
primitive _TFilterArg is Label fun text(): String => "FilterArg"
primitive _TProp is Label fun text(): String => "Prop"
primitive _TLoop is Label fun text(): String => "Loop"
primitive _TEnd is Label fun text(): String => "End"
primitive _TIf is Label fun text(): String => "If"
primitive _TIfNot is Label fun text(): String => "IfNot"
primitive _TElse is Label fun text(): String => "Else"
primitive _TElseIf is Label fun text(): String => "ElseIf"
primitive _TInclude is Label fun text(): String => "Include"
primitive _TExtends is Label fun text(): String => "Extends"
primitive _TBlock is Label fun text(): String => "Block"

primitive _EndNode
primitive _ElseNode

class box _ElseIfNode
  let value: _PropNode

  new box create(value': _PropNode) =>
    value = value'

class box _PropNode
  let name: String
  let props: Array[String]

  new box create(name': String, props': Array[String]) =>
    name = name'
    props = props'

// A filter argument is either a string literal or a property reference.
type _FilterArgValue is (_PropNode | String)

class box _FilterStep
  """
  One step in a pipe chain: a filter name and its arguments (excluding the
  piped input).
  """
  let name: String
  let args: Array[_FilterArgValue] box

  new box create(name': String, args': Array[_FilterArgValue] box) =>
    name = name'
    args = args'

class box _PipeNode
  """
  A pipe expression: a source property followed by one or more filter steps.
  """
  let source: _PropNode
  let filters: Array[_FilterStep] box

  new box create(
    source': _PropNode,
    filters': Array[_FilterStep] box
  ) =>
    source = source'
    filters = filters'

class box _IfNode
  let value: _PropNode

  new box create(value': _PropNode) =>
    value = value'

class box _IfNotNode
  let value: _PropNode

  new box create(value': _PropNode) =>
    value = value'

class box _IncludeNode
  let name: String

  new box create(name': String) =>
    name = name'

class box _LoopNode
  let target: String
  let source: _PropNode

  new box create(target': String, source': _PropNode) =>
    target = target'
    source = source'

class box _ExtendsNode
  let name: String

  new box create(name': String) =>
    name = name'

class box _BlockNode
  let name: String

  new box create(name': String) =>
    name = name'

type _StmtNode is
  ( _EndNode | _ElseNode | _ElseIfNode
  | _PropNode | _PipeNode | _IfNode | _IfNotNode
  | _LoopNode | _IncludeNode | _ExtendsNode | _BlockNode )

primitive _StmtParser
  fun _parser(): Parser val =>
    recover
      let alpha = R('a', 'z') / R('A', 'Z') / L("_")
      let digit = R('0', '9')
      let name = (alpha * (alpha / digit).many()).term(_TName)

      let prop = (name * (L(".") * name).many()).node(_TProp)

      let whitespace = (L(" ") / L("\t")).many1()

      // String literal for filter arguments: "..." with printable ASCII
      // except double quote
      let string_char = R(' ', '!') / R('#', '~')
      let string_literal =
        (L("\"") * string_char.many() * L("\"")).term(_TFilterArg)

      // A filter argument is a string literal or a prop reference
      let filter_arg = string_literal / prop

      // Filter arguments list: (arg1, arg2, ...)
      let filter_args =
        L("(") * filter_arg * (L(",") * filter_arg).many() * L(")")

      // A filter call: name or name(args)
      let filter_call =
        (name * filter_args.opt()).node(_TFilter).hide(whitespace)

      // Pipe expression: prop | filter1 | filter2 ...
      // Use Forward to prevent flattening of prop internals
      let prop_ref = Forward
      prop_ref() = prop
      let pipe_expr =
        (prop_ref * (L("|") * filter_call).many1())
          .node(_TPipe).hide(whitespace)

      let expr = pipe_expr / prop
      let end' = L("end").term(_TEnd)
      let loop = (L("for") * name * L("in") * prop).node(_TLoop)
        .hide(whitespace)
      let ifnot = (L("ifnot") * prop).node(_TIfNot).hide(whitespace)
      let else_if = (L("elseif") * prop).node(_TElseIf).hide(whitespace)
      let else' = L("else").term(_TElse)
      let if' = (L("if") * prop).node(_TIf).hide(whitespace)

      let partial_char = alpha / digit / L("-")
      let partial_name = (L("\"") * partial_char.many1() * L("\""))
        .term(_TName)
      let include = (L("include") * partial_name).node(_TInclude)
        .hide(whitespace)
      let extends' = (L("extends") * partial_name).node(_TExtends)
        .hide(whitespace)
      let block' = (L("block") * name).node(_TBlock).hide(whitespace)

      let stmt =
        extends' / ifnot / if' / loop / include / block' / else_if
          / else' / end' / expr
      stmt
    end

  fun parse(source: String): _StmtNode? =>
    let stripped = source.clone()
    stripped.strip()
    let expected_pos = stripped.size()
    (let pos, let result) = _parser().parse(Source.from_string(consume stripped))
    if pos < expected_pos then error end
    match result
    | let ast: ASTChild =>
      match ast.label()
      | let if': _TIf => _parse_if(ast as AST)?
      | let ifnot: _TIfNot => _parse_ifnot(ast as AST)?
      | let _: _TElse => _ElseNode
      | let _: _TElseIf => _parse_elseif(ast as AST)?
      | let _: _TEnd => _EndNode
      | let _: _TPipe => _parse_pipe(ast as AST)?
      | let loop: _TLoop => _parse_loop(ast as AST)?
      | let _: _TInclude => _parse_include(ast as AST)?
      | let _: _TExtends => _parse_extends(ast as AST)?
      | let _: _TBlock => _parse_block(ast as AST)?
      | let prop: _TProp => _parse_prop(ast as AST)?
      else error
      end
    else error
    end

  fun _parse_pipe(ast: AST): _PipeNode? =>
    // First child is the prop (source)
    let source = _parse_prop(ast.children(0)? as AST)?

    // Remaining children are sequence nodes from many1(), each containing
    // ["|" token, _TFilter node]. Access the _TFilter at index 1, matching
    // the pattern used by _parse_prop for (L(".") * name).many().
    let filters = Array[_FilterStep]
    for child in ast.children.slice(1).values() do
      let filter_ast = (child as AST).children(1)? as AST
      let filter_name = (filter_ast.children(0)? as Token).string()
      // Collect args by scanning recursively. The PEG Option parser wraps
      // filter_args.opt() results in an intermediate AST(NoLabel) that isn't
      // flattened by Sequence, so _TFilterArg and _TProp nodes may be nested.
      let args = Array[_FilterArgValue]
      var j: USize = 1
      while j < filter_ast.children.size() do
        _collect_filter_args(filter_ast.children(j)?, args)?
        j = j + 1
      end
      filters.push(_FilterStep(consume filter_name, consume args))
    end

    _PipeNode(source, consume filters)

  fun _collect_filter_args(node: ASTChild, args: Array[_FilterArgValue])? =>
    """
    Recursively collect filter arguments (_TFilterArg string literals and
    _TProp variable references) from a PEG AST subtree, skipping over
    intermediate nodes like parentheses, commas, and Option wrappers.
    """
    match node.label()
    | let _: _TFilterArg =>
      let quoted = (node as Token).string()
      args.push(quoted.substring(1, -1))
    | let _: _TProp =>
      args.push(_parse_prop(node as AST)?)
    else
      try
        let inner = node as AST
        for child in inner.children.values() do
          _collect_filter_args(child, args)?
        end
      end
    end

  fun _parse_if(ast: AST): _IfNode? =>
    _IfNode(_parse_prop(ast.children(1)? as AST)?)

  fun _parse_ifnot(ast: AST): _IfNotNode? =>
    _IfNotNode(_parse_prop(ast.children(1)? as AST)?)

  fun _parse_elseif(ast: AST): _ElseIfNode? =>
    _ElseIfNode(_parse_prop(ast.children(1)? as AST)?)

  fun _parse_loop(ast: AST): _LoopNode? =>
    let target = (ast.children(1)? as Token).string()
    let source = _parse_prop(ast.children(3)? as AST)?
    _LoopNode(consume target, source)

  fun _parse_include(ast: AST): _IncludeNode? =>
    let quoted = (ast.children(1)? as Token).string()
    let name = quoted.substring(1, -1)
    _IncludeNode(consume name)

  fun _parse_extends(ast: AST): _ExtendsNode? =>
    let quoted = (ast.children(1)? as Token).string()
    let name = quoted.substring(1, -1)
    _ExtendsNode(consume name)

  fun _parse_block(ast: AST): _BlockNode? =>
    let block_name = (ast.children(1)? as Token).string()
    _BlockNode(consume block_name)

  fun _parse_prop(ast: AST): _PropNode? =>
    let name = (ast.children(0)? as Token).string()
    let props: Array[String] = []
    for child in ast.children.slice(1).values() do
      props.push(((child as AST).children(1)? as Token).string())
    end
    _PropNode(consume name, props)
