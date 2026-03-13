## Add public `scope()` method to TemplateValues

`TemplateValues` now has a `scope()` method that creates an empty writable child scope backed by the receiver as a read-only parent. Writes go to the child; lookups that miss in the child fall through to the parent.

```pony
let parent = TemplateValues
parent("name") = "Alice"

let child = parent.scope()
child("extra") = "new value"

// child sees both its own values and the parent's
child("extra")?.string()?  // => "new value"
child("name")?.string()?   // => "Alice"
```

This is useful when you need a writable `TemplateValues` that inherits existing assigns without copying data or modifying the original. For example, composing component HTML into a template when the backing values are seen as `box` through viewpoint adaptation.
