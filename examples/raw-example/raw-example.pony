// This example demonstrates raw blocks using {{raw}}...{{end}} syntax.
// Everything between the tags is emitted as literal text — no {{ }}
// interpretation occurs. Useful when template output itself contains
// delimiter syntax.

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

actor Main
  new create(env: Env) =>
    // Basic raw output — {{ name }} passes through literally
    let basic =
      try
        Template.parse(
          "Template syntax: {{raw}}{{ name }}{{end}}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    try
      env.out.print(basic.render(TemplateValues)?)
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

    // Raw block with trim markers — strips surrounding whitespace while
    // still emitting the raw content literally
    let trimmed =
      try
        Template.parse(
          "before\n{{- raw -}}\n{{ delimiters }}\n{{- end -}}\nafter")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    try
      env.out.print(trimmed.render(TemplateValues)?)
    end
