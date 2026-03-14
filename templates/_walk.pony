class ref _StringSink is TemplateSink
  """
  A sink that concatenates all literal and dynamic segments into a single
  string. Used internally by `Template.render()` and `HtmlTemplate.render()`.
  """
  var _result: String iso = recover iso String end

  fun ref literal(text: String) =>
    _result.append(text)

  fun ref dynamic_value(value: String) =>
    _result.append(value)

  fun ref result(): String val =>
    _result = recover iso String end


primitive _TemplateWalk
  """
  Unified AST walker that drives a `TemplateSink` through a parsed template's
  parts. Handles the interleaving invariant: calls to `literal` and
  `dynamic_value` strictly alternate, starting and ending with `literal`.
  For N dynamic values, exactly N+1 literal calls are made. Empty-string
  literals are inserted where needed to maintain this invariant.

  Control flow subtrees (`_If`, `_IfNot`, `_Loop`) collapse into a single
  `dynamic_value` call. `_Block` is transparent — its literals merge with
  the surrounding context.
  """

  fun walk(
    parts: Array[_Part] box,
    values: TemplateValues box,
    sink: TemplateSink ref,
    escaper: _Escaper ref
  )? =>
    """
    Walk the top-level parts array, maintaining the interleaving invariant
    on the given sink.
    """
    let pending: String ref = String
    _walk_body(parts, values, sink, escaper, pending)?
    // Flush any trailing accumulated literal
    sink.literal(pending.clone())

  fun _walk_body(
    parts: Array[_Part] box,
    values: TemplateValues box,
    sink: TemplateSink ref,
    escaper: _Escaper ref,
    pending: String ref
  )? =>
    """
    Shared body walker with a pending literal buffer. Literals accumulate
    in `pending`; before each dynamic value, the buffer is flushed as a
    `literal` call, then the dynamic is emitted. `_Block` is transparent —
    its body is walked inline without flushing.
    """
    for part in parts.values() do
      match part
      | (_Literal, let text: String) =>
        escaper.advance_literal(text)
        pending.append(text)
      | let pipe: _Pipe box =>
        // Flush pending literal before dynamic
        sink.literal(pending.clone())
        pending.clear()
        sink.dynamic_value(escaper.escape_pipe(_eval_pipe(pipe, values)))
      | let prop: _PropNode =>
        // Flush pending literal before dynamic
        sink.literal(pending.clone())
        pending.clear()
        let tv = try values._lookup(prop)? else
          sink.dynamic_value("")
          continue
        end
        let raw = try tv.string()? else "" end
        sink.dynamic_value(escaper.escape_prop(tv, raw))
      | let ctrl: (_If box | _IfNot box | _Loop box) =>
        // Flush pending literal before collapsed dynamic
        sink.literal(pending.clone())
        pending.clear()
        let inner: _StringSink ref = _StringSink
        _walk_inner(ctrl, values, inner, escaper)?
        sink.dynamic_value(inner.result())
      | let blk: _Block box =>
        // Transparent — walk body inline, literals merge with surroundings
        _walk_body(blk.body, values, sink, escaper, pending)?
      end
    end

  fun _walk_inner(
    part: (_If box | _IfNot box | _Loop box),
    values: TemplateValues box,
    sink: _StringSink ref,
    escaper: _Escaper ref
  )? =>
    """
    Walk a control flow subtree, collapsing its output into a single string
    via the given `_StringSink`. No interleaving enforcement — the sink
    receives raw literal/dynamic calls that concatenate into a single result.
    """
    match part
    | let if': _If box =>
      if
        try
          values._lookup(if'.value)?._is_truthy()
        else
          false
        end
      then
        _walk_inner_body(if'.body, values, sink, escaper)?
      else
        match if'.else_body
        | let eb: Array[_Part] box =>
          _walk_inner_body(eb, values, sink, escaper)?
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
          _walk_inner_body(eb, values, sink, escaper)?
        end
      else
        _walk_inner_body(ifnot.body, values, sink, escaper)?
      end
    | let loop: _Loop box =>
      for value in values._lookup(loop.source)?.values() do
        let body_values = values._override(loop.target, value)
        _walk_inner_body(loop.body, body_values, sink, escaper)?
      end
    end

  fun _walk_inner_body(
    parts: Array[_Part] box,
    values: TemplateValues box,
    sink: _StringSink ref,
    escaper: _Escaper ref
  )? =>
    """
    Walk parts inside a collapsed control flow subtree. All output goes
    directly to the string sink without interleaving enforcement.
    """
    for part in parts.values() do
      match part
      | (_Literal, let text: String) =>
        escaper.advance_literal(text)
        sink.literal(text)
      | let pipe: _Pipe box =>
        sink.dynamic_value(escaper.escape_pipe(_eval_pipe(pipe, values)))
      | let prop: _PropNode =>
        let tv = try values._lookup(prop)? else
          sink.dynamic_value("")
          continue
        end
        let raw = try tv.string()? else "" end
        sink.dynamic_value(escaper.escape_prop(tv, raw))
      | let if': _If box =>
        _walk_inner(if', values, sink, escaper)?
      | let ifnot: _IfNot box =>
        _walk_inner(ifnot, values, sink, escaper)?
      | let loop: _Loop box =>
        _walk_inner(loop, values, sink, escaper)?
      | let blk: _Block box =>
        _walk_inner_body(blk.body, values, sink, escaper)?
      end
    end

  fun _eval_pipe(pipe: _Pipe box, values: TemplateValues box): String =>
    """
    Evaluate a pipe expression: resolve the source, then apply each filter
    in order with its resolved arguments.
    """
    var current: String = match pipe.source
    | let s: String => s
    | let p: _PropNode =>
      try values._lookup(p)?.string()? else "" end
    end
    for (filter, args) in pipe.filters.values() do
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
    current
