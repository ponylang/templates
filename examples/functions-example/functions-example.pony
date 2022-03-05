// This example demonstrates how you can use custom functions in your templates

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

use "collections"

actor Main
  new create(env: Env) =>
    // Functions can be passed via a TemplateContext
    let ctx = TemplateContext(
      recover
        let functions = Map[String, {(String): String}]
        functions("yell") = { (x) => x.upper() }
        functions
      end
    )

    let template =
      try
        // The context needs to be passed to parse (or from_file)
        Template.parse(
          "{{ for name in names }}Hello {{ yell(name) }}\n{{ end }}", 
          ctx)?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    let values = TemplateValues
    values("names") = TemplateValue([
        TemplateValue("Pony enthusiast")
        TemplateValue("Pony developer")
    ])

    try
      env.out.print(template.render(values)?)
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

