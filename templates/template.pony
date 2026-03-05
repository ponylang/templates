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
* **Filters**: `{{ name | upper }}` pipes a value through one or more
  filters. Filters are chained left-to-right:
  `{{ name | trim | upper | default("ANON") }}`. Seven built-in filters are
  available without registration: `upper`, `lower`, `trim`, `capitalize`,
  `title`, `default("fallback")`, and `replace("old", "new")`. Custom filters can
  be registered via `TemplateContext`. Filter arguments can be string
  literals (`"hello"`) or template variables (`varname`).
* **Includes**: `{{ include "name" }}` inlines a named partial registered via
  `TemplateContext`. Partials share the same variable scope and can contain
  any block type. Circular includes are detected at parse time.
* **Template inheritance**: A child template declares
  `{{ extends "base" }}` as its first statement and overrides named blocks
  defined in the base with `{{ block name }}...{{ end }}`. Base templates are
  registered as partials via `TemplateContext`. Blocks not overridden render
  their default content from the base. Multi-level inheritance is supported.
  Content outside `{{ block }}` definitions in a child template is silently
  ignored. Circular extends chains are detected at parse time.
* **Whitespace trimming**: `{{-` strips trailing whitespace from the preceding
  literal, `-}}` strips leading whitespace from the following literal. Either
  or both can be used independently: `{{- x -}}`. Whitespace includes spaces,
  tabs, and newlines. Useful for generating indentation-sensitive output like
  YAML without unwanted blank lines from control flow tags.
"""

use "collections"
use "files"
use "valbytes"


primitive _Literal

// A resolved filter argument: either a string literal or a property reference.
type _ResolvedArg is (String | _PropNode)

class _Pipe
  """
  A fully resolved pipe expression ready for rendering. The source property
  is piped through each filter in order. Each filter has been validated at
  parse time for existence and correct arity.
  """
  let source: _PropNode
  let filters: Array[(AnyFilter, Array[_ResolvedArg] box)] box

  new box create(
    source': _PropNode,
    filters': Array[(AnyFilter, Array[_ResolvedArg] box)] box
  ) =>
    source = source'
    filters = filters'

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

class _Block
  let name: String
  let body: Array[_Part] box

  new box create(name': String, body': Array[_Part] box) =>
    name = name'
    body = body'

type _Part is
  ( (_Literal, String) | _Pipe box | _PropNode
  | _If box | _IfNot box | _Loop box | _Block box )


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
  Configuration for template parsing. Provides named filters that can be
  applied to values via `{{ value | filter }}`, and named partials that can
  be inlined via `{{ include "name" }}` or used as base templates for
  inheritance via `{{ extends "name" }}`.

  Seven built-in filters are always available: `upper`, `lower`, `trim`,
  `capitalize`, `title`, `default`, and `replace`. User-supplied filters with the
  same name override the built-in.
  """
  let filters: Map[String, AnyFilter] box
  let partials: Map[String, String] box

  new val create(
    filters': Map[String, AnyFilter] val
      = recover Map[String, AnyFilter] end,
    partials': Map[String, String] val
      = recover Map[String, String] end
  ) =>
    let merged = recover iso Map[String, AnyFilter] end
    merged("upper") = Upper
    merged("lower") = Lower
    merged("trim") = Trim
    merged("capitalize") = Capitalize
    merged("title") = Title
    merged("default") = Default
    merged("replace") = Replace
    for (k, v) in filters'.pairs() do
      merged(k) = v
    end
    filters = consume merged
    partials = partials'


