// This example demonstrates template comments using {{! ... }} syntax.
// Comments are stripped from the output entirely — useful for documenting
// template logic without polluting rendered text.

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

use "collections"

actor Main
  new create(env: Env) =>
    let values = TemplateValues
    values("name") = "world"
    values("items") = TemplateValue(
      recover val
        let s = Array[TemplateValue]
        s.push(TemplateValue("alpha"))
        s.push(TemplateValue("beta"))
        s
      end)

    // Basic comment — the {{! ... }} block is invisible in the output
    let basic =
      try
        Template.parse(
          "Hello {{! greeting target }} {{ name }}!")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    try
      env.out.print(basic.render(values)?)
    else
      env.err.print("Could not render template :(")
      env.exitcode(1)
      return
    end

    // Comments with trim markers remove surrounding whitespace, just like
    // any other block type. Useful inside loops to avoid extra blank lines.
    let trimmed =
      try
        Template.parse(
          "items:\n" +
          "{{ for item in items -}}\n" +
          "{{-! Document each list entry -}}\n" +
          "- {{ item }}\n" +
          "{{ end }}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    try
      env.out.print(trimmed.render(values)?)
    end
