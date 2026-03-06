## Add template comments

Templates now support comments with `{{! ... }}` syntax. Everything between `!` and `}}` is discarded during rendering, so comments never appear in the output.

```pony
let t = Template.parse("Hello {{! a comment }} world")?
t.render(TemplateValues)? // => "Hello  world"
```

Trim markers work with comments the same way they work with any other block type:

```pony
Template.parse("Hello{{-! trimmed -}}world")?
  .render(TemplateValues)? // => "Helloworld"
```

Comments can appear anywhere a normal block can: inside `if`/`else` bodies, loop bodies, and before `extends` declarations. They are transparent to the template engine — a comment before `{{ extends "base" }}` does not prevent the extends from being recognized as the first statement.
