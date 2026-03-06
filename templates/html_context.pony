primitive _CtxText
primitive _CtxHtmlAttr
primitive _CtxUrlAttr
primitive _CtxJsAttr
primitive _CtxCssAttr
primitive _CtxScript
primitive _CtxStyle
primitive _CtxComment
primitive _CtxRcdata
primitive _CtxError

type _HtmlContext is
  ( _CtxText | _CtxHtmlAttr | _CtxUrlAttr | _CtxJsAttr | _CtxCssAttr
  | _CtxScript | _CtxStyle | _CtxComment | _CtxRcdata | _CtxError )


primitive _StateText
primitive _StateTag
primitive _StateAttrName
primitive _StateAfterAttrName
primitive _StateBeforeAttrVal
primitive _StateDqAttrVal
primitive _StateSqAttrVal
primitive _StateUnqAttrVal
primitive _StateComment
primitive _StateRcdata
primitive _StateScript
primitive _StateStyle

type _HtmlState is
  ( _StateText | _StateTag | _StateAttrName | _StateAfterAttrName
  | _StateBeforeAttrVal | _StateDqAttrVal | _StateSqAttrVal
  | _StateUnqAttrVal | _StateComment | _StateRcdata
  | _StateScript | _StateStyle )


class _HtmlContextTracker
  """
  Character-by-character HTML state machine that tracks position within HTML
  structure. Used at both parse time (to validate insertion points) and render
  time (to determine context-appropriate escaping).
  """
  var _state: _HtmlState = _StateText
  var _tag_name: String ref = String
  var _attr_name: String ref = String
  var _tag_name_done: Bool = false

  fun ref feed(text: String) =>
    """
    Advance the state machine through a chunk of literal text. Each chunk
    should be a single literal segment between template insertion points.
    After calling feed(), call feed_close_tag() with the same text to detect
    closing tags for script, style, rcdata, and comment states. The two-pass
    design assumes closing tags appear at chunk boundaries (guaranteed by the
    template parser splitting at `{{ }}` delimiters).
    """
    var i: USize = 0
    while i < text.size() do
      try _feed_byte(text(i)?) end
      i = i + 1
    end

  fun ref _feed_byte(c: U8) =>
    match _state
    | _StateText => _in_text(c)
    | _StateTag => _in_tag(c)
    | _StateAttrName => _in_attr_name(c)
    | _StateAfterAttrName => _in_after_attr_name(c)
    | _StateBeforeAttrVal => _in_before_attr_val(c)
    | _StateDqAttrVal => if c == '"' then _state = _StateTag end
    | _StateSqAttrVal => if c == '\'' then _state = _StateTag end
    | _StateUnqAttrVal => _in_unq_attr_val(c)
    | _StateComment => _in_comment(c)
    | _StateRcdata => _in_rcdata(c)
    | _StateScript => _in_script(c)
    | _StateStyle => _in_style(c)
    end

  fun ref _in_text(c: U8) =>
    if c == '<' then
      _tag_name = String
      _tag_name_done = false
      _state = _StateTag
    end

  fun ref _in_tag(c: U8) =>
    if c == '>' then
      _transition_after_tag()
    elseif _is_ws(c) then
      _tag_name_done = true
    elseif c == '/' then
      _tag_name_done = true
    elseif not _tag_name_done then
      // Still building tag name
      if c == '!' then
        _tag_name.push(c)
      else
        _tag_name.push(_lower(c))
      end
      if _starts_comment() then
        _state = _StateComment
      end
    else
      // After tag name — start of attribute
      _attr_name = String
      _attr_name.push(_lower(c))
      _state = _StateAttrName
    end

  fun _starts_comment(): Bool =>
    try
      (_tag_name.size() >= 3)
        and (_tag_name(0)? == '!')
        and (_tag_name(1)? == '-')
        and (_tag_name(2)? == '-')
    else false
    end

  fun ref _in_attr_name(c: U8) =>
    if c == '=' then
      _state = _StateBeforeAttrVal
    elseif c == '>' then
      _transition_after_tag()
    elseif _is_ws(c) then
      _state = _StateAfterAttrName
    elseif _is_name_char(c) then
      _attr_name.push(_lower(c))
    else
      _state = _StateTag
    end

  fun ref _in_after_attr_name(c: U8) =>
    if c == '=' then
      _state = _StateBeforeAttrVal
    elseif c == '>' then
      _transition_after_tag()
    elseif _is_ws(c) then
      None
    else
      // New attribute without value
      _attr_name = String
      _attr_name.push(_lower(c))
      _state = _StateAttrName
    end

  fun ref _in_before_attr_val(c: U8) =>
    if c == '"' then
      _state = _StateDqAttrVal
    elseif c == '\'' then
      _state = _StateSqAttrVal
    elseif _is_ws(c) then
      None
    elseif c == '>' then
      _transition_after_tag()
    else
      _state = _StateUnqAttrVal
    end

  fun ref _in_unq_attr_val(c: U8) =>
    if _is_ws(c) then
      _state = _StateTag
    elseif c == '>' then
      _transition_after_tag()
    end

  fun ref _in_comment(c: U8) =>
    // No-op per byte. Closing "-->" is detected by feed_close_tag().
    None

  fun ref _in_rcdata(c: U8) =>
    // No-op per byte. Closing tags are detected by feed_close_tag().
    None

  fun ref _in_script(c: U8) =>
    // No-op per byte. Closing </script> is detected by feed_close_tag().
    None

  fun ref _in_style(c: U8) =>
    // No-op per byte. Closing </style> is detected by feed_close_tag().
    None

  fun ref _transition_after_tag() =>
    // _tag_name is already lowered during construction in _in_tag
    if (_tag_name == "script") then
      _state = _StateScript
    elseif (_tag_name == "style") then
      _state = _StateStyle
    elseif (_tag_name == "title") or (_tag_name == "textarea") then
      _state = _StateRcdata
    else
      _state = _StateText
    end
    _tag_name = String
    _attr_name = String
    _tag_name_done = false

  fun ref feed_close_tag(text: String) =>
    """
    Scan literal text for closing tags that would change the state back
    to text. Must be called after feed() for states that need closing tag
    detection (script, style, rcdata).
    """
    match _state
    | _StateScript =>
      if _contains_close_tag(text, "script") then
        _state = _StateText
      end
    | _StateStyle =>
      if _contains_close_tag(text, "style") then
        _state = _StateText
      end
    | _StateRcdata =>
      if _contains_close_tag(text, "title")
        or _contains_close_tag(text, "textarea")
      then
        _state = _StateText
      end
    | _StateComment =>
      if text.contains("-->") then
        _state = _StateText
      end
    end

  fun _contains_close_tag(text: String, tag_name: String): Bool =>
    // Look for </tag> case-insensitively, allowing optional whitespace
    // before >. Per the HTML spec, </script > is a valid closing tag.
    let lower = text.clone()
    lower.lower_in_place()
    let prefix = recover val
      let s = String(tag_name.size() + 2)
      s.append("</")
      s.append(tag_name)
      s
    end
    // Scan for the prefix, then check that only whitespace follows before >
    var pos: USize = 0
    try
      while pos < lower.size() do
        let remaining = lower.substring(pos.isize())
        if remaining.at(prefix) then
          var j = pos + prefix.size()
          // Skip optional whitespace
          while (j < lower.size()) and _is_ws(lower(j)?) do
            j = j + 1
          end
          if (j < lower.size()) and (lower(j)? == '>') then
            return true
          end
        end
        pos = pos + 1
      end
    end
    false

  fun context(): _HtmlContext =>
    """
    Return the current escaping context based on state and attribute name.
    """
    match _state
    | _StateText => _CtxText
    | _StateDqAttrVal => _attr_context()
    | _StateSqAttrVal => _attr_context()
    | _StateUnqAttrVal => _CtxError
    | _StateScript => _CtxScript
    | _StateStyle => _CtxStyle
    | _StateComment => _CtxComment
    | _StateRcdata => _CtxRcdata
    | _StateTag => _CtxError
    | _StateAttrName => _CtxError
    | _StateAfterAttrName => _CtxError
    | _StateBeforeAttrVal => _CtxError
    end

  fun _attr_context(): _HtmlContext =>
    if _is_url_attr() then _CtxUrlAttr
    elseif _is_js_attr() then _CtxJsAttr
    elseif _is_css_attr() then _CtxCssAttr
    else _CtxHtmlAttr
    end

  fun _is_url_attr(): Bool =>
    // _attr_name is already lowered during construction
    (_attr_name == "href") or (_attr_name == "src") or (_attr_name == "action")
      or (_attr_name == "formaction") or (_attr_name == "cite")
      or (_attr_name == "data") or (_attr_name == "poster")

  fun _is_js_attr(): Bool =>
    // _attr_name is already lowered during construction
    try
      (_attr_name.size() >= 2)
        and (_attr_name(0)? == 'o')
        and (_attr_name(1)? == 'n')
    else false
    end

  fun _is_css_attr(): Bool =>
    // _attr_name is already lowered during construction
    _attr_name == "style"

  fun state(): _HtmlState => _state

  fun clone(): _HtmlContextTracker ref^ =>
    let c = _HtmlContextTracker
    c._state = _state
    c._tag_name = _tag_name.clone()
    c._attr_name = _attr_name.clone()
    c._tag_name_done = _tag_name_done
    c

  fun eq(other: _HtmlContextTracker box): Bool =>
    (_state is other._state)
      and (_tag_name == other._tag_name)
      and (_attr_name == other._attr_name)
      and (_tag_name_done == other._tag_name_done)

  fun _is_ws(c: U8): Bool =>
    (c == ' ') or (c == '\t') or (c == '\n') or (c == '\r')

  fun _is_name_char(c: U8): Bool =>
    ((c >= 'a') and (c <= 'z'))
      or ((c >= 'A') and (c <= 'Z'))
      or ((c >= '0') and (c <= '9'))
      or (c == '-') or (c == '_')

  fun _lower(c: U8): U8 =>
    if (c >= 'A') and (c <= 'Z') then c + 32 else c end
