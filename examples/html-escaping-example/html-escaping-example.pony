// in your code this `use` statement would be:
// use "templates"
use "../../templates"

actor Main
  new create(env: Env) =>
    // HtmlTemplate works exactly like Template but automatically escapes
    // variable output based on HTML context.
    let template =
      try
        HtmlTemplate.parse(
          "<h1>{{ title }}</h1>\n"
          + "<p>{{ message }}</p>\n"
          + "<a href=\"{{ url }}\">{{ link_text }}</a>")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    // Values containing HTML special characters are escaped automatically.
    let values = TemplateValues
    values("title") = "Hello & welcome"
    values("message") = "<script>alert('xss')</script>"
    values("url") = "https://example.com/?q=a&b=c"
    values("link_text") = "Click <here>"

    try
      env.out.print("--- Escaped output ---")
      env.out.print(template.render(values)?)
      // Output:
      // <h1>Hello &amp; welcome</h1>
      // <p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>
      // <a href="https://example.com/?q=a&amp;b=c">Click &lt;here&gt;</a>
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

    // To insert trusted HTML without escaping, use TemplateValue.unescaped
    // or the TemplateValues.unescaped convenience method.
    let values2 = TemplateValues
    values2("title") = "Page Title"
    values2.unescaped("message", "<em>This is <b>safe</b> HTML</em>")
    values2("url") = "https://example.com"
    values2("link_text") = "Home"

    try
      env.out.print("")
      env.out.print("--- Unescaped output ---")
      env.out.print(template.render(values2)?)
      // Output:
      // <h1>Page Title</h1>
      // <p><em>This is <b>safe</b> HTML</em></p>
      // <a href="https://example.com">Home</a>
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end
