## Add HTML-aware template engine with contextual auto-escaping

`HtmlTemplate` works like `Template` but automatically escapes variable output based on HTML context. A variable inside a `<p>` tag gets HTML entity escaping; inside an `href` attribute it gets URL scheme filtering and percent-encoding; inside an `onclick` attribute it gets JavaScript string escaping; and so on.

```pony
let t = HtmlTemplate.parse(
  "<h1>{{ title }}</h1>\n<p>{{ message }}</p>")?

let v = TemplateValues
v("title") = "Hello & welcome"
v("message") = "<script>alert('xss')</script>"

t.render(v)?
// <h1>Hello &amp; welcome</h1>
// <p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>
```

Parse-time validation rejects templates with variables in structurally invalid positions — inside tag names, unquoted attribute values, etc. — and verifies that `if`/`else` branches and loops preserve HTML context consistency.

To bypass escaping for trusted content, use `TemplateValue.unescaped` or `TemplateValues.unescaped`:

```pony
let v = TemplateValues
v.unescaped("bio", "<em>Trusted</em> HTML")
```

`HtmlTemplate` shares the same template syntax, `TemplateContext`, and `TemplateValues` as `Template`. The `RenderableValue` interface and `HtmlContext` type are public for custom escaping strategies.
