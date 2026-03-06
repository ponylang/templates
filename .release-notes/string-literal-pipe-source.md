## Add string literals as pipe source

String literals can now be used as the starting value in a pipe chain, without needing a template variable:

```pony
let t = Template.parse("{{ \"hello world\" | upper }}")?
t.render(TemplateValues)?  // => "HELLO WORLD"
```

This works with any filter chain: `{{ "  hello  " | trim | upper }}` produces `HELLO`. The string literal follows the same quoting rules as filter arguments — printable ASCII characters excluding double quotes.
