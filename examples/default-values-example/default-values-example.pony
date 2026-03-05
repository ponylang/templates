// in your code this `use` statement would be:
// use "templates"
use "../../templates"

actor Main
  new create(env: Env) =>
    let template =
      try
        Template.parse(
          "Hello {{ name | default(\"stranger\") }}, " +
          "welcome to {{ place | default(\"the world\") }}!")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    // With values provided — defaults are not used
    let values = TemplateValues
    values("name") = "Alice"
    values("place") = "Ponyville"
    try
      env.out.print(template.render(values)?)
      // Output: Hello Alice, welcome to Ponyville!
    end

    // With no values — defaults are used
    try
      env.out.print(template.render(TemplateValues)?)
      // Output: Hello stranger, welcome to the world!
    end

    // With only some values — mix of actual and default
    let partial = TemplateValues
    partial("name") = "Bob"
    try
      env.out.print(template.render(partial)?)
      // Output: Hello Bob, welcome to the world!
    end
