## Add default values for missing variables

Missing variables in templates render as empty strings, with no way to provide a fallback. `| default("...")` lets template authors declare what to show when a variable is absent.

```pony
let t = Template.parse(
  "Hello {{ name | default(\"stranger\") }}")?

// name is missing — renders "Hello stranger"
t.render(TemplateValues)?

// name is present — renders "Hello Alice"
let v = TemplateValues
v("name") = "Alice"
t.render(v)?
```

Defaults work with dotted properties and function call arguments:

```pony
// Dotted property with default
Template.parse("{{ user.name | default(\"anon\") }}")?

// Function argument with default
Template.parse("{{ upper(name | default(\"anon\")) }}", ctx)?
```

Defaults are not allowed in control flow conditions (`if`, `ifnot`, `elseif`, `for ... in`) — a default would make the condition always truthy, defeating its purpose.
