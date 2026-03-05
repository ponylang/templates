## Add else and elseif branches to if blocks

`if` blocks now support `else` and `elseif` branches, so you no longer need to duplicate content with negated conditions.

```pony
let t = Template.parse(
  "{{ if admin }}admin panel" +
  "{{ elseif member }}member area" +
  "{{ else }}public page{{ end }}")?
```

`elseif` chains can be as long as needed. A final `else` branch is optional and renders when no condition matches.

`if` checks both existence and non-emptiness: a variable bound to an empty sequence is falsy, so `{{ if items }}` naturally guards a loop without a separate check.

## Add `ifnot` negated conditional blocks

`ifnot` renders its body when a variable is absent or is an empty sequence — the logical inverse of `if`. This lets you write the "missing" case as the primary branch instead of requiring an `if`/`else` just to get at the `else`.

```pony
let t = Template.parse(
  "{{ ifnot name }}Anonymous{{ end }}")?
```

Like `if`, `ifnot` supports `else` and `elseif` branches:

```pony
let t = Template.parse(
  "{{ ifnot name }}Anonymous{{ else }}{{ name }}{{ end }}")?
```
## Unify `if` and `ifnotempty` conditionals

`ifnotempty` has been removed. `if` now checks both existence and sequence non-emptiness, making `ifnotempty` redundant.

Before:

```pony
let t = Template.parse(
  "{{ ifnotempty items }}{{ for i in items }}{{ i }}{{ end }}{{ end }}")?
```

After:

```pony
let t = Template.parse(
  "{{ if items }}{{ for i in items }}{{ i }}{{ end }}{{ end }}")?
```

Unlike `ifnotempty`, `if` supports `else` and `elseif` branches:

```pony
let t = Template.parse(
  "{{ if items }}{{ for i in items }}{{ i }}{{ end }}" +
  "{{ else }}no items{{ end }}")?
```

## Add `include` partials

Templates can now reuse shared fragments via `{{ include "name" }}`. Partials are raw template strings registered in `TemplateContext` and inlined at parse time. They share the calling template's variable scope and can contain any block type (variables, loops, conditionals). Circular includes are detected at parse time.

```pony
let ctx = TemplateContext(where partials' =
  recover val
    let p = Map[String, String]
    p("header") = "=== {{ title }} ==="
    p
  end
)

let template = Template.parse(
  "{{ include \"header\" }}\n{{ for item in items }}{{ item }}\n{{ end }}",
  ctx)?
```

Partial names may contain letters, digits, underscores, and hyphens (`[a-zA-Z0-9_-]+`).

## Add template inheritance

Templates can now extend a base layout and override named blocks. A base template defines `{{ block name }}...{{ end }}` sections with default content. A child template declares `{{ extends "base" }}` as its first statement and overrides specific blocks — blocks not overridden render their defaults from the base.

```pony
let ctx = TemplateContext(where partials' =
  recover val
    let p = Map[String, String]
    p("base") =
      "<head>{{ block head }}<title>Default</title>{{ end }}</head>" +
      "<body>{{ block content }}{{ end }}</body>"
    p
  end
)

let template = Template.parse(
  "{{ extends \"base\" }}" +
  "{{ block head }}<title>{{ title }}</title>{{ end }}" +
  "{{ block content }}<h1>{{ title }}</h1>{{ end }}",
  ctx)?
```

Base templates are registered as partials via `TemplateContext` — the same mechanism used by `include`. Multi-level inheritance works naturally (child extends parent extends grandparent). Content outside `{{ block }}` definitions in a child is silently ignored. Circular extends chains are detected at parse time.

## Add default values for missing variables

Missing variables in templates render as empty strings, with no way to provide a fallback. `| default("...")` lets template authors declare what to show when a variable is absent.

```pony
let t = Template.parse(
  "Hello {{ name | default(\"stranger\") }}")?

// name is missing — renders "Hello stranger"
t.render(TemplateValues)?

// name is present — renders "Hello Alice"
let v = TemplateValues
v("name") = "Alice"
t.render(v)?
```

Defaults work with dotted properties and can be chained with other filters:

```pony
// Dotted property with default
Template.parse("{{ user.name | default(\"anon\") }}")?

// Default chained with upper
Template.parse("{{ name | default(\"anon\") | upper }}")?
```

Defaults are not allowed in control flow conditions (`if`, `ifnot`, `elseif`, `for ... in`) — pipes are only valid in expression positions.

## Add trim syntax for whitespace control

Templates now support `{{-` and `-}}` trim markers that strip whitespace from adjacent literals. `{{-` removes trailing whitespace (spaces, tabs, newlines) from the text before the tag, `-}}` removes leading whitespace from the text after it. Use both together with `{{- ... -}}` to strip in both directions.

This matters most when generating indentation-sensitive output like YAML or Python. Without trimming, control flow tags (`if`, `for`, `end`) inject blank lines and leading whitespace into the output because the newlines around the tags themselves become part of the rendered text. Trim markers let you eliminate that whitespace without cramming everything onto one line.

```pony
let values = TemplateValues
values("name") = "app"
values("services") = TemplateValue(
  recover val
    let s = Array[TemplateValue]
    s.push(TemplateValue("web"))
    s.push(TemplateValue("db"))
    s
  end)

let t = Template.parse(
  "name: {{ name }}\n" +
  "services:\n" +
  "{{ for svc in services -}}" +
  "\n- {{ svc }}\n" +
  "{{ end }}")?

t.render(values)?
// name: app
// services:
// - web
// - db
```

The right-trim on the `for` tag strips the newline that would otherwise appear before the first list item. Either marker can be used independently — you pick which side to trim based on where the unwanted whitespace is.

