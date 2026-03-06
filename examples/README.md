# Examples

Each subdirectory is a self-contained Pony program demonstrating a different part of the templates library. Ordered from simplest to most involved.

## [simple-example](simple-example/)

Parses a template with a single placeholder, binds a value, and renders the result. Demonstrates the core workflow: `Template.parse()`, `TemplateValues`, and `Template.render()`. Start here if you're new to the library.

## [raw-example](raw-example/)

Uses `{{raw}}...{{end}}` syntax to emit literal text without interpreting `{{ }}` sequences inside it. Useful when the template output itself contains delimiter syntax — for example, generating Mustache templates or documentation about this library. Shows basic raw output and raw blocks combined with trim markers.

## [comments-example](comments-example/)

Uses `{{! ... }}` syntax to add comments to templates. Comments are stripped from the output entirely, so they're useful for documenting template logic without affecting rendered text. Shows basic comments and comments combined with trim markers inside loops.

## [filters-example](filters-example/)

Uses the filter/pipe system to transform values. Demonstrates built-in filters (`upper`, `trim`, `capitalize`, `title`, `default`), chaining multiple filters (`{{ greeting | trim | capitalize }}`), string literals as pipe sources (`{{ "hello world" | upper }}`), custom filter registration via `TemplateContext`, and filters inside loops.

## [conditionals-example](conditionals-example/)

Shows how to use `if`/`else`, `if`/`elseif`/`else`, and `ifnot` blocks to conditionally include content based on whether values are present or absent. Demonstrates simple two-branch conditionals, chained multi-branch selection, negated conditionals, and sequence truthiness (guarding a loop with `if` so it only renders when items are present).

## [include-example](include-example/)

Registers named partials via `TemplateContext` and inlines them with `{{ include "name" }}`. Demonstrates reusing template fragments across templates, with partials sharing the same variable scope.

## [inheritance-example](inheritance-example/)

Defines a base HTML layout with `{{ block head }}` and `{{ block content }}` sections, then creates a child template that extends the base and overrides both blocks. Demonstrates template inheritance via `{{ extends "base" }}` and `{{ block name }}...{{ end }}`.

## [trim-example](trim-example/)

Uses `{{-` and `-}}` trim markers to strip whitespace around tags. Shows how selective trimming produces clean, indentation-sensitive output (like YAML service lists) without unwanted blank lines from control flow tags.
