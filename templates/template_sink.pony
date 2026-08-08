interface ref TemplateSink
  """
  Receives the output of a template walk as a sequence of literal and dynamic
  segments. Calls strictly alternate between `literal` and `dynamic_value`,
  starting and ending with `literal`. For N dynamic insertions, exactly N+1
  literal calls are made. Empty strings are used where needed to maintain this
  interleaving invariant.

  Control flow subtrees (`if`, `ifnot`, `for`) collapse into a single
  `dynamic_value` call containing the fully rendered branch or loop output.
  `block` is transparent — its literal content merges into the surrounding
  literal segments.
  """
  fun ref literal(text: String)
    """
    Called with a static template segment. May be an empty string when two
    dynamic values are adjacent or at template boundaries.
    """

  fun ref dynamic_value(value: String)
    """
    Called with a resolved (and, for `HTMLTemplate`, already-escaped) dynamic
    value. For control flow subtrees, contains the fully rendered branch or
    loop output as a single string.
    """

class ref _SplitSink is TemplateSink
  """
  Collects literal and dynamic segments into separate arrays for
  `render_split()`.
  """
  var _statics: Array[String] iso = recover iso Array[String] end
  var _dynamics: Array[String] iso = recover iso Array[String] end

  fun ref literal(text: String) =>
    _statics.push(text)

  fun ref dynamic_value(value: String) =>
    _dynamics.push(value)

  fun ref result(): (Array[String] val, Array[String] val) =>
    let s: Array[String] val = _statics = recover iso Array[String] end
    let d: Array[String] val = _dynamics = recover iso Array[String] end
    (s, d)
