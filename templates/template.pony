"""
A simple text-based template engine.

Templates are strings containing literal text interspersed with `{{ ... }}`
blocks. Supported block types:

* **Variable substitution**: `{{ name }}` or `{{ obj.prop }}`
* **Conditionals**: `{{ if flag }}...{{ end }}`, with optional
  `{{ else }}` and `{{ elseif other }}` branches. Truthy when the variable
  exists and, for sequences, is non-empty.
* **Negated conditionals**: `{{ ifnot flag }}...{{ end }}`, renders when
  the variable is absent or is an empty sequence; supports `{{ else }}`
  and `{{ elseif }}`
* **Loops**: `{{ for item in items }}...{{ end }}`
* **Function calls**: `{{ fn(arg) }}` using functions registered via
  `TemplateContext`
* **Includes**: `{{ include "name" }}` inlines a named partial registered via
  `TemplateContext`. Partials share the same variable scope and can contain
  any block type. Circular includes are detected at parse time.
"""

use "collections"
use "files"
use "valbytes"


primitive _Literal

class _Call
  let f: {(String): String} val
  let arg: _PropNode

  new box create(f': {(String): String} val, arg': _PropNode) =>
    f = f'
    arg = arg'

class _If
  let value: _PropNode
  let body: Array[_Part] box
  let else_body: (Array[_Part] box | None)

  new box create(
    value': _PropNode,
    body': Array[_Part] box,
    else_body': (Array[_Part] box | None) = None
  ) =>
    value = value'
    body = body'
    else_body = else_body'

class box _IfElse
  """
  Marker on the open-block stack indicating an `if` or `ifnot` block that has
  transitioned to its `else` branch. Stores the original condition and if-body
  so they can be assembled into the final `_If` or `_IfNot` node when `end` is
  encountered.
  """
  let value: _PropNode
  let if_body: Array[_Part] box
  let negated: Bool

  new box create(
    value': _PropNode,
    if_body': Array[_Part] box,
    negated': Bool = false
  ) =>
    value = value'
    if_body = if_body'
    negated = negated'

class _IfNot
  let value: _PropNode
  let body: Array[_Part] box
  let else_body: (Array[_Part] box | None)

  new box create(
    value': _PropNode,
    body': Array[_Part] box,
    else_body': (Array[_Part] box | None) = None
  ) =>
    value = value'
    body = body'
    else_body = else_body'

