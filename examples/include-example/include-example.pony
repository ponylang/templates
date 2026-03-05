// This example demonstrates how to use partials (includes) to reuse template
// fragments across templates

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

use "collections"

actor Main
  new create(env: Env) =>
    // Partials are raw template strings registered in a TemplateContext.
    // They can contain any template syntax — variables, loops, conditionals.
    let ctx = TemplateContext(where partials' =
      recover val
        let p = Map[String, String]
        p("header") = "=== {{ title }} ==="
        p("user-line") = "- {{ user }} ({{ user.role }})"
        p
      end
    )

    // Use {{ include "name" }} to inline a partial. The partial shares the
    // same variable scope as the surrounding template.
    let template =
      try
        Template.parse(
          "{{ include \"header\" }}\n" +
          "{{ for user in users }}{{ include \"user-line\" }}\n{{ end }}",
          ctx)?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    let values = TemplateValues
    values("title") = "Team Members"

    let alice_props = Map[String, TemplateValue]
    alice_props("role") = TemplateValue("admin")
    let bob_props = Map[String, TemplateValue]
    bob_props("role") = TemplateValue("member")

    values("users") = TemplateValue(
      [TemplateValue("Alice", alice_props)
       TemplateValue("Bob", bob_props)])

    try
      env.out.print(template.render(values)?)
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end
