## Add else and elseif branches to if blocks

`if` blocks now support `else` and `elseif` branches, so you no longer need to duplicate content with negated conditions.

```pony
let t = Template.parse(
  "{{ if admin }}admin panel" +
  "{{ elseif member }}member area" +
  "{{ else }}public page{{ end }}")?
```

`elseif` chains can be as long as needed. A final `else` branch is optional and renders when no condition matches.

`if` checks both existence and non-emptiness: a variable bound to an empty sequence is falsy, so `{{ if items }}` naturally guards a loop without a separate check.

## Add `ifnot` negated conditional blocks

`ifnot` renders its body when a variable is absent or is an empty sequence — the logical inverse of `if`. This lets you write the "missing" case as the primary branch instead of requiring an `if`/`else` just to get at the `else`.

```pony
let t = Template.parse(
  "{{ ifnot name }}Anonymous{{ end }}")?
```

Like `if`, `ifnot` supports `else` and `elseif` branches:

```pony
let t = Template.parse(
  "{{ ifnot name }}Anonymous{{ else }}{{ name }}{{ end }}")?
```
## Unify `if` and `ifnotempty` conditionals

`ifnotempty` has been removed. `if` now checks both existence and sequence non-emptiness, making `ifnotempty` redundant.

Before:

```pony
let t = Template.parse(
  "{{ ifnotempty items }}{{ for i in items }}{{ i }}{{ end }}{{ end }}")?
```

After:

```pony
let t = Template.parse(
  "{{ if items }}{{ for i in items }}{{ i }}{{ end }}{{ end }}")?
```

Unlike `ifnotempty`, `if` supports `else` and `elseif` branches:

```pony
let t = Template.parse(
  "{{ if items }}{{ for i in items }}{{ i }}{{ end }}" +
  "{{ else }}no items{{ end }}")?
```

