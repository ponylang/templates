## Add `ifnot` negated conditional blocks

`ifnot` renders its body when a variable is absent — the logical inverse of `if`. This lets you write the "missing" case as the primary branch instead of requiring an `if`/`else` just to get at the `else`.

```pony
let t = Template.parse(
  "{{ ifnot name }}Anonymous{{ end }}")?
```

Like `if`, `ifnot` supports `else` and `elseif` branches:

```pony
let t = Template.parse(
  "{{ ifnot name }}Anonymous{{ else }}{{ name }}{{ end }}")?
```
