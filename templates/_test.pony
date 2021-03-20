use "collections"
use "ponytest"


actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TemplateTest)
    test(_LoopTest)
    test(_IfTest)
    test(_IfNotEmptyTest)
    test(_CallTest)
    test(_StmtParserTest)


// XXX test TemplateValues


class iso _TemplateTest is UnitTest
  fun name(): String => "Template basic functionality"

  fun apply(h: TestHelper)? =>
    let empty = Template.parse("")?
    h.assert_eq[String]("", empty.render(TemplateValues)?)

    let no_var = Template.parse("Template without variable")?
    h.assert_eq[String]("Template without variable", no_var.render(TemplateValues)?)

    let with_var = Template.parse("Hello {{ name }} from {{ sender }}")?

    let values = TemplateValues
    values("name") = "world"
    // A missing value for a var should just leave out the placeholder
    h.assert_eq[String]("Hello world from ", with_var.render(values)?)

    values("sender") = "pony"
    h.assert_eq[String]("Hello world from pony", with_var.render(values)?)

    let props = Map[String, TemplateValue]
    props("inner") = TemplateValue("inner value")
    values("nested") = TemplateValue("outer", props)
    let nested_template = Template.parse("{{ nested.inner }}")?
    h.assert_eq[String]("inner value", nested_template.render(values)?)


class iso _LoopTest is UnitTest
  fun name(): String => "Template loops"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    let props = Map[String, TemplateValue]
    props("inner") = TemplateValue([TemplateValue("rab"); TemplateValue("oof")])
    values("xs") = TemplateValue([TemplateValue("foo"); TemplateValue("bar")], props)

    let var_not_used = Template.parse("{{ for x in xs }}{{ end }}")?
    h.assert_eq[String]("", var_not_used.render(values)?)

    let template = Template.parse("{{ for x in xs}}{{ x }} {{ end }}")?
    h.assert_eq[String]("foo bar ", template.render(values)?)

    let nested_template = Template.parse("{{ for x in xs.inner }}{{ x }}{{ end }}")?
    h.assert_eq[String]("raboof", nested_template.render(values)?)

    // XXX check end without loop


class iso _IfTest is UnitTest
  fun name(): String => "Template if"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    let template = Template.parse("{{ if spam }}Eggs{{ end }}")?
    h.assert_eq[String]("", template.render(values)?)

    values("spam") = "value"
    h.assert_eq[String]("Eggs", template.render(values)?)


class iso _IfNotEmptyTest is UnitTest
  fun name(): String => "Template ifnotempty"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("seqempty") = TemplateValue([])
    values("seq") = TemplateValue([TemplateValue("spam")])
    let not_template = Template.parse(
      """
      {{ ifnotempty seqempty }}Should not be rendered{{ end }}
      {{ ifnotempty seq}}Values: {{ for x in seq }}{{x}}{{ end}}{{ end }}
      """)?
    h.assert_eq[String]("\nValues: spam\n", not_template.render(values)?)

    // XXX check end without ifnotempty


class iso _CallTest is UnitTest
  fun name(): String => "Template calls"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "foo"
    let ctx = TemplateContext(
      recover
        let functions = Map[String, {(String): String}]
        functions("double") = {(x) => x + x}
        functions
      end
    )
    let template = Template.parse("{{ double(x) }}", ctx)?
    h.assert_eq[String]("foofoo", template.render(values)?)


class iso _StmtParserTest is UnitTest
  fun name(): String => "Template statement parser"

  fun apply(h: TestHelper) =>
    h.assert_no_error({()? => _StmtParser.parse("end")? as _EndNode })
    h.assert_no_error({()? => _StmtParser.parse("foo(spam.eggs)")? as _CallNode })
    h.assert_no_error({()? => _StmtParser.parse("ifnotempty spam")? as _IfNotEmptyNode })
