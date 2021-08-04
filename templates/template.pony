"""
A simple text-based template engine.
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

  new box create(value': _PropNode, body': Array[_Part] box) =>
    value = value'
    body = body'

class _IfNotEmpty
  let value: _PropNode
  let body: Array[_Part] box

  new box create(value': _PropNode, body': Array[_Part] box) =>
    value = value'
    body = body'

class _Loop
  let target: String
  let source: _PropNode
  let body: Array[_Part] box

  new box create(target': String, source': _PropNode, body': Array[_Part] box) =>
    target = target'
    source = source'
    body = body'

type _Part is ((_Literal, String) | _Call box | _PropNode | _If box | _IfNotEmpty box | _Loop box)


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
  let functions: Map[String, {(String): String}] box

  new val create(
    functions': Map[String, {(String): String}] val = recover Map[String, {(String): String}] end
  ) =>
    functions = functions'


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

  fun tag _parse(source: String, ctx: TemplateContext val): Array[_Part] box? =>
    var parts: Array[_Part] = []
    var current_parts = parts
    var open: Array[((_IfNode | _IfNotEmptyNode | _LoopNode), Array[_Part])] = []
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
      | let prop: _PropNode => current_parts.push(prop)
      | let call: _CallNode =>
        current_parts.push(_Call(ctx.functions(call.name)?, call.arg))
      | let if': _IfNode =>
        current_parts = Array[_Part]
        open.push((if', current_parts))
      | let ifnotempty: _IfNotEmptyNode =>
        current_parts = Array[_Part]
        open.push((ifnotempty, current_parts))
      | let loop: _LoopNode =>
        current_parts = Array[_Part]
        open.push((loop, current_parts))
      end

      prev_end = end_pos + 2
    end

    if prev_end < source.size().isize() then
      parts.push((_Literal, source.substring(prev_end.isize())))
    end

    if open.size() > 0 then error end

    consume parts

  fun tag _parse_end(
    open: Array[((_IfNode | _IfNotEmptyNode | _LoopNode), Array[_Part])],
    parts: Array[_Part]
  ): Array[_Part]? =>
    (let stmt, let body) = open.pop()?

    let next_current =
      if open.size() == 0 then parts
      else open(open.size() - 1)?._2
      end

    match stmt
    | let if': _IfNode =>
      next_current.push(_If(if'.value, body))
    | let ifnotempty: _IfNotEmptyNode =>
      next_current.push(_IfNotEmpty(ifnotempty.value, body))
    | let loop: _LoopNode =>
      next_current.push(_Loop(loop.target, loop.source, body))
    end

    next_current

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
        try
          values._lookup(if'.value)?
          result = result + _render_parts(if'.body, values)?
        end
      | let ifnotempty: _IfNotEmpty box =>
        if values._lookup(ifnotempty.value)?.values().has_next() then
          result = result + _render_parts(ifnotempty.body, values)?
        end
      | let loop: _Loop box =>
        for value in values._lookup(loop.source)?.values() do
          let body_values = values._override(loop.target, value)
          result = result + _render_parts(loop.body, body_values)?
        end
      end
    end
    result.string()
