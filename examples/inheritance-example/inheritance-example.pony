// This example demonstrates template inheritance: a child template extends a
// base layout and overrides specific named blocks.

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

use "collections"

actor Main
  new create(env: Env) =>
    // The base layout is registered as a partial. It defines blocks with
    // default content that child templates can override.
    let ctx = TemplateContext(where partials' =
      recover val
        let p = Map[String, String]
        p("base") =
          "<html>\n" +
          "<head>{{ block head }}<title>Default Title</title>{{ end }}</head>\n" +
          "<body>\n" +
          "{{ block content }}(no content){{ end }}\n" +
          "</body>\n" +
          "</html>"
        p
      end
    )

    // The child template declares {{ extends "base" }} as its first statement,
    // then overrides specific blocks. The "head" block is overridden with a
    // dynamic title; the "content" block is filled in. Content outside block
    // definitions in the child is silently ignored.
    let template =
      try
        Template.parse(
          "{{ extends \"base\" }}" +
          "{{ block head }}<title>{{ title }}</title>{{ end }}" +
          "{{ block content }}" +
          "<h1>{{ title }}</h1>\n" +
          "<p>Welcome, {{ user }}!</p>" +
          "{{ end }}",
          ctx)?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    let values = TemplateValues
    values("title") = "My Page"
    values("user") = "Alice"

    try
      env.out.print(template.render(values)?)
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end
