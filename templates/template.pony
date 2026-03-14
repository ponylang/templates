"""
A text-based template engine with optional HTML auto-escaping.

Two template types are available:

* `Template` renders values as-is, with no escaping. Suitable for plain text,
  configuration files, or contexts where HTML safety is not a concern.
* `HtmlTemplate` automatically escapes variable output based on HTML context —
  text content gets entity escaping, URL attributes get scheme filtering and
  percent-encoding, script contexts get JS string escaping, and so on.
  Use `TemplateValue.unescaped` to bypass escaping for trusted content.

Both types share the same template syntax. Templates are strings containing
literal text interspersed with `{{ ... }}` blocks. Supported block types:

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
  `{{ name | trim | upper | default("ANON") }}`. The pipe source can be a
  template variable or a string literal: `{{ "hello" | upper }}`. Seven
  built-in filters are available without registration: `upper`, `lower`,
  `trim`, `capitalize`, `title`, `default("fallback")`, and
  `replace("old", "new")`. Custom filters can be registered via
  `TemplateContext`. Filter arguments can be string literals (`"hello"`) or
  template variables (`varname`).
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
* **Raw / literal blocks**: `{{raw}}...{{end}}` emits everything between the
  tags as literal text, without interpreting `{{ }}` sequences. Useful when the
  template output itself contains delimiter syntax (e.g., generating Mustache
  templates or documentation about this library). Trim markers work on both tags:
  `{{- raw -}}...{{- end -}}`. The first `{{ end }}` closes the raw block, so
  literal `{{ end }}` cannot appear inside raw content.
* **Comments**: `{{! ... }}` is ignored during rendering. Everything between `!`
  and `}}` is discarded. Comments can appear anywhere a normal block can appear,
  and trim markers work as expected: `{{!- comment -}}`.

## Rendering modes

Both `Template` and `HtmlTemplate` support three rendering methods:

* `render(values)` returns the complete output as a single `String`.
* `render_to(sink, values)` drives a caller-supplied `TemplateSink` with
  separate `literal` and `dynamic_value` calls, enabling use cases like
  tagged template literals or custom output assembly.
  Calls strictly alternate between `literal` and `dynamic_value`, starting
  and ending with `literal` — for N dynamic insertions, exactly N+1 literal
  calls are made. Control flow subtrees (`if`, `ifnot`, `for`) collapse into
  a single `dynamic_value` call; `block` is transparent (its literals merge
  with surroundings).
* `render_split(values)` returns `(Array[String] val, Array[String] val)` —
  the statics and dynamics arrays separately, maintaining the same
  interleaving guarantee.
"""

use "collections"
use "files"
use "valbytes"


primitive _Literal

primitive _RegularBlock
primitive _CommentBlock
primitive _RawBlock
type _BlockKind is (_RegularBlock | _CommentBlock | _RawBlock)

// A resolved filter argument: either a string literal or a property reference.
type _ResolvedArg is (String | _PropNode)

