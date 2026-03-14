## Add sink/visitor interface for split rendering

Both `Template` and `HtmlTemplate` now support two new rendering methods in addition to `render()`:

`render_split(values)` returns `(Array[String] val, Array[String] val)` — the static literal segments and dynamic value segments as separate arrays. For N dynamic insertions, the statics array has N+1 entries. This enables use cases like tagged template literals or any context where static template structure and dynamic values need to be handled differently.

`render_to(sink, values)` drives a caller-supplied `TemplateSink` with alternating `literal` and `dynamic_value` calls. The interleaving is strict: calls always start and end with `literal`, and for N dynamics there are exactly N+1 literal calls (empty strings are inserted where needed). Control flow subtrees (`if`, `ifnot`, `for`) collapse into a single `dynamic_value` call; `block` is transparent.

For `HtmlTemplate`, dynamic values passed to the sink are already escaped based on HTML context — the sink receives final, safe strings.

```pony
// render_split: separate statics from dynamics
let t = Template.parse("Hello {{ name }}, you have {{ count }} messages.")?
let v = TemplateValues
v("name") = "Alice"
v("count") = "3"
(let statics, let dynamics) = t.render_split(v)?
// statics: ["Hello ", ", you have ", " messages."]
// dynamics: ["Alice", "3"]

// render_to: drive a custom sink
class MySink is TemplateSink
  fun ref literal(text: String) => // handle static text
  fun ref dynamic_value(value: String) => // handle dynamic value

let sink: MySink ref = MySink
t.render_to(sink, v)?
```

