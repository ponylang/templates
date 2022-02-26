# Templates

A template engine for [Pony](https://www.ponylang.io/)

## Status

Templates is an alpha-level package.

As templates gets used in more projects, we expect to find and fix bugs. We also expect that we will make breaking changes.

## Installation

* Install [corral](https://github.com/ponylang/corral)
* `corral add github.com/ponylang/templates.git --version 0.2.3`
* `corral fetch` to fetch your dependencies
* `use "templates"` to include this package
* `corral run -- ponyc` to compile your application

## API Documentation

[https://ponylang.github.io/templates](https://ponylang.github.io/templates)

## How to use pony-templates

* Add a line `use "templates"` to your source file
* Load a template with `Template.parse("Hello {{ name }}")?`. Note that this
  method is partial. In other words, it can fail.
* Create a `TemplateValues` object and fill it with the values you want to see
  in the rendered template:

  ```pony
    let values = TemplateValues
    values("name") = "world"
  ```

* Finally, render the template with `template.render(values)?` (assuming
  `template` references your template). Note that this method is partial as
  well.

## Supported Features

* Variables: `{{ some_var }}` will be replaced with the variable
  `some_var`'s value. A value can either be a `String` or a
  `TemplateValue`. A `TemplateValue` is either a `String` or a
  `Seq[TemplateValue]]`.
* Properties: `{{ some_var.prop }}` will be replaced with value `some_var`'s
  property `prop`. Properties are part of `TemplateValue`: its constructor
  takes a `Map[String, TemplateValue]` that defines the value's properties.
* For loops: `{{ for x in xs }}{{ x }} {{ end }}` will iterate through the
  sequence `xs` and adds each element plus a space to the output.
* Conditional output: `{{ if spam }}Eggs{{ end }}` only adds `Eggs` to the
  output if the variable `spam` exists. Can also check for the presence of a
  property.

  `{{ ifnotempty seq }}` ignores everything until the next `{{ end }}` if
  sequence ``seq`` is empty.
* Calls: `{{ escape(var) }}` calls `escape` with argument `var` and adds
  the function result to the output. All known functions must be passed as part
  of a `TemplateContext` value to the template's constructor.
