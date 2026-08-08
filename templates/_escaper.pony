interface ref _Escaper
  """
  Determines how literal text and dynamic values are processed during a
  template walk. `_IdentityEscaper` passes values through unchanged (for
  `Template`); `_HTMLEscaper` applies context-aware HTML escaping (for
  `HTMLTemplate`).
  """
  fun ref advance_literal(text: String)
  fun ref escape_pipe(value: String): String
  fun ref escape_prop(tv: TemplateValue box, raw: String): String

class ref _IdentityEscaper is _Escaper
  """
  No-op escaper for plain `Template` rendering. Values pass through unchanged.
  """
  fun ref advance_literal(text: String) =>
    None

  fun ref escape_pipe(value: String): String =>
    value

  fun ref escape_prop(tv: TemplateValue box, raw: String): String =>
    raw

class ref _HTMLEscaper is _Escaper
  """
  Context-aware HTML escaper for `HTMLTemplate` rendering. Tracks position
  within the HTML structure and applies the appropriate escaping strategy for
  each insertion point.
  """
  let _tracker: _HTMLContextTracker ref

  new ref create(tracker: _HTMLContextTracker ref) =>
    _tracker = tracker

  fun ref advance_literal(text: String) =>
    _tracker.feed(text)
    _tracker.feed_close_tag(text)

  fun ref escape_pipe(value: String): String =>
    _HTMLEscapingRenderer.render(_tracker.context(), value)

  fun ref escape_prop(tv: TemplateValue box, raw: String): String =>
    tv.renderable().render(_tracker.context(), raw)
