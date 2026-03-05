// This example demonstrates the filter/pipe system in templates.
// Filters transform values using the pipe syntax: {{ value | filter }}

// In your code this `use` statement would be:
// use "templates"
use "../../templates"

use "collections"

// A custom filter that repeats the input n times (where n is the extra arg).
primitive Repeat is Filter2
  fun apply(input: String, arg1: String): String =>
    let count: USize = try arg1.usize()? else 1 end
    let out = recover iso String(input.size() * count) end
    var i: USize = 0
    while i < count do
      out.append(input)
      i = i + 1
    end
    consume out

actor Main
  new create(env: Env) =>
    // Register a custom filter via TemplateContext.
    // Built-in filters (upper, lower, trim, capitalize, title, default,
    // replace) are always available without registration.
    let ctx = TemplateContext(
      recover val
        let filters = Map[String, AnyFilter]
        filters("repeat") = Repeat
        filters
      end
    )

    // Basic pipe: apply a single filter
    try
      let t1 = Template.parse("Hello {{ name | upper }}!", ctx)?
      let v1 = TemplateValues
      v1("name") = "world"
      env.out.print(t1.render(v1)?)
      // Output: Hello WORLD!
    end

    // Chaining: multiple filters applied left-to-right
    try
      let t2 = Template.parse(
        "Greeting: {{ greeting | trim | capitalize }}", ctx)?
      let v2 = TemplateValues
      v2("greeting") = "  hello world  "
      env.out.print(t2.render(v2)?)
      // Output: Greeting: Hello world
    end

    // Title case: capitalize the first letter of each word
    try
      let t = Template.parse("{{ name | title }}", ctx)?
      let v = TemplateValues
      v("name") = "hello world"
      env.out.print(t.render(v)?)
      // Output: Hello World
    end

    // Default filter: fallback when a variable is missing
    try
      let t3 = Template.parse(
        "Hello {{ name | default(\"stranger\") }}!", ctx)?
      env.out.print(t3.render(TemplateValues)?)
      // Output: Hello stranger!
    end

    // Custom filter with an argument, inside a loop
    try
      let t4 = Template.parse(
        "{{ for name in names }}{{ name | repeat(\"3\") }} {{ end }}",
        ctx)?
      let v4 = TemplateValues
      v4("names") = TemplateValue([
        TemplateValue("ha")
        TemplateValue("ho")
      ])
      env.out.print(t4.render(v4)?)
      // Output: hahaha hohoho
    end

    // Combining default and upper (migration from old syntax)
    // Old: {{ upper(name | default("anon")) }}
    // New: {{ name | default("anon") | upper }}
    try
      let t5 = Template.parse(
        "{{ name | default(\"anon\") | upper }}", ctx)?
      env.out.print(t5.render(TemplateValues)?)
      // Output: ANON

      let v5 = TemplateValues
      v5("name") = "alice"
      env.out.print(t5.render(v5)?)
      // Output: ALICE
    end
