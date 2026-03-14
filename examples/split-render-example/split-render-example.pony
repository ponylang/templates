// in your code this `use` statement would be:
// use "templates"
use "../../templates"

class PrintingSink is TemplateSink
  """
  A sink that prints each segment with a label, demonstrating the alternating
  literal/dynamic_value call pattern.
  """
  let _env: Env

  new ref create(env: Env) =>
    _env = env

  fun ref literal(text: String) =>
    _env.out.print("  LITERAL: \"" + text + "\"")

  fun ref dynamic_value(value: String) =>
    _env.out.print("  DYNAMIC: \"" + value + "\"")


actor Main
  new create(env: Env) =>
    let template =
      try
        Template.parse("Hello {{ name }}, you have {{ count }} messages.")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    let values = TemplateValues
    values("name") = "Alice"
    values("count") = "3"

    // render_split() returns (statics, dynamics) as separate arrays.
    // statics always has exactly one more element than dynamics.
    try
      env.out.print("--- render_split ---")
      (let statics, let dynamics) = template.render_split(values)?
      env.out.print("Statics (" + statics.size().string() + "):")
      for (i, s) in statics.pairs() do
        env.out.print("  [" + i.string() + "] \"" + s + "\"")
      end
      env.out.print("Dynamics (" + dynamics.size().string() + "):")
      for (i, d) in dynamics.pairs() do
        env.out.print("  [" + i.string() + "] \"" + d + "\"")
      end

      // Recombine to verify: interleave statics and dynamics
      let recombined = recover val
        let buf = String
        for (j, stat) in statics.pairs() do
          buf.append(stat)
          try buf.append(dynamics(j)?) end
        end
        buf
      end
      env.out.print("Recombined: \"" + recombined + "\"")
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

    // render_to() drives a custom sink with alternating calls.
    try
      env.out.print("")
      env.out.print("--- render_to with PrintingSink ---")
      let sink: PrintingSink ref = PrintingSink(env)
      template.render_to(sink, values)?
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

    // HtmlTemplate.render_split() provides already-escaped dynamics.
    try
      let html_template = HtmlTemplate.parse(
        "<p>{{ message }}</p>")?

      let html_values = TemplateValues
      html_values("message") = "<script>alert('xss')</script>"

      env.out.print("")
      env.out.print("--- HtmlTemplate render_split (escaped dynamics) ---")
      (let statics, let dynamics) = html_template.render_split(html_values)?
      for (i, s) in statics.pairs() do
        env.out.print("  static[" + i.string() + "]: \"" + s + "\"")
      end
      for (i, d) in dynamics.pairs() do
        env.out.print("  dynamic[" + i.string() + "]: \"" + d + "\"")
      end
    else
      env.err.print("Could not render HTML template :(")
      env.exitcode(1)
    end
