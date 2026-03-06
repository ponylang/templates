## Add raw / literal blocks

Raw blocks let you output literal `{{ }}` delimiters without the engine interpreting them. Wrap content in `{{raw}}...{{end}}` and everything between the tags is emitted as-is:

```pony
let t = Template.parse("{{raw}}{{ name }}{{end}}")?
t.render(TemplateValues)?  // => "{{ name }}"
```

Trim markers work on both tags (`{{- raw -}}...{{- end -}}`), following the same rules as other block types.

The first `{{ end }}` always closes the raw block, so literal `{{ end }}` cannot appear inside raw content. This is the same class of limitation as `}}` inside comments.
