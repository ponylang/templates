## Add trim syntax for whitespace control

Templates now support `{{-` and `-}}` trim markers that strip whitespace from adjacent literals. `{{-` removes trailing whitespace (spaces, tabs, newlines) from the text before the tag, `-}}` removes leading whitespace from the text after it. Use both together with `{{- ... -}}` to strip in both directions.

This matters most when generating indentation-sensitive output like YAML or Python. Without trimming, control flow tags (`if`, `for`, `end`) inject blank lines and leading whitespace into the output because the newlines around the tags themselves become part of the rendered text. Trim markers let you eliminate that whitespace without cramming everything onto one line.

```pony
let values = TemplateValues
values("name") = "app"
values("services") = TemplateValue(
  recover val
    let s = Array[TemplateValue]
    s.push(TemplateValue("web"))
    s.push(TemplateValue("db"))
    s
  end)

let t = Template.parse(
  "name: {{ name }}\n" +
  "services:\n" +
  "{{ for svc in services -}}" +
  "\n- {{ svc }}\n" +
  "{{ end }}")?

t.render(values)?
// name: app
// services:
// - web
// - db
```

The right-trim on the `for` tag strips the newline that would otherwise appear before the first list item. Either marker can be used independently — you pick which side to trim based on where the unwanted whitespace is.
