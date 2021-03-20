use "peg"


primitive _TName is Label fun text(): String => "Name"
primitive _TCall is Label fun text(): String => "Call"
primitive _TProp is Label fun text(): String => "Prop"
primitive _TLoop is Label fun text(): String => "Loop"
primitive _TEnd is Label fun text(): String => "End"
primitive _TIf is Label fun text(): String => "If"
primitive _TIfNotEmpty is Label fun text(): String => "IfNotEmpty"

primitive _EndNode

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

class box _IfNotEmptyNode
  let value: _PropNode

  new box create(value': _PropNode) =>
    value = value'

class box _LoopNode
  let target: String
  let source: _PropNode

  new box create(target': String, source': _PropNode) =>
    target = target'
    source = source'

type _StmtNode is (_EndNode | _PropNode | _CallNode | _IfNode | _IfNotEmptyNode | _LoopNode)

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
      let ifnotempty = (L("ifnotempty") * prop).node(_TIfNotEmpty).hide(whitespace)
      let if' = (L("if") * prop).node(_TIf).hide(whitespace)

      let stmt = ifnotempty / if' / loop / end' / expr
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
      | let ifnotempty: _TIfNotEmpty => _parse_ifnotempty(ast as AST)?
      | let _: _TEnd => _EndNode
      | let call: _TCall => _parse_call(ast as AST)?
      | let loop: _TLoop => _parse_loop(ast as AST)?
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

  fun _parse_ifnotempty(ast: AST): _IfNotEmptyNode? =>
    _IfNotEmptyNode(_parse_prop(ast.children(1)? as AST)?)

  fun _parse_loop(ast: AST): _LoopNode? =>
    let target = (ast.children(1)? as Token).string()
    let source = _parse_prop(ast.children(3)? as AST)?
    _LoopNode(consume target, source)

  fun _parse_prop(ast: AST): _PropNode? =>
    let name = (ast.children(0)? as Token).string()
    let props: Array[String] = []
    for child in ast.children.slice(1).values() do
      props.push(((child as AST).children(1)? as Token).string())
    end
    _PropNode(consume name, props)
