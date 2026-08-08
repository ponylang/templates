// in your code this `use` statement would be:
// use "templates"
use "../../templates"

actor Main
  new create(env: Env) =>
    // First, create a template. Here, we use a string as template source, but
    // you could also load a template from a file (with `Template.from_file`)
    let template =
      try
        Template.parse("Hello {{ name }}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    // TemplateValues is a namespace. Use its apply function to bind values
    // to placeholder names
    let values = TemplateValues
    // In our case, we want to provide a value for "name"
    values("name") = "Pony enthusiast"

    // And finally, render the template (replace placeholders with values)
    try
      env.out.print(template.render(values)?)
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

    // A template can be rendered more than once, with different values
    let new_values = TemplateValues
    new_values("name") = "world"
    try
      env.out.print(template.render(new_values)?)
    end
