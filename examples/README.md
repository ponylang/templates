# Examples

Each subdirectory is a self-contained Pony program demonstrating a different part of the templates library. Ordered from simplest to most involved.

## [simple-example](simple-example/)

Parses a template with a single placeholder, binds a value, and renders the result. Demonstrates the core workflow: `Template.parse()`, `TemplateValues`, and `Template.render()`. Start here if you're new to the library.

## [conditionals-example](conditionals-example/)

Shows how to use `if`/`else`, `if`/`elseif`/`else`, and `ifnot` blocks to conditionally include content based on whether values are present or absent. Demonstrates simple two-branch conditionals, chained multi-branch selection, and negated conditionals for the absent-variable case.

## [functions-example](functions-example/)

Registers a custom function via `TemplateContext` and calls it from within a template inside a `for` loop. Demonstrates how to extend templates with user-defined transformations.
