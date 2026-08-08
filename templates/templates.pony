"""
A text-based template engine with optional HTML auto-escaping.

Two template types are available:

* `Template` renders values as-is, with no escaping. Suitable for plain text,
  configuration files, or contexts where HTML safety is not a concern.
* `HTMLTemplate` automatically escapes variable output based on HTML context —
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
  `{{ name | trim | upper | default("ANON") }}`. The pipe source can be
  a template variable or a string literal: `{{ "hello" | upper }}`. Seven
  built-in filters are available without registration: `upper`, `lower`,
  `trim`, `capitalize`, `title`, `default("fallback")`, and
  `replace("old", "new")`. Custom filters can be registered via
  `TemplateContext`. Filter arguments can be string literals (`"hello"`)
  or template variables (`varname`).
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
* **Raw / literal blocks**: `{{raw}}...{{end}}` emits everything between
  the tags as literal text, without interpreting `{{ }}` sequences. Useful
  when the template output itself contains delimiter syntax (e.g., generating
  Mustache templates or documentation about this library). Trim markers work
  on both tags: `{{- raw -}}...{{- end -}}`. The first `{{ end }}` closes
  the raw block, so literal `{{ end }}` cannot appear inside raw content.
* **Comments**: `{{! ... }}` is ignored during rendering. Everything between
  `!` and `}}` is discarded. Comments can appear anywhere a normal block can
  appear, and trim markers work as expected: `{{!- comment -}}`.

## Rendering modes

Both `Template` and `HTMLTemplate` support three rendering methods:

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
