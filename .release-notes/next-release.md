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

## Replace function calls with filter pipes

Function calls (`{{ fn(arg) }}`) have been replaced by a filter/pipe system. Values are now transformed by piping them through one or more filters: `{{ value | filter1 | filter2 }}`. The pipe source can be a template variable or a string literal: `{{ "hello" | upper }}`.

Seven built-in filters are available in all templates without registration:

- `upper` — uppercase
- `lower` — lowercase
- `trim` — strip leading/trailing whitespace
- `capitalize` — first character upper, rest lower
- `title` — title case each word
- `default("fallback")` — use fallback when the value is empty or missing
- `replace("old", "new")` — replace all occurrences

Before:

```pony
let ctx = TemplateContext(
  recover
    let functions = Map[String, {(String): String}]
    functions("upper") = {(s) =>
      let out = s.clone()
      out.upper_in_place()
      consume out
    }
    functions
  end
)

let t = Template.parse("{{ upper(name) }}", ctx)?
```

After:

```pony
// upper is built-in — no registration needed
let t = Template.parse("{{ name | upper }}")?
```

Filters can be chained left-to-right and accept string literal or variable arguments:

```pony
Template.parse("{{ name | default(\"anon\") | upper }}")?

// String literal as pipe source — no variable needed
Template.parse("{{ \"hello world\" | upper }}")?
```

The `TemplateContext` constructor's `functions` parameter has been replaced by `filters`. Custom filters implement `Filter` (0 extra args), `Filter2` (1 extra arg), or `Filter3` (2 extra args):

Before:

```pony
let ctx = TemplateContext(
  recover
    let functions = Map[String, {(String): String}]
    functions("yell") = {(s) => s.upper()}
    functions
  end,
  partials
)
```

After:

```pony
let ctx = TemplateContext(
  recover val
    let filters = Map[String, AnyFilter]
    filters("yell") = Upper  // reuse built-in, or provide a custom primitive
    filters
  end,
  partials
)
```

Filters are validated at parse time — unknown filter names and arity mismatches produce parse errors rather than runtime failures.

## Add template comments

Templates now support comments with `{{! ... }}` syntax. Everything between `!` and `}}` is discarded during rendering, so comments never appear in the output.

```pony
let t = Template.parse("Hello {{! a comment }} world")?
t.render(TemplateValues)? // => "Hello  world"
```

Trim markers work with comments the same way they work with any other block type:

```pony
Template.parse("Hello{{-! trimmed -}}world")?
  .render(TemplateValues)? // => "Helloworld"
```

Comments can appear anywhere a normal block can: inside `if`/`else` bodies, loop bodies, and before `extends` declarations. They are transparent to the template engine — a comment before `{{ extends "base" }}` does not prevent the extends from being recognized as the first statement.

## Add raw / literal blocks

Raw blocks let you output literal `{{ }}` delimiters without the engine interpreting them. Wrap content in `{{raw}}...{{end}}` and everything between the tags is emitted as-is:

```pony
let t = Template.parse("{{raw}}{{ name }}{{end}}")?
t.render(TemplateValues)?  // => "{{ name }}"
```

Trim markers work on both tags (`{{- raw -}}...{{- end -}}`), following the same rules as other block types.

The first `{{ end }}` always closes the raw block, so literal `{{ end }}` cannot appear inside raw content. This is the same class of limitation as `}}` inside comments.

## Add HTML-aware template engine with contextual auto-escaping

`HtmlTemplate` works like `Template` but automatically escapes variable output based on HTML context. A variable inside a `<p>` tag gets HTML entity escaping; inside an `href` attribute it gets URL scheme filtering and percent-encoding; inside an `onclick` attribute it gets JavaScript string escaping; and so on.

```pony
let t = HtmlTemplate.parse(
  "<h1>{{ title }}</h1>\n<p>{{ message }}</p>")?

let v = TemplateValues
v("title") = "Hello & welcome"
v("message") = "<script>alert('xss')</script>"

t.render(v)?
// <h1>Hello &amp; welcome</h1>
// <p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>
```

Parse-time validation rejects templates with variables in structurally invalid positions — inside tag names, unquoted attribute values, etc. — and verifies that `if`/`else` branches and loops preserve HTML context consistency.

To bypass escaping for trusted content, use `TemplateValue.unescaped` or `TemplateValues.unescaped`:

```pony
let v = TemplateValues
v.unescaped("bio", "<em>Trusted</em> HTML")
```

`HtmlTemplate` shares the same template syntax, `TemplateContext`, and `TemplateValues` as `Template`. The `RenderableValue` interface and `HtmlContext` type are public for custom escaping strategies.