class val Template
  let _parts: Array[_Part] box

  new val parse(source: String, ctx: TemplateContext val = TemplateContext())? =>
    _parts = _parse_template(source, ctx)?

  new val from_file(path: FilePath, ctx: TemplateContext val = TemplateContext())? =>
    let chunk_size: USize = 1024 * 1024 * 1
    match OpenFile(path)
    | let file: File =>
      var data = ByteArrays()
      while file.errno() is FileOK do
        data = data + file.read(chunk_size)
      end
      _parts = _parse_template(data.string(), ctx)?
    else error
    end

  fun tag _parse(
    source: String,
    ctx: TemplateContext val,
    include_stack: Array[String] box = []
  ): Array[_Part] box? =>
    var parts: Array[_Part] = []
    var current_parts = parts
    var open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _BlockNode), Array[_Part], Bool)] = []
    var first_stmt: Bool = true
    var trim_next_literal: Bool = false
    var prev_end: ISize = 0
    while prev_end < source.size().isize() do
      let start_pos =
        try source.find("{{" where offset = prev_end)?
        else break end
      let end_pos =
        try _find_close_delim(source, start_pos + 2)?
        else break end

      // Detect {{- (left trim) and -}} (right trim)
      let left_trim =
        try source((start_pos + 2).usize())? == '-'
        else false
        end
      let stmt_start: ISize =
        if left_trim then start_pos + 3 else start_pos + 2 end
      let right_trim =
        try
          (end_pos > stmt_start) and (source((end_pos - 1).usize())? == '-')
        else false
        end
      let stmt_end: ISize =
        if right_trim then end_pos - 1 else end_pos end

      if start_pos != prev_end then
        var literal = source.substring(prev_end.isize(), start_pos)
        if trim_next_literal then literal.lstrip() end
        if left_trim then literal.rstrip() end
        if literal.size() > 0 then
          current_parts.push((_Literal, consume literal))
        end
      else
        // No literal between tags, but reset trim_next_literal below
        None
      end
      trim_next_literal = right_trim

      let stmt_source: String = source.substring(stmt_start, stmt_end)
      match _StmtParser.parse(stmt_source)?
      | _EndNode => current_parts = _parse_end(open, parts)?
      | _ElseNode => current_parts = _parse_else(open)?
      | let else_if: _ElseIfNode =>
        current_parts = _parse_elseif_stmt(open, else_if)?
      | let prop: _PropNode => current_parts.push(prop)
      | let pipe: _PipeNode =>
        current_parts.push(_resolve_pipe(pipe, ctx)?)
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
      | let ext: _ExtendsNode =>
        if not first_stmt then error end
      | let blk: _BlockNode =>
        current_parts = Array[_Part]
        open.push((blk, current_parts, false))
      end

      first_stmt = false
      prev_end = end_pos + 2
    end

    if prev_end < source.size().isize() then
      var trailing = source.substring(prev_end.isize())
      if trim_next_literal then trailing.lstrip() end
      if trailing.size() > 0 then
        parts.push((_Literal, consume trailing))
      end
    end

    if open.size() > 0 then error end

    consume parts

  fun tag _resolve_pipe(
    pipe: _PipeNode,
    ctx: TemplateContext val
  ): _Pipe box? =>
    """
    Resolve a parsed `_PipeNode` into a renderable `_Pipe` by looking up
    each filter by name and validating its arity.
    """
    let resolved = Array[(AnyFilter, Array[_ResolvedArg] box)]
    for step in pipe.filters.values() do
      let filter = ctx.filters(step.name)?
      let args = Array[_ResolvedArg]
      for arg in step.args.values() do
        match arg
        | let s: String => args.push(s)
        | let p: _PropNode => args.push(p)
        end
      end
      // Validate arity
      match filter
      | let _: Filter val =>
        if args.size() != 0 then error end
      | let _: Filter2 val =>
        if args.size() != 1 then error end
      | let _: Filter3 val =>
        if args.size() != 2 then error end
      end
      resolved.push((filter, consume args))
    end
    _Pipe(pipe.source, consume resolved)

  fun tag _parse_end(
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _BlockNode), Array[_Part], Bool)],
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
      | let blk: _BlockNode => _Block(blk.name, body)
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
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _BlockNode), Array[_Part], Bool)]
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
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _BlockNode), Array[_Part], Bool)],
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

  fun tag _parse_template(
    source: String,
    ctx: TemplateContext val,
    include_stack: Array[String] box = []
  ): Array[_Part] box? =>
    match _check_extends(source)?
    | let base_name: String =>
      for name in include_stack.values() do
        if name == base_name then error end
      end
      let child_parts = _parse(source, ctx, include_stack)?
      let overrides = _extract_blocks(child_parts)?
      let base_source = ctx.partials(base_name)?
      let new_stack = Array[String](include_stack.size() + 1)
      for name in include_stack.values() do
        new_stack.push(name)
      end
      new_stack.push(base_name)
      _apply_overrides(_parse_template(base_source, ctx, new_stack)?, overrides)
    else
      _parse(source, ctx, include_stack)?
    end

  fun tag _check_extends(source: String): (String | None)? =>
    let start_pos =
      try source.find("{{")?
      else return None
      end
    let end_pos =
      try _find_close_delim(source, start_pos + 2)?
      else return None
      end
    let left_trim =
      try source((start_pos + 2).usize())? == '-'
      else false
      end
    let stmt_start: ISize =
      if left_trim then start_pos + 3 else start_pos + 2 end
    let right_trim =
      try
        (end_pos > stmt_start) and (source((end_pos - 1).usize())? == '-')
      else false
      end
    let stmt_end: ISize =
      if right_trim then end_pos - 1 else end_pos end
    let stmt_source: String val = source.substring(stmt_start, stmt_end)
    match _StmtParser.parse(stmt_source)?
    | let ext: _ExtendsNode => ext.name
    else None
    end

  fun tag _extract_blocks(
    parts: Array[_Part] box
  ): Map[String, Array[_Part] box]? =>
    let blocks = Map[String, Array[_Part] box]
    for part in parts.values() do
      match part
      | let blk: _Block box =>
        if blocks.contains(blk.name) then error end
        blocks(blk.name) = blk.body
      end
    end
    blocks

  fun tag _apply_overrides(
    parts: Array[_Part] box,
    overrides: Map[String, Array[_Part] box] box
  ): Array[_Part] box =>
    let result = Array[_Part]
    for part in parts.values() do
      match part
      | let blk: _Block box =>
        try
          let override_body = overrides(blk.name)?
          for p in override_body.values() do
            result.push(p)
          end
        else
          result.push(
            _Block(blk.name, _apply_overrides(blk.body, overrides)))
        end
      | let if': _If box =>
        let new_else: (Array[_Part] box | None) =
          match if'.else_body
          | let eb: Array[_Part] box =>
            _apply_overrides(eb, overrides)
          else None
          end
        result.push(
          _If(if'.value, _apply_overrides(if'.body, overrides), new_else))
      | let ifnot: _IfNot box =>
        let new_else: (Array[_Part] box | None) =
          match ifnot.else_body
          | let eb: Array[_Part] box =>
            _apply_overrides(eb, overrides)
          else None
          end
        result.push(
          _IfNot(
            ifnot.value,
            _apply_overrides(ifnot.body, overrides),
            new_else))
      | let loop: _Loop box =>
        result.push(
          _Loop(
            loop.target,
            loop.source,
            _apply_overrides(loop.body, overrides)))
      else
        result.push(part)
      end
    end
    result

  fun tag _find_close_delim(source: String, from: ISize): ISize? =>
    """
    Find the closing `}}` delimiter starting from `from`, skipping over
    double-quoted strings so that `}}` inside a filter argument like
    `default("a}}b")` is not treated as the closing delimiter.
    """
    var i = from
    let limit = source.size().isize()
    while i < (limit - 1) do
      if source(i.usize())? == '"' then
        // Skip to closing quote
        i = i + 1
        while i < limit do
          if source(i.usize())? == '"' then break end
          i = i + 1
        end
      elseif
        (source(i.usize())? == '}') and (source((i + 1).usize())? == '}')
      then
        return i
      end
      i = i + 1
    end
    error

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
      | let pipe: _Pipe box =>
        var current: String = try values._lookup(pipe.source)?.string()?
        else "" end
        for (filter, args) in pipe.filters.values() do
          // Resolve arguments
          match filter
          | let f: Filter val =>
            current = f(current)
          | let f: Filter2 val =>
            let a1 = try
              match args(0)?
              | let s: String => s
              | let p: _PropNode =>
                try values._lookup(p)?.string()? else "" end
              end
            else "" end
            current = f(current, a1)
          | let f: Filter3 val =>
            let a1 = try
              match args(0)?
              | let s: String => s
              | let p: _PropNode =>
                try values._lookup(p)?.string()? else "" end
              end
            else "" end
            let a2 = try
              match args(1)?
              | let s: String => s
              | let p: _PropNode =>
                try values._lookup(p)?.string()? else "" end
              end
            else "" end
            current = f(current, a1, a2)
          end
        end
        result = result + current
      | let prop: _PropNode =>
        let substitution = try values._lookup(prop)?.string()?
        else "" end
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
      | let blk: _Block box =>
        result = result + _render_parts(blk.body, values)?
      end
    end
    result.string()
