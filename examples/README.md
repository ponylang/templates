# Examples

Each subdirectory is a self-contained Pony program demonstrating a different part of the templates library. Ordered from simplest to most involved.

## [simple-example](simple-example/)

Parses a template with a single placeholder, binds a value, and renders the result. Demonstrates the core workflow: `Template.parse()`, `TemplateValues`, and `Template.render()`. Start here if you're new to the library.

## [default-values-example](default-values-example/)

Uses `| default("...")` to provide fallback text when variables are missing. Shows the three cases: all values provided (defaults ignored), no values (defaults used), and partial values (mix of actual and default).

## [conditionals-example](conditionals-example/)

Shows how to use `if`/`else`, `if`/`elseif`/`else`, and `ifnot` blocks to conditionally include content based on whether values are present or absent. Demonstrates simple two-branch conditionals, chained multi-branch selection, negated conditionals, and sequence truthiness (guarding a loop with `if` so it only renders when items are present).

## [functions-example](functions-example/)

Registers a custom function via `TemplateContext` and calls it from within a template inside a `for` loop. Demonstrates how to extend templates with user-defined transformations.

## [include-example](include-example/)

Registers named partials via `TemplateContext` and inlines them with `{{ include "name" }}`. Demonstrates reusing template fragments across templates, with partials sharing the same variable scope.

## [inheritance-example](inheritance-example/)

Defines a base HTML layout with `{{ block head }}` and `{{ block content }}` sections, then creates a child template that extends the base and overrides both blocks. Demonstrates template inheritance via `{{ extends "base" }}` and `{{ block name }}...{{ end }}`.
