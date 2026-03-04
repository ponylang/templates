## Add template inheritance

Templates can now extend a base layout and override named blocks. A base template defines `{{ block name }}...{{ end }}` sections with default content. A child template declares `{{ extends "base" }}` as its first statement and overrides specific blocks — blocks not overridden render their defaults from the base.

```pony
let ctx = TemplateContext(
  recover Map[String, {(String): String}] end,
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
