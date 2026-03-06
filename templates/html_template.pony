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
    let tracker: _HtmlContextTracker ref = _HtmlContextTracker
    _render_parts(_parts, values, tracker)?

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

  fun tag _render_parts(
    parts: Array[_Part] box,
    values: TemplateValues box,
    tracker: _HtmlContextTracker ref
  ): String? =>
    var result = ByteArrays()
    for part in parts.values() do
      match part
      | (_Literal, let text: String) =>
        tracker.feed(text)
        tracker.feed_close_tag(text)
        result = result + text
      | let pipe: _Pipe box =>
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
        // Pipe results are always escaped — no TemplateValue to check
        result = result + _HtmlEscapingRenderer.render(
          tracker.context(), current)
      | let prop: _PropNode =>
        let tv = try values._lookup(prop)? else
          // Missing value — render empty, same as Template
          result = result + ""
          continue
        end
        let raw = try tv.string()? else "" end
        result = result + tv.renderable().render(tracker.context(), raw)
      | let if': _If box =>
        if
          try
            values._lookup(if'.value)?._is_truthy()
          else
            false
          end
        then
          result = result + _render_parts(if'.body, values, tracker)?
        else
          match if'.else_body
          | let eb: Array[_Part] box =>
            result = result + _render_parts(eb, values, tracker)?
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
            result = result + _render_parts(eb, values, tracker)?
          end
        else
          result = result + _render_parts(ifnot.body, values, tracker)?
        end
      | let loop: _Loop box =>
        for value in values._lookup(loop.source)?.values() do
          let body_values = values._override(loop.target, value)
          result = result + _render_parts(loop.body, body_values, tracker)?
        end
      | let blk: _Block box =>
        result = result + _render_parts(blk.body, values, tracker)?
      end
    end
    result.string()
