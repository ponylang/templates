# templates

A template engine for Pony with optional HTML-aware contextual auto-escaping.

## Status

Templates is beta-level software. As it gets used in more projects, we may make breaking changes.

## Installation

* Install [corral](https://github.com/ponylang/corral)
* `corral add github.com/ponylang/templates.git --version 0.3.1`
* `corral fetch` to fetch your dependencies
* `use "templates"` to include this package
* `corral run -- ponyc` to compile your application

## Usage

Parse a template, bind values, and render:

```pony
use "templates"

actor Main
  new create(env: Env) =>
    let template =
      try
        Template.parse("Hello {{ name }}")?
      else
        env.err.print("Could not parse template")
        return
      end

    let values = TemplateValues
    values("name") = "world"

    try
      env.out.print(template.render(values)?)
    end
```

For HTML output, use `HtmlTemplate` to get automatic context-aware escaping:

```pony
let template =
  try
    HtmlTemplate.parse(
      "<h1>{{ title }}</h1><p>{{ message }}</p>")?
  else
    env.err.print("Could not parse template")
    return
  end

let values = TemplateValues
values("title") = "Hello & welcome"
values("message") = "<script>alert('xss')</script>"

try
  // Renders:
  // <h1>Hello &amp; welcome</h1>
  // <p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>
  env.out.print(template.render(values)?)
end
```

See the [examples](examples/) directory for more.

## Supported Features

* **Variables**: `{{ some_var }}` is replaced with the variable's value. A value
  can be a `String` or a `TemplateValue`. A `TemplateValue` is either a `String`
  or a `Seq[TemplateValue]`.
* **Properties**: `{{ some_var.prop }}` is replaced with value `some_var`'s
  property `prop`. Properties are part of `TemplateValue`: its constructor takes
  a `Map[String, TemplateValue]` that defines the value's properties.
* **Conditionals**: `{{ if flag }}...{{ end }}` renders content when the variable
  exists and, for sequences, is non-empty. Can check properties too. Supports
  `{{ else }}` and `{{ elseif other_flag }}` branches.
* **Negated conditionals**: `{{ ifnot flag }}...{{ end }}` renders content when
  the variable is absent or is an empty sequence. Supports `{{ else }}` and
  `{{ elseif }}` branches.
* **For loops**: `{{ for x in xs }}{{ x }} {{ end }}` iterates through the
  sequence `xs` and adds each element plus a space to the output.
* **Filters**: `{{ name | upper }}` pipes a value through one or more
  filters. Filters chain left-to-right: `{{ name | trim | upper }}`. The pipe
  source can be a template variable or a string literal:
  `{{ "hello" | upper }}`. Filter arguments can be string literals (`"hello"`)
  or template variables (`varname`). Built-in filters: `upper`, `lower`, `trim`,
  `capitalize`, `title`, `default("fallback")`, `replace("old", "new")`. Custom
  filters can be registered via `TemplateContext`.
* **Includes**: `{{ include "header" }}` inlines a named partial registered via
  `TemplateContext`. Partials share the same variable scope as the surrounding
  template and can contain any block type. Circular includes are detected at
  parse time.
* **Template inheritance**: A child template declares
  `{{ extends "base" }}` as its first statement and overrides named blocks
  defined in the base with `{{ block name }}...{{ end }}`. Base templates are
  registered as partials via `TemplateContext`. Blocks not overridden render
  their default content from the base. Multi-level inheritance is supported.
  Content outside `{{ block }}` definitions in a child template is silently
  ignored. Circular extends chains are detected at parse time.
* **Comments**: `{{! this is a comment }}` is ignored during rendering.
  Everything between `!` and `}}` is discarded. Trim markers work as expected:
  `{{!- comment -}}`.
* **Raw blocks**: `{{raw}}...{{end}}` emits everything between the tags as
  literal text, without interpreting `{{ }}` sequences. Useful when the template
  output itself contains delimiter syntax. Trim markers work on both tags:
  `{{- raw -}}...{{- end -}}`. The first `{{ end }}` closes the raw block, so
  literal `{{ end }}` cannot appear inside raw content.
* **Whitespace trimming**: `{{- x }}` strips trailing whitespace from the
  preceding literal, `{{ x -}}` strips leading whitespace from the following
  literal, `{{- x -}}` strips both. Useful for generating
  indentation-sensitive output (YAML, Python, Pony) without unwanted blank
  lines from control flow tags.
* **HTML auto-escaping**: `HtmlTemplate` automatically escapes variable output
  based on HTML context — text content gets entity escaping, URL attributes get
  scheme filtering and percent-encoding, script contexts get JS string escaping,
  and so on.
  Use `TemplateValue.unescaped` or `TemplateValues.unescaped` to bypass escaping
  for trusted content.

## API Documentation

[https://ponylang.github.io/templates](https://ponylang.github.io/templates)