class _Loop
  let target: String
  let source: _PropNode
  let body: Array[_Part] box

  new box create(target': String, source': _PropNode, body': Array[_Part] box) =>
    target = target'
    source = source'
    body = body'

type _Part is
  ( (_Literal, String) | _Call box | _PropNode
  | _If box | _IfNot box | _Loop box )


class box TemplateValue
  """
  A value that can be used in a template. Either a single value or a
  sequence of values.
  """
  let _value: (String | None)
  let _values: Seq[TemplateValue] box
  let _properties: Map[String, TemplateValue] box

  new box create(
    value: (String | Seq[TemplateValue] box),
    properties: Map[String, TemplateValue] box = Map[String, TemplateValue]
  ) =>
    _value = match value
    | let s: String => s
    else None
    end
    _values = match value
    | let seq: Seq[TemplateValue] box => seq
    else []
    end
    _properties = properties

  fun apply(name: String): TemplateValue? => _properties(name)?

  fun string(): String? => _value as String

  fun values(): Iterator[TemplateValue] => _values.values()

  fun box _is_truthy(): Bool =>
    match _value
    | let _: String => true
    else _values.values().has_next()
    end


class TemplateValues
  let _parent: (TemplateValues box | None)
  let _values: Map[String, TemplateValue]

  new _create(
    parent: TemplateValues box,
    values: Map[String, TemplateValue]
  ) =>
    _parent = parent
    _values = values

  new create() =>
    _parent = None
    _values = Map[String, TemplateValue]

  fun box apply(name: String): TemplateValue? =>
    try _values(name)?
    else
      match _parent
      | let parent: TemplateValues box => parent(name)?
      | None => error
      end
    end


  fun box _lookup(prop: _PropNode): TemplateValue? =>
    var value = this(prop.name)?
    for name in prop.props.values() do
      value = value(name)?
    end

    value

  fun ref update(name: String, value: (String | TemplateValue)) =>
    _values(name) = match value
    | let string: String => TemplateValue(string)
    | let template_value: TemplateValue => template_value
    end

  fun box _override(name: String, value: TemplateValue): TemplateValues =>
    let values = Map[String, TemplateValue]
    values(name) = value
    TemplateValues._create(this, values)


class TemplateContext
  """
  Configuration for template parsing. Provides named functions that can be
  called from templates via `{{ fn(arg) }}`, and named partials that can be
  inlined via `{{ include "name" }}`.
  """
  let functions: Map[String, {(String): String}] box
  let partials: Map[String, String] box

  new val create(
    functions': Map[String, {(String): String}] val
      = recover Map[String, {(String): String}] end,
    partials': Map[String, String] val
      = recover Map[String, String] end
  ) =>
    functions = functions'
    partials = partials'


class val Template
  let _parts: Array[_Part] box

  new val parse(source: String, ctx: TemplateContext val = TemplateContext())? =>
    _parts = _parse(source, ctx)?

  new val from_file(path: FilePath, ctx: TemplateContext val = TemplateContext())? =>
    let chunk_size: USize = 1024 * 1024 * 1
    match OpenFile(path)
    | let file: File =>
      var data = ByteArrays()
      while file.errno() is FileOK do
        data = data + file.read(chunk_size)
      end
      _parts = _parse(data.string(), ctx)?
    else error
    end

  fun tag _parse(
    source: String,
    ctx: TemplateContext val,
    include_stack: Array[String] box = []
  ): Array[_Part] box? =>
    var parts: Array[_Part] = []
    var current_parts = parts
    var open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse), Array[_Part], Bool)] = []
    var prev_end: ISize = 0
    while prev_end < source.size().isize() do
      let start_pos =
        try source.find("{{" where offset = prev_end)?
        else break end
      let end_pos =
        try source.find("}}" where offset = start_pos)?
        else break end
      if start_pos != prev_end then
        let literal = source.substring(prev_end.isize(), start_pos)
        current_parts.push((_Literal, consume literal))
      end

      let stmt_source: String = source.substring(start_pos + 2, end_pos)
      match _StmtParser.parse(stmt_source)?
      | _EndNode => current_parts = _parse_end(open, parts)?
      | _ElseNode => current_parts = _parse_else(open)?
      | let else_if: _ElseIfNode =>
        current_parts = _parse_elseif_stmt(open, else_if)?
      | let prop: _PropNode => current_parts.push(prop)
      | let call: _CallNode =>
        current_parts.push(_Call(ctx.functions(call.name)?, call.arg))
      | let if': _IfNode =>
        current_parts = Array[_Part]
        open.push((if', current_parts, false))
      | let ifnot: _IfNotNode =>
        current_parts = Array[_Part]
        open.push((ifnot, current_parts, false))
      | let loop: _LoopNode =>
        current_parts = Array[_Part]
        open.push((loop, current_parts, false))
      | let inc: _IncludeNode =>
        let partial_source = ctx.partials(inc.name)?
        for name in include_stack.values() do
          if name == inc.name then error end
        end
        let new_stack = Array[String](include_stack.size() + 1)
        for name in include_stack.values() do
          new_stack.push(name)
        end
        new_stack.push(inc.name)
        let inline_parts = _parse(partial_source, ctx, new_stack)?
        for p in inline_parts.values() do
          current_parts.push(p)
        end
      end

      prev_end = end_pos + 2
    end

    if prev_end < source.size().isize() then
      parts.push((_Literal, source.substring(prev_end.isize())))
    end

    if open.size() > 0 then error end

    consume parts

  fun tag _parse_end(
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse), Array[_Part], Bool)],
    parts: Array[_Part]
  ): Array[_Part]? =>
    (let stmt, let body, _) = open.pop()?

    let node: _Part =
      match stmt
      | let if': _IfNode => _If(if'.value, body)
      | let ifnot: _IfNotNode => _IfNot(ifnot.value, body)
      | let ie: _IfElse =>
        if ie.negated then _IfNot(ie.value, ie.if_body, body)
        else _If(ie.value, ie.if_body, body)
        end
      | let loop: _LoopNode => _Loop(loop.target, loop.source, body)
      end

    // Auto-close elseif chain entries
    var current_node: _Part = node
    while open.size() > 0 do
      if open(open.size() - 1)?._3 then
        (let outer_stmt, let outer_body, _) = open.pop()?
        match outer_stmt
        | let ie: _IfElse =>
          outer_body.push(current_node)
          current_node =
            if ie.negated then _IfNot(ie.value, ie.if_body, outer_body)
            else _If(ie.value, ie.if_body, outer_body)
            end
        else
          error // auto_close should only be set on _IfElse entries
        end
      else
        break
      end
    end

    let next_current =
      if open.size() == 0 then parts
      else open(open.size() - 1)?._2
      end

    next_current.push(current_node)
    next_current

  fun tag _parse_else(
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse), Array[_Part], Bool)]
  ): Array[_Part]? =>
    (let stmt, let if_body, _) = open.pop()?
    match stmt
    | let if': _IfNode =>
      let else_body = Array[_Part]
      open.push((_IfElse(if'.value, if_body), else_body, false))
      else_body
    | let ifnot: _IfNotNode =>
      let else_body = Array[_Part]
      open.push(
        (_IfElse(ifnot.value, if_body where negated' = true), else_body, false))
      else_body
    else
      error // else only valid inside an if or ifnot block
    end

  fun tag _parse_elseif_stmt(
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse), Array[_Part], Bool)],
    else_if: _ElseIfNode
  ): Array[_Part]? =>
    (let stmt, let if_body, _) = open.pop()?
    match stmt
    | let if': _IfNode =>
      let else_body = Array[_Part]
      open.push((_IfElse(if'.value, if_body), else_body, true))
      let else_if_body = Array[_Part]
      open.push((_IfNode(else_if.value), else_if_body, false))
      else_if_body
    | let ifnot: _IfNotNode =>
      let else_body = Array[_Part]
      open.push(
        (_IfElse(ifnot.value, if_body where negated' = true), else_body, true))
      let else_if_body = Array[_Part]
      open.push((_IfNode(else_if.value), else_if_body, false))
      else_if_body
    else
      error // elseif only valid inside an if or ifnot block
    end

  fun render(values: TemplateValues box): String? =>
    """
    Fills in the given values into template.
    """
    _render_parts(_parts, values)?

  fun tag _render_parts(parts: Array[_Part] box, values: TemplateValues box): String? =>
    var result = ByteArrays()
    for part in parts.values() do
      match part
      | (_Literal, let value: String) => result = result + value
      | let call: _Call box =>
        let arg = values._lookup(call.arg)?
        result = result + call.f(arg.string()?)
      | let prop: _PropNode =>
        // XXX make this an error instead
        let substitution = try values._lookup(prop)?.string()? else "" end
        result = result + substitution
      | let if': _If box =>
        if
          try
            values._lookup(if'.value)?._is_truthy()
          else
            false
          end
        then
          result = result + _render_parts(if'.body, values)?
        else
          match if'.else_body
          | let eb: Array[_Part] box =>
            result = result + _render_parts(eb, values)?
          end
        end
      | let ifnot: _IfNot box =>
        if
          try
            values._lookup(ifnot.value)?._is_truthy()
          else
            false
          end
        then
          match ifnot.else_body
          | let eb: Array[_Part] box =>
            result = result + _render_parts(eb, values)?
          end
        else
          result = result + _render_parts(ifnot.body, values)?
        end
      | let loop: _Loop box =>
        for value in values._lookup(loop.source)?.values() do
          let body_values = values._override(loop.target, value)
          result = result + _render_parts(loop.body, body_values)?
        end
      end
    end
    result.string()
