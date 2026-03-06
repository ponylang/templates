primitive _HtmlEscape
  fun for_context(context: _HtmlContext, raw: String): String =>
    """
    Apply context-appropriate escaping to the raw string.
    """
    match context
    | _CtxText => html_text(raw)
    | _CtxHtmlAttr => html_attr(raw)
    | _CtxUrlAttr => url_attr(raw)
    | _CtxJsAttr => js_string(raw)
    | _CtxCssAttr => css_value(raw)
    | _CtxScript => js_string(raw)
    | _CtxStyle => css_value(raw)
    | _CtxComment => comment(raw)
    | _CtxRcdata => rcdata(raw)
    | _CtxError => raw
    end

  fun html_text(raw: String): String val =>
    """
    Escape `& < > " '` to HTML entities.
    """
    recover val
      let out = String(raw.size())
      for c in raw.values() do
        match c
        | '&' => out.append("&amp;")
        | '<' => out.append("&lt;")
        | '>' => out.append("&gt;")
        | '"' => out.append("&#34;")
        | '\'' => out.append("&#39;")
        else
          out.push(c)
        end
      end
      out
    end

  fun html_attr(raw: String): String =>
    """
    Escape for quoted attribute values. Same entities as html_text.
    """
    html_text(raw)

  fun url_attr(raw: String): String =>
    """
    Filter dangerous URL schemes, then percent-encode special characters
    for use in a quoted URL attribute value.

    Blocks `javascript:`, `vbscript:`, and `data:` schemes by replacing
    the entire value with `#ZgotmplZ` (following Go's convention).
    """
    let trimmed = raw.clone()
    trimmed.lstrip()
    let lower = trimmed.clone()
    lower.lower_in_place()

    if _has_dangerous_scheme(consume lower) then
      return "#ZgotmplZ"
    end

    // Percent-encode characters that are unsafe in URL attribute context,
    // then HTML-entity-encode the result for embedding in an attribute.
    let url_encoded = _percent_encode(raw)
    html_attr(url_encoded)

  fun js_string(raw: String): String val =>
    """
    Escape for JavaScript string context. Escapes backslash, quotes,
    angle brackets, and non-ASCII to `\\xNN` / `\\uNNNN`.
    """
    recover val
      let out = String(raw.size())
      for c in raw.values() do
        match c
        | '\\' => out.append("\\\\")
        | '\'' => out.append("\\'")
        | '"' => out.append("\\\"")
        | '<' => out.append("\\x3c")
        | '>' => out.append("\\x3e")
        | '&' => out.append("\\x26")
        | '\n' => out.append("\\n")
        | '\r' => out.append("\\r")
        | '\t' => out.append("\\t")
        else
          if c < 0x20 then
            _hex_escape(out, c)
          elseif c >= 0x80 then
            _hex_escape(out, c)
          else
            out.push(c)
          end
        end
      end
      out
    end

  fun css_value(raw: String): String val =>
    """
    Escape for CSS value context. Escapes characters that could break out
    of a CSS value or inject expressions.
    """
    recover val
      let out = String(raw.size())
      for c in raw.values() do
        if _is_css_safe(c) then
          out.push(c)
        else
          _css_escape(out, c)
        end
      end
      out
    end

  fun comment(raw: String): String val =>
    """
    Escape for HTML comment context. Strips `--` sequences to prevent
    premature comment termination.
    """
    recover val
      let out = raw.clone()
      while out.contains("--") do
        out.replace("--", "")
      end
      out
    end

  fun rcdata(raw: String): String val =>
    """
    Escape for RCDATA context (title, textarea). Only `<` and `&` need
    escaping.
    """
    recover val
      let out = String(raw.size())
      for c in raw.values() do
        match c
        | '&' => out.append("&amp;")
        | '<' => out.append("&lt;")
        else
          out.push(c)
        end
      end
      out
    end

  fun _has_dangerous_scheme(lower: String val): Bool =>
    // Caller must pass a trimmed, lowered string.
    (lower.substring(0, 11) == "javascript:")
      or (lower.substring(0, 9) == "vbscript:")
      or (lower.substring(0, 5) == "data:")

  fun _percent_encode(raw: String): String val =>
    recover val
      let out = String(raw.size())
      for c in raw.values() do
        if _is_url_safe(c) then
          out.push(c)
        else
          out.push('%')
          out.push(_hex_digit((c >> 4) and 0x0F))
          out.push(_hex_digit(c and 0x0F))
        end
      end
      out
    end

  fun _is_url_safe(c: U8): Bool =>
    ((c >= 'a') and (c <= 'z'))
      or ((c >= 'A') and (c <= 'Z'))
      or ((c >= '0') and (c <= '9'))
      or (c == '-') or (c == '_') or (c == '.')
      or (c == '~') or (c == '/') or (c == ':')
      or (c == '?') or (c == '#') or (c == '[')
      or (c == ']') or (c == '@') or (c == '!')
      or (c == '$') or (c == '&') or (c == '\'')
      or (c == '(') or (c == ')') or (c == '*')
      or (c == '+') or (c == ',') or (c == ';')
      or (c == '=') or (c == '%')

  fun _hex_escape(out: String ref, c: U8) =>
    out.append("\\x")
    out.push(_hex_digit((c >> 4) and 0x0F))
    out.push(_hex_digit(c and 0x0F))

  fun _css_escape(out: String ref, c: U8) =>
    out.push('\\')
    out.push(_hex_digit((c >> 4) and 0x0F))
    out.push(_hex_digit(c and 0x0F))
    out.push(' ')

  fun _is_css_safe(c: U8): Bool =>
    ((c >= 'a') and (c <= 'z'))
      or ((c >= 'A') and (c <= 'Z'))
      or ((c >= '0') and (c <= '9'))
      or (c == ' ') or (c == '_') or (c == '-')
      or (c == '.') or (c == ',') or (c == '/')

  fun _hex_digit(n: U8): U8 =>
    if n < 10 then '0' + n
    else ('a' - 10) + n
    end


interface val _RenderableValue
  """
  Determines how a template value is rendered within an HTML context.
  The renderer passes the current HTML context and the raw string value;
  the implementation decides whether and how to escape.
  """
  fun val render(context: _HtmlContext, raw: String): String


primitive _HtmlEscapingRenderer is _RenderableValue
  """
  Applies context-appropriate HTML escaping. This is the default renderer
  for template values used with `HtmlTemplate`.
  """
  fun val render(context: _HtmlContext, raw: String): String =>
    _HtmlEscape.for_context(context, raw)


primitive _NoEscapeRenderer is _RenderableValue
  """
  Returns content unchanged, bypassing auto-escaping. Used for values
  explicitly marked as unescaped via `TemplateValue.unescaped`.
  """
  fun val render(context: _HtmlContext, raw: String): String =>
    raw
