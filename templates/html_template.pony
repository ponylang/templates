use "collections"
use "files"
use "valbytes"


class val HtmlTemplate
  """
  An HTML-aware template engine with contextual auto-escaping.

  `HtmlTemplate` uses the same template syntax as `Template` but automatically
  escapes variable output based on HTML context. A variable inside a `<p>` tag
  gets HTML entity escaping; inside an `href` attribute it gets URL escaping
  and dangerous scheme filtering; inside an `onclick` attribute it gets
  JavaScript string escaping; and so on.

  Parse-time validation rejects templates with variables in structurally
  invalid positions (inside tag names, unquoted attribute values, etc.) and
  verifies that `if`/`else` branches and loops preserve HTML context
  consistency.

  To bypass auto-escaping for trusted content, use `TemplateValue.unescaped`
  or `TemplateValues.unescaped`. Plain `Template` ignores the escaping
  annotations entirely — they only take effect in `HtmlTemplate`.
  """
  let _parts: Array[_Part] box

  new val parse(
    source: String,
    ctx: TemplateContext val = TemplateContext()
  )? =>
    """
    Parse an HTML template from a string. Raises an error if the template
    has syntax errors or if variables appear in invalid HTML positions
    (tag names, unquoted attributes, etc.).
    """
    let parts = _ParserCommon.parse_template(source, ctx)?
    _validate(parts)?
    _parts = parts

  new val from_file(
    path: FilePath,
    ctx: TemplateContext val = TemplateContext()
  )? =>
    """
    Parse an HTML template from a file. Raises an error if the file cannot
    be read, the template has syntax errors, or variables appear in invalid
    HTML positions.
    """
    let chunk_size: USize = 1024 * 1024 * 1
    match OpenFile(path)
    | let file: File =>
      var data = ByteArrays()
      while file.errno() is FileOK do
        data = data + file.read(chunk_size)
      end
      let parts = _ParserCommon.parse_template(data.string(), ctx)?
      _validate(parts)?
      _parts = parts
    else error
    end

  fun render(values: TemplateValues box): String? =>
    """
    Render the template with the given values. Variable output is
    automatically escaped based on HTML context unless the value was
    created with `TemplateValue.unescaped`.
    """
    let sink: _StringSink ref = _StringSink
    let escaper: _HtmlEscaper ref = _HtmlEscaper(_HtmlContextTracker)
    _TemplateWalk.walk(_parts, values, sink, escaper)?
    sink.result()

  fun render_to(sink: TemplateSink ref, values: TemplateValues box)? =>
    """
    Walk the template and drive the given sink with alternating `literal` and
    `dynamic_value` calls. Dynamic values are already escaped based on HTML
    context — the sink receives final, safe strings. See `TemplateSink` for
    the interleaving guarantee.
    """
    let escaper: _HtmlEscaper ref = _HtmlEscaper(_HtmlContextTracker)
    _TemplateWalk.walk(_parts, values, sink, escaper)?

  fun render_split(
    values: TemplateValues box
  ): (Array[String] val, Array[String] val)? =>
    """
    Render the template and return the static literal segments and dynamic
    value segments as separate arrays. Dynamic values are already escaped
    based on HTML context. For N dynamic insertions, the statics array has
    N+1 entries. Concatenating `statics(0) + dynamics(0) + statics(1) +
    dynamics(1) + ... + statics(N)` produces the same result as `render()`.
    """
    let sink: _SplitSink ref = _SplitSink
    let escaper: _HtmlEscaper ref = _HtmlEscaper(_HtmlContextTracker)
    _TemplateWalk.walk(_parts, values, sink, escaper)?
    sink.result()

  fun tag _validate(parts: Array[_Part] box)? =>
    let tracker: _HtmlContextTracker ref = _HtmlContextTracker
    _validate_parts(parts, tracker)?

  fun tag _validate_parts(
    parts: Array[_Part] box,
    tracker: _HtmlContextTracker ref
  )? =>
    for part in parts.values() do
      match part
      | (_Literal, let text: String) =>
        tracker.feed(text)
        tracker.feed_close_tag(text)
      | let prop: _PropNode =>
        _check_insertion_point(tracker)?
      | let pipe: _Pipe box =>
        _check_insertion_point(tracker)?
      | let if': _If box =>
        let before = tracker.clone()
        _validate_parts(if'.body, tracker)?
        match if'.else_body
        | let eb: Array[_Part] box =>
          let else_tracker = before.clone()
          _validate_parts(eb, else_tracker)?
          if not tracker.eq(else_tracker) then error end
        else
          // No else branch — if-body must preserve context
          if not tracker.eq(before) then error end
        end
      | let ifnot: _IfNot box =>
        let before = tracker.clone()
        _validate_parts(ifnot.body, tracker)?
        match ifnot.else_body
        | let eb: Array[_Part] box =>
          let else_tracker = before.clone()
          _validate_parts(eb, else_tracker)?
          if not tracker.eq(else_tracker) then error end
        else
          if not tracker.eq(before) then error end
        end
      | let loop: _Loop box =>
        let before = tracker.clone()
        _validate_parts(loop.body, tracker)?
        if not tracker.eq(before) then error end
      | let blk: _Block box =>
        _validate_parts(blk.body, tracker)?
      end
    end

  fun tag _check_insertion_point(tracker: _HtmlContextTracker box)? =>
    match tracker.context()
    | CtxError => error
    end

