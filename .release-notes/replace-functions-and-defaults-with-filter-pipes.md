## Replace function calls and default values with unified filter pipes

Function calls (`{{ fn(arg) }}`) and the `| default("...")` syntax have been replaced by a unified filter/pipe system. Values are now transformed by piping them through one or more filters: `{{ value | filter1 | filter2 }}`.

Six built-in filters are available in all templates without registration:

- `upper` — uppercase
- `lower` — lowercase
- `trim` — strip leading/trailing whitespace
- `capitalize` — first character upper, rest lower
- `default("fallback")` — use fallback when the value is empty or missing
- `replace("old", "new")` — replace all occurrences

Before (function call):

```pony
let ctx = TemplateContext(
  recover
    let functions = Map[String, {(String): String}]
    functions("upper") = {(s) =>
      let out = s.clone()
      out.upper_in_place()
      consume out
    }
    functions
  end
)

let t = Template.parse("{{ upper(name) }}", ctx)?
```

After (pipe filter):

```pony
// upper is built-in — no registration needed
let t = Template.parse("{{ name | upper }}")?
```

Before (default inside function call):

```pony
Template.parse("{{ upper(name | default(\"anon\")) }}", ctx)?
```

After (chained filters):

```pony
Template.parse("{{ name | default(\"anon\") | upper }}")?
```

The `TemplateContext` constructor's `functions` parameter has been replaced by `filters`. Custom filters implement `Filter` (0 extra args), `Filter2` (1 extra arg), or `Filter3` (2 extra args):

Before:

```pony
let ctx = TemplateContext(
  recover
    let functions = Map[String, {(String): String}]
    functions("yell") = {(s) => s.upper()}
    functions
  end,
  partials
)
```

After:

```pony
let ctx = TemplateContext(
  recover val
    let filters = Map[String, AnyFilter]
    filters("yell") = Upper  // reuse built-in, or provide a custom primitive
    filters
  end,
  partials
)
```

Filter arguments can be string literals (`"hello"`) or template variables (`varname`). Filters are validated at parse time — unknown filter names and arity mismatches produce parse errors rather than runtime failures.

Semantic change: the `default` filter triggers on empty strings, not just missing variables. A variable bound to `""` now renders the fallback value.
