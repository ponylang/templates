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
  A pipe expression: a source value followed by one or more filter steps.
  The source is either a property reference or a string literal.
  """
  let source: (_PropNode | String)
  let filters: Array[_FilterStep] box

  new box create(
    source': (_PropNode | String),
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


class _Cursor
  """
  A simple cursor over a `String val` with position tracking for recursive
  descent parsing.
  """
  let _data: String val
  var _pos: USize

  new create(data: String val) =>
    _data = data
    _pos = 0

  fun pos(): USize => _pos

  fun ref set_pos(p: USize) =>
    _pos = p

  fun has_remaining(): Bool =>
    _pos < _data.size()

  fun peek(): U8? =>
    _data(_pos)?

  fun ref next(): U8? =>
    let c = _data(_pos)?
    _pos = _pos + 1
    c

  fun ref advance() =>
    _pos = _pos + 1

  fun ref skip_whitespace() =>
    try
      while _pos < _data.size() do
        let c = _data(_pos)?
        if (c == ' ') or (c == '\t') then _pos = _pos + 1
        else return
        end
      end
    end

  fun ref try_consume(prefix: String): Bool =>
    let remaining = _data.size() - _pos
    if remaining < prefix.size() then return false end
    var i: USize = 0
    try
      while i < prefix.size() do
        if _data(_pos + i)? != prefix(i)? then return false end
        i = i + 1
      end
    else return false
    end
    _pos = _pos + prefix.size()
    true

  fun ref try_consume_char(c: U8): Bool =>
    try
      if _data(_pos)? == c then
        _pos = _pos + 1
        true
      else false
      end
    else false
    end

  fun substring(from: USize, to: USize): String =>
    _data.substring(from.isize(), to.isize())


primitive _StmtParser
  fun parse(source: String): _StmtNode? =>
    let stripped = source.clone()
    stripped.strip()
    let cursor = _Cursor(consume stripped)
    let result = _parse_stmt(cursor)?
    cursor.skip_whitespace()
    if cursor.has_remaining() then error end
    result

  fun _parse_stmt(cursor: _Cursor): _StmtNode? =>
    cursor.skip_whitespace()

    // Try keywords in PEG priority order.
    // Keywords with required arguments use cursor reset for backtracking.
    // Terminal keywords (else, end) return directly.

    // extends
    let saved = cursor.pos()
    if cursor.try_consume("extends") then
      try return _parse_extends_kw(cursor)?
      else cursor.set_pos(saved)
      end
    end

    // ifnot (must come before if)
    if cursor.try_consume("ifnot") then
      try return _parse_ifnot_kw(cursor)?
      else cursor.set_pos(saved)
      end
    end

    // if
    if cursor.try_consume("if") then
      try return _parse_if_kw(cursor)?
      else cursor.set_pos(saved)
      end
    end

    // for
    if cursor.try_consume("for") then
      try return _parse_loop_kw(cursor)?
      else cursor.set_pos(saved)
      end
    end

    // include
    if cursor.try_consume("include") then
      try return _parse_include_kw(cursor)?
      else cursor.set_pos(saved)
      end
    end

    // block
    if cursor.try_consume("block") then
      try return _parse_block_kw(cursor)?
      else cursor.set_pos(saved)
      end
    end

    // elseif
    if cursor.try_consume("elseif") then
      try return _parse_elseif_kw(cursor)?
      else cursor.set_pos(saved)
      end
    end

    // else (terminal)
    if cursor.try_consume("else") then
      return _ElseNode
    end

    // end (terminal)
    if cursor.try_consume("end") then
      return _EndNode
    end

    // Fall through to expression
    _parse_expr(cursor)?

  fun _parse_expr(cursor: _Cursor): _StmtNode? =>
    """
    Parse an expression: a pipe source (string literal or prop) optionally
    followed by a pipe tail.
    """
    cursor.skip_whitespace()
    let source: (_PropNode | String) =
      try _parse_string_literal(cursor)?
      else _parse_prop(cursor)?
      end

    cursor.skip_whitespace()
    if cursor.try_consume_char('|') then
      // Parse pipe tail
      let filters = Array[_FilterStep]
      _parse_filter_call(cursor, filters)?
      while true do
        cursor.skip_whitespace()
        if cursor.try_consume_char('|') then
          _parse_filter_call(cursor, filters)?
        else break
        end
      end
      _PipeNode(source, consume filters)
    else
      match source
      | let p: _PropNode => p
      | let s: String =>
        // A bare string literal with no pipe is not a valid statement
        error
      end
    end

  fun _parse_filter_call(
    cursor: _Cursor,
    filters: Array[_FilterStep]
  )? =>
    """
    Parse a single filter call: `name` or `name(arg1, arg2, ...)`.
    """
    cursor.skip_whitespace()
    let name = _parse_name(cursor)?
    cursor.skip_whitespace()
    let args = Array[_FilterArgValue]
    if cursor.try_consume_char('(') then
      // Parse first argument
      cursor.skip_whitespace()
      args.push(_parse_filter_arg(cursor)?)
      // Parse remaining arguments
      while true do
        cursor.skip_whitespace()
        if cursor.try_consume_char(',') then
          cursor.skip_whitespace()
          args.push(_parse_filter_arg(cursor)?)
        else break
        end
      end
      cursor.skip_whitespace()
      if not cursor.try_consume_char(')') then error end
    end
    filters.push(_FilterStep(consume name, consume args))

  fun _parse_filter_arg(cursor: _Cursor): _FilterArgValue? =>
    """
    Parse a filter argument: either a string literal or a prop reference.
    """
    cursor.skip_whitespace()
    try
      _parse_string_literal(cursor)?
    else
      _parse_prop(cursor)?
    end

  fun _parse_prop(cursor: _Cursor): _PropNode? =>
    """
    Parse a property reference: `name` or `name.name.name`.
    """
    let name = _parse_name(cursor)?
    let props = Array[String]
    while cursor.try_consume_char('.') do
      props.push(_parse_name(cursor)?)
    end
    _PropNode(consume name, props)

  fun _parse_name(cursor: _Cursor): String? =>
    """
    Parse an identifier: `[a-zA-Z_][a-zA-Z0-9_]*`.
    """
    let start = cursor.pos()
    let first = cursor.peek()?
    if not (_is_alpha(first) or (first == '_')) then error end
    cursor.advance()
    try
      while true do
        let c = cursor.peek()?
        if _is_alpha(c) or _is_digit(c) or (c == '_') then
          cursor.advance()
        else break
        end
      end
    end
    cursor.substring(start, cursor.pos())

  fun _parse_string_literal(cursor: _Cursor): String? =>
    """
    Parse a double-quoted string literal: `"..."` with printable ASCII
    except double quote. Returns the content without quotes.
    """
    if not cursor.try_consume_char('"') then error end
    let start = cursor.pos()
    try
      while true do
        let c = cursor.peek()?
        if c == '"' then break end
        // Printable ASCII except double quote: ' ' to '!' and '#' to '~'
        if ((c >= 0x20) and (c <= 0x21)) or ((c >= 0x23) and (c <= 0x7E)) then
          cursor.advance()
        else error
        end
      end
    end
    let content = cursor.substring(start, cursor.pos())
    if not cursor.try_consume_char('"') then error end
    content

  fun _parse_quoted_name(cursor: _Cursor): String? =>
    """
    Parse a quoted name for include/extends: `"[a-zA-Z0-9_-]+"`.
    Returns the content without quotes.
    """
    if not cursor.try_consume_char('"') then error end
    let start = cursor.pos()
    var count: USize = 0
    try
      while true do
        let c = cursor.peek()?
        if _is_alpha(c) or _is_digit(c) or (c == '_') or (c == '-') then
          cursor.advance()
          count = count + 1
        else break
        end
      end
    end
    if count == 0 then error end
    let content = cursor.substring(start, cursor.pos())
    if not cursor.try_consume_char('"') then error end
    content

  fun _parse_if_kw(cursor: _Cursor): _IfNode? =>
    cursor.skip_whitespace()
    _IfNode(_parse_prop(cursor)?)

  fun _parse_ifnot_kw(cursor: _Cursor): _IfNotNode? =>
    cursor.skip_whitespace()
    _IfNotNode(_parse_prop(cursor)?)

  fun _parse_elseif_kw(cursor: _Cursor): _ElseIfNode? =>
    cursor.skip_whitespace()
    _ElseIfNode(_parse_prop(cursor)?)

  fun _parse_loop_kw(cursor: _Cursor): _LoopNode? =>
    cursor.skip_whitespace()
    let target = _parse_name(cursor)?
    cursor.skip_whitespace()
    if not cursor.try_consume("in") then error end
    cursor.skip_whitespace()
    let source = _parse_prop(cursor)?
    _LoopNode(consume target, source)

  fun _parse_include_kw(cursor: _Cursor): _IncludeNode? =>
    cursor.skip_whitespace()
    _IncludeNode(_parse_quoted_name(cursor)?)

  fun _parse_extends_kw(cursor: _Cursor): _ExtendsNode? =>
    cursor.skip_whitespace()
    _ExtendsNode(_parse_quoted_name(cursor)?)

  fun _parse_block_kw(cursor: _Cursor): _BlockNode? =>
    cursor.skip_whitespace()
    _BlockNode(_parse_name(cursor)?)

  fun _is_alpha(c: U8): Bool =>
    ((c >= 'a') and (c <= 'z')) or ((c >= 'A') and (c <= 'Z'))

  fun _is_digit(c: U8): Bool =>
    (c >= '0') and (c <= '9')
