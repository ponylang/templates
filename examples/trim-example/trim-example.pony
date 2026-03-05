// This example demonstrates whitespace trimming with {{- and -}} markers.
// Trim markers strip adjacent whitespace from literals, which is useful for
// generating indentation-sensitive output without blank lines from control
// flow tags.

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

use "collections"

actor Main
  new create(env: Env) =>
    // Without trimming, a loop injects extra whitespace from the for/end
    // lines. With selective trim markers, we get clean output.
    let values = TemplateValues
    values("services") = TemplateValue(
      recover val
        let s = Array[TemplateValue]
        s.push(TemplateValue("web"))
        s.push(TemplateValue("db"))
        s.push(TemplateValue("cache"))
        s
      end)

    // Right-trim on the for tag strips the newline before loop body content.
    // The end tag has no trim markers, so each iteration's trailing newline
    // is preserved.
    let template =
      try
        Template.parse(
          "services:\n" +
          "{{ for svc in services -}}" +
          "\n- {{ svc }}\n" +
          "{{ end }}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    try
      env.out.print(template.render(values)?)
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

    // Both-side trim to collapse whitespace completely
    let inline_template =
      try
        Template.parse(
          "items: {{- for svc in services -}} [{{ svc }}] {{- end }}",
          TemplateContext)?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    try
      env.out.print(inline_template.render(values)?)
    end