class _Pipe
  """
  A fully resolved pipe expression ready for rendering. The source — either a
  property reference or a string literal — is piped through each filter in
  order. Each filter has been validated at parse time for existence and correct
  arity.
  """
  let source: (_PropNode | String)
  let filters: Array[(AnyFilter, Array[_ResolvedArg] box)] box

  new box create(
    source': (_PropNode | String),
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
  Marker on the open-block stack indicating an `if` block that has transitioned
  to its `else` branch. Stores the original condition and if-body so they can
  be assembled into the final `_If` node when `end` is encountered.
  """
  let value: _PropNode
  let if_body: Array[_Part] box

  new box create(value': _PropNode, if_body': Array[_Part] box) =>
    value = value'
    if_body = if_body'

class box _IfNotElse
  """
  Marker on the open-block stack indicating an `ifnot` block that has
  transitioned to its `else` branch. Stores the original condition and if-body
  so they can be assembled into the final `_IfNot` node when `end` is
  encountered.
  """
  let value: _PropNode
  let if_body: Array[_Part] box

  new box create(value': _PropNode, if_body': Array[_Part] box) =>
    value = value'
    if_body = if_body'

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

  When used with `HtmlTemplate`, values are automatically escaped based on
  their HTML context. To bypass escaping for trusted content, use the
  `unescaped` constructor instead of `create`.
  """
  let _data: (String | Seq[TemplateValue] box)
  let _properties: Map[String, TemplateValue] box
  let _renderable: RenderableValue

  new box create(
    value: (String | Seq[TemplateValue] box),
    properties: Map[String, TemplateValue] box = Map[String, TemplateValue]
  ) =>
    _data = value
    _properties = properties
    _renderable = _HtmlEscapingRenderer

  new box unescaped(
    value: (String | Seq[TemplateValue] box),
    properties: Map[String, TemplateValue] box = Map[String, TemplateValue]
  ) =>
    """
    Create a value that bypasses HTML auto-escaping in `HtmlTemplate`.
    The content is inserted as-is, without context-aware escaping. Use this
    only for content you trust (e.g., pre-sanitized HTML fragments).

    Has no effect when used with plain `Template`, which does not escape.

    Note: the unescaped annotation applies only to direct variable
    substitution (`{{ name }}`). When a value passes through a filter pipe
    (`{{ name | upper }}`), the result is always escaped — filters could
    introduce unsafe content.
    """
    _data = value
    _properties = properties
    _renderable = _NoEscapeRenderer

  fun apply(name: String): TemplateValue? => _properties(name)?

  fun string(): String? => _data as String

  fun renderable(): RenderableValue =>
    """
    The rendering strategy for this value. `HtmlTemplate` calls this to
    determine how to escape the value based on HTML context.
    """
    _renderable

  fun values(): Iterator[TemplateValue] =>
    match _data
    | let seq: Seq[TemplateValue] box => seq.values()
    else Array[TemplateValue].values()
    end

  fun box _is_truthy(): Bool =>
    match _data
    | let _: String => true
    | let seq: Seq[TemplateValue] box => seq.values().has_next()
    end


class TemplateValues
  """
  A scoped key-value store for template rendering. Values are stored as
  `TemplateValue` entries and looked up by name. Lookups check the local
  scope first, then walk up the parent chain.

  Use `scope()` to create a writable child that inherits all values from
  this set without copying. Use `update()` and `unescaped()` to add values.
  """
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
    """
    Store a value under the given name. String values are wrapped in a
    `TemplateValue` automatically. This is also the target of Pony's
    sugar for `values("key") = "value"`.
    """
    _values(name) = match value
    | let string: String => TemplateValue(string)
    | let template_value: TemplateValue => template_value
    end

  fun ref unescaped(name: String, value: String) =>
    """
    Store a string value that bypasses HTML auto-escaping in `HtmlTemplate`.
    See `TemplateValue.unescaped` for details. For structured values (with
    properties or sequences), use `TemplateValue.unescaped()` directly and
    pass the result to `update()`.
    """
    _values(name) = TemplateValue.unescaped(value)

  fun box scope(): TemplateValues =>
    """
    Create an empty writable child scope backed by this value set as a
    read-only parent. Writes go to the child; lookups that miss in the
    child fall through to the parent.
    """
    TemplateValues._create(this, Map[String, TemplateValue])

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


class box _BlockScan
  """
  Result of scanning a single `{{ }}` block from the template source. Holds
  the extracted statement content and positional metadata needed by the outer
  parsing loop. The `kind` field distinguishes regular, comment, and raw blocks.
  """
  let stmt_source: String
  let start_pos: ISize
  let end_pos: ISize
  let left_trim: Bool
  let right_trim: Bool
  let kind: _BlockKind

  new box create(
    stmt_source': String,
    start_pos': ISize,
    end_pos': ISize,
    left_trim': Bool,
    right_trim': Bool,
    kind': _BlockKind
  ) =>
    stmt_source = stmt_source'
    start_pos = start_pos'
    end_pos = end_pos'
    left_trim = left_trim'
    right_trim = right_trim'
    kind = kind'


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
    Called with a resolved (and, for `HtmlTemplate`, already-escaped) dynamic
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


class val Template
  let _parts: Array[_Part] box

  new val parse(source: String, ctx: TemplateContext val = TemplateContext())? =>
    _parts = _ParserCommon.parse_template(source, ctx)?

  new val from_file(path: FilePath, ctx: TemplateContext val = TemplateContext())? =>
    let chunk_size: USize = 1024 * 1024 * 1
    match OpenFile(path)
    | let file: File =>
      var data = ByteArrays()
      while file.errno() is FileOK do
        data = data + file.read(chunk_size)
      end
      _parts = _ParserCommon.parse_template(data.string(), ctx)?
    else error
    end

  fun render(values: TemplateValues box): String? =>
    """
    Render the template with the given values and return the result as a
    single string.
    """
    let sink: _StringSink ref = _StringSink
    let escaper: _IdentityEscaper ref = _IdentityEscaper
    _TemplateWalk.walk(_parts, values, sink, escaper)?
    sink.result()

  fun render_to(sink: TemplateSink ref, values: TemplateValues box)? =>
    """
    Walk the template and drive the given sink with alternating `literal` and
    `dynamic_value` calls. Values are not escaped — they pass through as-is.
    See `TemplateSink` for the interleaving guarantee.
    """
    let escaper: _IdentityEscaper ref = _IdentityEscaper
    _TemplateWalk.walk(_parts, values, sink, escaper)?

  fun render_split(
    values: TemplateValues box
  ): (Array[String] val, Array[String] val)? =>
    """
    Render the template and return the static literal segments and dynamic
    value segments as separate arrays. For N dynamic insertions, the statics
    array has N+1 entries. Concatenating `statics(0) + dynamics(0) +
    statics(1) + dynamics(1) + ... + statics(N)` produces the same result
    as `render()`.
    """
    let sink: _SplitSink ref = _SplitSink
    let escaper: _IdentityEscaper ref = _IdentityEscaper
    _TemplateWalk.walk(_parts, values, sink, escaper)?
    sink.result()
