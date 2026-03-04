// This example demonstrates if/else, if/elseif/else, and ifnot conditional
// blocks

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

actor Main
  new create(env: Env) =>
    // Simple if/else: show different text based on whether a value exists
    let greeting =
      try
        Template.parse(
          "{{ if name }}Hello {{ name }}!{{ else }}Hello stranger!{{ end }}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    // With a name → "Hello Alice!"
    let with_name = TemplateValues
    with_name("name") = "Alice"
    try env.out.print(greeting.render(with_name)?) end

    // Without a name → "Hello stranger!"
    try env.out.print(greeting.render(TemplateValues)?) end

    // Chained elseif: pick the first matching branch
    let role_msg =
      try
        Template.parse(
          "{{ if admin }}admin panel" +
          "{{ elseif member }}member area" +
          "{{ else }}public page{{ end }}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    let admin_values = TemplateValues
    admin_values("admin") = "yes"
    try env.out.print(role_msg.render(admin_values)?) end  // "admin panel"

    let member_values = TemplateValues
    member_values("member") = "yes"
    try env.out.print(role_msg.render(member_values)?) end  // "member area"

    // No flags set → "public page"
    try env.out.print(role_msg.render(TemplateValues)?) end

    // Negated conditional: render content when a variable is absent
    let anon =
      try
        Template.parse(
          "{{ ifnot name }}Anonymous{{ end }}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    // Without a name → "Anonymous"
    try env.out.print(anon.render(TemplateValues)?) end

    // With a name → "" (empty, body not rendered)
    try env.out.print(anon.render(with_name)?) end

    // ifnot with else: different content based on absence vs presence
    let display_name =
      try
        Template.parse(
          "{{ ifnot name }}Anonymous{{ else }}{{ name }}{{ end }}")?
      else
        env.err.print("Could not parse template :(")
        env.exitcode(1)
        return
      end

    // Without a name → "Anonymous"
    try env.out.print(display_name.render(TemplateValues)?) end

    // With a name → "Alice"
    try env.out.print(display_name.render(with_name)?) end
