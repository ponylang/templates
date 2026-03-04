use "peg"


primitive _TName is Label fun text(): String => "Name"
primitive _TCall is Label fun text(): String => "Call"
primitive _TProp is Label fun text(): String => "Prop"
primitive _TLoop is Label fun text(): String => "Loop"
primitive _TEnd is Label fun text(): String => "End"
primitive _TIf is Label fun text(): String => "If"
primitive _TIfNot is Label fun text(): String => "IfNot"
primitive _TElse is Label fun text(): String => "Else"
primitive _TElseIf is Label fun text(): String => "ElseIf"
primitive _TInclude is Label fun text(): String => "Include"

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

class box _CallNode
  let name: String
  let arg: _PropNode

  new box create(name': String, arg': _PropNode) =>
    name = name'
    arg = arg'

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

type _StmtNode is
  ( _EndNode | _ElseNode | _ElseIfNode
  | _PropNode | _CallNode | _IfNode | _IfNotNode
  | _LoopNode | _IncludeNode )

primitive _StmtParser
  fun _parser(): Parser val =>
    recover
      let expr = Forward

      let alpha = R('a', 'z') / R('A', 'Z') / L("_")
      let digit = R('0', '9')
      let name = (alpha * (alpha / digit).many()).term(_TName)

      let prop = (name * (L(".") * name).many()).node(_TProp)
      let call = (name * L("(") * expr * L(")")).node(_TCall)
      expr() = call / prop

      let whitespace = (L(" ") / L("\t")).many1()
      let end' = L("end").term(_TEnd)
      let loop = (L("for") * name * L("in") * prop).node(_TLoop).hide(whitespace)
      let ifnot = (L("ifnot") * prop).node(_TIfNot).hide(whitespace)
      let else_if = (L("elseif") * prop).node(_TElseIf).hide(whitespace)
      let else' = L("else").term(_TElse)
      let if' = (L("if") * prop).node(_TIf).hide(whitespace)

      let partial_char = alpha / digit / L("-")
      let partial_name = (L("\"") * partial_char.many1() * L("\"")).term(_TName)
      let include = (L("include") * partial_name).node(_TInclude)
        .hide(whitespace)

      let stmt = ifnot / if' / loop / include / else_if / else' / end' / expr
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
      | let call: _TCall => _parse_call(ast as AST)?
      | let loop: _TLoop => _parse_loop(ast as AST)?
      | let _: _TInclude => _parse_include(ast as AST)?
      | let prop: _TProp => _parse_prop(ast as AST)?
      else error
      end
    else error
    end

  fun _parse_call(ast: AST): _CallNode? =>
    let name = (ast.children(0)? as Token).string()
    let arg = _parse_prop(ast.children(2)? as AST)?
    _CallNode(consume name, arg)

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

  fun _parse_prop(ast: AST): _PropNode? =>
    let name = (ast.children(0)? as Token).string()
    let props: Array[String] = []
    for child in ast.children.slice(1).values() do
      props.push(((child as AST).children(1)? as Token).string())
    end
    _PropNode(consume name, props)
