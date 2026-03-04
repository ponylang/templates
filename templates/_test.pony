use "collections"
use "files"
use "pony_check"
use "pony_test"


actor \nodoc\ Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    // Existing tests
    test(_TemplateTest)
    test(_LoopTest)
    test(_IfTest)
    test(_IfNotEmptyTest)
    test(_CallTest)
    test(_StmtParserTest)

    // TemplateValues tests (Step 3)
    test(_TestTemplateValuesStore)
    test(_TestTemplateValuesParentChain)
    test(_TestTemplateValuesLookup)
    test(Property1UnitTest[String](_PropTemplateValuesRoundtrip))
    test(Property1UnitTest[(String, String, String)](
      _PropTemplateValuesOverrideShadows))

    // Parser tests (Step 4)
    test(Property1UnitTest[String](_PropValidPropParsesToPropNode))
    test(Property1UnitTest[String](_PropValidCallParsesToCallNode))
    test(Property1UnitTest[String](_PropValidLoopParsesToLoopNode))
    test(Property1UnitTest[String](_PropValidIfParsesToIfNode))
    test(Property1UnitTest[String](_PropValidIfNotEmptyParsesToIfNotEmptyNode))
    test(Property1UnitTest[box->String](_PropInvalidStmtErrors))
    test(_TestParserNodeFields)
    test(_TestParserKeywordAmbiguity)

    // Template parse error tests (Step 5)
    test(_TestParseErrorUnclosedBlock)
    test(_TestParseErrorEndWithoutBlock)
    test(_TestParseErrorUnknownFunction)
    test(_TestParseErrorMalformedStmt)
    test(_TestParseIncompleteDelimiters)

    // Template render tests (Step 6)
    test(Property1UnitTest[String](_PropLiteralIdentity))
    test(Property1UnitTest[String](_PropRenderDeterminism))
    test(Property1UnitTest[(String, String)](_PropVariableSubstitution))
    test(Property1UnitTest[String](_PropMissingVariableRendersEmpty))
    test(_TestRenderNestedLoop)
    test(_TestRenderLoopWithIf)
    test(_TestRenderIfNotEmptyWithLoop)
    test(_TestRenderAdjacentPlaceholders)
    test(_TestRenderLoopVariableShadowing)

    // Function call tests (Step 7)
    test(_TestCallWithNestedProp)
    test(_TestCallArgMissing)
    test(_TestCallMultipleFunctions)

    // from_file test (Step 8)
    test(_TestFromFile)


// ---------------------------------------------------------------------------
// Generators (Step 2)
// ---------------------------------------------------------------------------

primitive \nodoc\ _Generators
  fun _alpha_chars(): String =>
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

  fun _alnum_chars(): String =>
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

  fun valid_name(): Generator[String] =>
    """
    Generates valid identifier names matching [a-zA-Z_][a-zA-Z0-9_]{0,19},
    filtered to exclude names that parse as keywords:
    - Names starting with "end" (parse as _EndNode or error)
    - Names starting with "if" + alpha/underscore (parse as _IfNode)
    """
    let first = _alpha_chars()
    let rest = _alnum_chars()
    Generator[String](
      object is GenObj[String]
        fun generate(rnd: Randomness): String^ =>
          let len = rnd.usize(1, 20)
          let s = recover iso String(len) end
          try s.push(first(rnd.usize(0, first.size() - 1))?) end
          var i: USize = 1
          while i < len do
            try s.push(rest(rnd.usize(0, rest.size() - 1))?) end
            i = i + 1
          end
          consume s
      end)
      .filter({(s: String): (String^, Bool) =>
        // Reject names starting with "end"
        if s.at("end", 0) then return (consume s, false) end
        // Reject names starting with "if" + alpha/underscore
        if (s.size() >= 3) and s.at("if", 0) then
          try
            let c = s(2)?
            if ((c >= 'a') and (c <= 'z'))
              or ((c >= 'A') and (c <= 'Z'))
              or (c == '_')
            then
              return (consume s, false)
            end
          end
        end
        (consume s, true)
      })

  fun valid_prop_stmt(): Generator[String] =>
    """
    Generates `name(.name){0,2}` — a dotted property path.
    """
    Generators.map3[String, String, String, String](
      valid_name(), valid_name(), valid_name(),
      {(a, b, c) =>
        let depth = a.size() % 3  // Use first name's length to vary depth
        if depth == 0 then
          a
        elseif depth == 1 then
          a + "." + b
        else
          a + "." + b + "." + c
        end
      })

  fun valid_call_stmt(): Generator[String] =>
    """
    Generates `name(prop)` — a function call with a property argument.
    """
    Generators.map2[String, String, String](
      valid_name(), valid_prop_stmt(),
      {(name, prop) => name + "(" + prop + ")" })

  fun valid_loop_stmt(): Generator[String] =>
    """
    Generates `for name in prop` — a loop statement.
    """
    Generators.map2[String, String, String](
      valid_name(), valid_prop_stmt(),
      {(name, prop) => "for " + name + " in " + prop })

  fun valid_if_stmt(): Generator[String] =>
    """
    Generates `if prop` — an if statement.
    """
    valid_prop_stmt().map[String]({(prop) => "if " + prop })

  fun valid_ifnotempty_stmt(): Generator[String] =>
    """
    Generates `ifnotempty prop` — an ifnotempty statement.
    """
    valid_prop_stmt().map[String]({(prop) => "ifnotempty " + prop })

  fun invalid_stmt(): Generator[box->String] =>
    """
    Generates invalid statement strings, one per distinct failure mode.
    """
    Generators.one_of[String]([
      ""           // empty
      "3abc"       // starts with digit
      "foo@bar"    // invalid character
      "foo("       // unclosed paren
      "foo()"      // empty call arg
      "for x"      // incomplete loop (no "in")
      "for x in"   // loop with no source
      "foo..bar"   // double dot
      ".foo"       // leading dot
      "for x y z"  // invalid loop syntax
      "end."       // trailing dot after end
    ])

  fun literal_text(): Generator[String] =>
    """
    Generates printable ASCII text with no `{` character, length 0-50.
    """
    let chars: String val =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      + "0123456789 !\"#$%&'()*+,-./:;<=>?@[\\]^_`|}~\t\n\r"
    let char_gen = Generators.usize(0, chars.size() - 1)
      .map[U8]({(idx) =>
        try chars(idx)? else ' ' end
      })
    Generators.byte_string(char_gen, 0, 50)

  fun template_value_string(): Generator[String] =>
    """
    Generates printable ASCII strings 0-50 chars for use as template values.
    """
    Generators.ascii_printable(0, 50)


// ---------------------------------------------------------------------------
// Existing tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TemplateTest is UnitTest
  fun name(): String => "Template basic functionality"

  fun apply(h: TestHelper)? =>
    let empty = Template.parse("")?
    h.assert_eq[String]("", empty.render(TemplateValues)?)

    let no_var = Template.parse("Template without variable")?
    h.assert_eq[String](
      "Template without variable", no_var.render(TemplateValues)?)

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


class \nodoc\ iso _LoopTest is UnitTest
  fun name(): String => "Template loops"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    let props = Map[String, TemplateValue]
    props("inner") = TemplateValue(
      [TemplateValue("rab"); TemplateValue("oof")])
    values("xs") = TemplateValue(
      [TemplateValue("foo"); TemplateValue("bar")], props)

    let var_not_used = Template.parse("{{ for x in xs }}{{ end }}")?
    h.assert_eq[String]("", var_not_used.render(values)?)

    let template = Template.parse("{{ for x in xs}}{{ x }} {{ end }}")?
    h.assert_eq[String]("foo bar ", template.render(values)?)

    let nested_template =
      Template.parse("{{ for x in xs.inner }}{{ x }}{{ end }}")?
    h.assert_eq[String]("raboof", nested_template.render(values)?)


class \nodoc\ iso _IfTest is UnitTest
  fun name(): String => "Template if"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    let template = Template.parse("{{ if spam }}Eggs{{ end }}")?
    h.assert_eq[String]("", template.render(values)?)

    values("spam") = "value"
    h.assert_eq[String]("Eggs", template.render(values)?)


class \nodoc\ iso _IfNotEmptyTest is UnitTest
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


class \nodoc\ iso _CallTest is UnitTest
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


class \nodoc\ iso _StmtParserTest is UnitTest
  fun name(): String => "Template statement parser"

  fun apply(h: TestHelper) =>
    h.assert_no_error({()? => _StmtParser.parse("end")? as _EndNode })
    h.assert_no_error(
      {()? => _StmtParser.parse("foo(spam.eggs)")? as _CallNode })
    h.assert_no_error(
      {()? => _StmtParser.parse("ifnotempty spam")? as _IfNotEmptyNode })


// ---------------------------------------------------------------------------
// TemplateValues tests (Step 3)
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestTemplateValuesStore is UnitTest
  fun name(): String => "TemplateValues store and retrieve"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("key") = "hello"
    h.assert_eq[String]("hello", values("key")?.string()?)

    h.assert_error({() ? => TemplateValues("nonexistent")? })


class \nodoc\ iso _TestTemplateValuesParentChain is UnitTest
  fun name(): String => "TemplateValues parent chain scoping"

  fun apply(h: TestHelper)? =>
    let parent = TemplateValues
    parent("shared") = "from_parent"
    parent("shadowed") = "parent_value"

    let child = parent._override("shadowed", TemplateValue("child_value"))

    // Child shadows parent
    h.assert_eq[String]("child_value", child("shadowed")?.string()?)
    // Child delegates to parent
    h.assert_eq[String]("from_parent", child("shared")?.string()?)
    // Neither has key
    h.assert_error({() ? =>
      let c = parent._override("x", TemplateValue("y"))
      c("missing")?
    })


class \nodoc\ iso _TestTemplateValuesLookup is UnitTest
  fun name(): String => "TemplateValues _lookup with dotted paths"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    let inner_props = Map[String, TemplateValue]
    inner_props("inner") = TemplateValue("found")
    values("obj") = TemplateValue("outer", inner_props)

    // Dotted property lookup succeeds
    let prop = _PropNode("obj", ["inner"])
    h.assert_eq[String]("found", values._lookup(prop)?.string()?)

    // Nonexistent nested property
    let bad_prop = _PropNode("obj", ["nonexistent"])
    h.assert_error({() ? =>
      let v = TemplateValues
      let p = Map[String, TemplateValue]
      p("inner") = TemplateValue("found")
      v("obj") = TemplateValue("outer", p)
      v._lookup(_PropNode("obj", ["nonexistent"]))?
    })

    // Missing top-level name
    h.assert_error({() ? =>
      TemplateValues._lookup(_PropNode("missing", []))?
    })


class \nodoc\ iso _PropTemplateValuesRoundtrip is Property1[String]
  fun name(): String => "TemplateValues roundtrip: store then retrieve"

  fun gen(): Generator[String] =>
    _Generators.valid_name()

  fun ref property(name': String, h: PropertyHelper) ? =>
    let values = TemplateValues
    let v: String val = name' + "_value"
    values(name') = v
    h.assert_eq[String](v, values(name')?.string()?)


class \nodoc\ iso _PropTemplateValuesOverrideShadows
  is Property1[(String, String, String)]
  fun name(): String =>
    "TemplateValues override shadows parent"

  fun gen(): Generator[(String, String, String)] =>
    Generators.zip3[String, String, String](
      _Generators.valid_name(),
      _Generators.template_value_string(),
      _Generators.template_value_string())

  fun ref property(
    sample: (String, String, String),
    h: PropertyHelper)
  ? =>
    (let n, let parent_val, let child_val) = sample
    let parent = TemplateValues
    parent(n) = parent_val
    let child = parent._override(n, TemplateValue(child_val))
    h.assert_eq[String](child_val, child(n)?.string()?)


// ---------------------------------------------------------------------------
// Parser tests (Step 4)
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropValidPropParsesToPropNode is Property1[String]
  fun name(): String => "Parser: valid prop parses to _PropNode"

  fun gen(): Generator[String] =>
    _Generators.valid_prop_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _PropNode


class \nodoc\ iso _PropValidCallParsesToCallNode is Property1[String]
  fun name(): String => "Parser: valid call parses to _CallNode"

  fun gen(): Generator[String] =>
    _Generators.valid_call_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _CallNode


class \nodoc\ iso _PropValidLoopParsesToLoopNode is Property1[String]
  fun name(): String => "Parser: valid loop parses to _LoopNode"

  fun gen(): Generator[String] =>
    _Generators.valid_loop_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _LoopNode


class \nodoc\ iso _PropValidIfParsesToIfNode is Property1[String]
  fun name(): String => "Parser: valid if parses to _IfNode"

  fun gen(): Generator[String] =>
    _Generators.valid_if_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _IfNode


class \nodoc\ iso _PropValidIfNotEmptyParsesToIfNotEmptyNode
  is Property1[String]
  fun name(): String =>
    "Parser: valid ifnotempty parses to _IfNotEmptyNode"

  fun gen(): Generator[String] =>
    _Generators.valid_ifnotempty_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _IfNotEmptyNode


class \nodoc\ iso _PropInvalidStmtErrors is Property1[box->String]
  fun name(): String => "Parser: invalid statements error"

  fun gen(): Generator[box->String] =>
    _Generators.invalid_stmt()

  fun ref property(stmt: box->String, h: PropertyHelper) =>
    h.assert_error({() ? =>
      _StmtParser.parse(stmt.clone())?
    })


class \nodoc\ iso _TestParserNodeFields is UnitTest
  fun name(): String => "Parser: node field correctness"

  fun apply(h: TestHelper)? =>
    // "end" → _EndNode
    match _StmtParser.parse("end")?
    | _EndNode => None
    else h.fail("expected _EndNode"); error
    end

    // "foo" → _PropNode(name="foo", props=[])
    match _StmtParser.parse("foo")?
    | let p: _PropNode =>
      h.assert_eq[String]("foo", p.name)
      h.assert_eq[USize](0, p.props.size())
    else h.fail("expected _PropNode"); error
    end

    // "foo.bar.baz" → _PropNode(name="foo", props=["bar", "baz"])
    match _StmtParser.parse("foo.bar.baz")?
    | let p: _PropNode =>
      h.assert_eq[String]("foo", p.name)
      h.assert_eq[USize](2, p.props.size())
      h.assert_eq[String]("bar", p.props(0)?)
      h.assert_eq[String]("baz", p.props(1)?)
    else h.fail("expected _PropNode"); error
    end

    // "double(x.y)" → _CallNode(name="double", arg=_PropNode("x", ["y"]))
    match _StmtParser.parse("double(x.y)")?
    | let c: _CallNode =>
      h.assert_eq[String]("double", c.name)
      h.assert_eq[String]("x", c.arg.name)
      h.assert_eq[USize](1, c.arg.props.size())
      h.assert_eq[String]("y", c.arg.props(0)?)
    else h.fail("expected _CallNode"); error
    end

    // "for item in list.items" → _LoopNode
    match _StmtParser.parse("for item in list.items")?
    | let l: _LoopNode =>
      h.assert_eq[String]("item", l.target)
      h.assert_eq[String]("list", l.source.name)
      h.assert_eq[USize](1, l.source.props.size())
      h.assert_eq[String]("items", l.source.props(0)?)
    else h.fail("expected _LoopNode"); error
    end

    // "if active" → _IfNode(value=_PropNode("active", []))
    match _StmtParser.parse("if active")?
    | let i: _IfNode =>
      h.assert_eq[String]("active", i.value.name)
      h.assert_eq[USize](0, i.value.props.size())
    else h.fail("expected _IfNode"); error
    end

    // "ifnotempty seq" → _IfNotEmptyNode(value=_PropNode("seq", []))
    match _StmtParser.parse("ifnotempty seq")?
    | let i: _IfNotEmptyNode =>
      h.assert_eq[String]("seq", i.value.name)
      h.assert_eq[USize](0, i.value.props.size())
    else h.fail("expected _IfNotEmptyNode"); error
    end

    // "  foo  " → _PropNode(name="foo") (whitespace stripped)
    match _StmtParser.parse("  foo  ")?
    | let p: _PropNode =>
      h.assert_eq[String]("foo", p.name)
      h.assert_eq[USize](0, p.props.size())
    else h.fail("expected _PropNode for stripped input"); error
    end


class \nodoc\ iso _TestParserKeywordAmbiguity is UnitTest
  fun name(): String => "Parser: keyword ambiguity behavior"

  fun apply(h: TestHelper) =>
    // "end" → _EndNode
    h.assert_no_error({() ? => _StmtParser.parse("end")? as _EndNode })

    // "endgame" → error (end prefix matches, pos < expected_pos)
    h.assert_error({() ? => _StmtParser.parse("endgame")? })

    // "iffy" → _IfNode(value=_PropNode("fy"))
    h.assert_no_error({() ? =>
      match _StmtParser.parse("iffy")?
      | let i: _IfNode =>
        if i.value.name != "fy" then error end
      else error
      end
    })

    // "ifnotemptyxyz" → _IfNotEmptyNode(value=_PropNode("xyz"))
    h.assert_no_error({() ? =>
      match _StmtParser.parse("ifnotemptyxyz")?
      | let i: _IfNotEmptyNode =>
        if i.value.name != "xyz" then error end
      else error
      end
    })

    // "for" → _PropNode(name="for") (keyword rule fails, falls through)
    h.assert_no_error({() ? =>
      _StmtParser.parse("for")? as _PropNode
    })

    // "if" → _PropNode(name="if") (keyword rule fails, falls through)
    h.assert_no_error({() ? =>
      _StmtParser.parse("if")? as _PropNode
    })

    // "ifnotempty" → _IfNode(value=_PropNode("notempty"))
    h.assert_no_error({() ? =>
      match _StmtParser.parse("ifnotempty")?
      | let i: _IfNode =>
        if i.value.name != "notempty" then error end
      else error
      end
    })


// ---------------------------------------------------------------------------
// Template parse error tests (Step 5)
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestParseErrorUnclosedBlock is UnitTest
  fun name(): String => "Template parse error: unclosed block"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? =>
      Template.parse("{{ for x in xs }}body")?
    })
    h.assert_error({() ? =>
      Template.parse("{{ if flag }}body")?
    })
    h.assert_error({() ? =>
      Template.parse("{{ ifnotempty seq }}body")?
    })
    h.assert_error({() ? =>
      Template.parse("{{ for x in xs }}{{ if y }}nested")?
    })


class \nodoc\ iso _TestParseErrorEndWithoutBlock is UnitTest
  fun name(): String => "Template parse error: end without block"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? => Template.parse("{{ end }}")? })
    h.assert_error({() ? =>
      Template.parse("{{ if flag }}body{{ end }}{{ end }}")?
    })


class \nodoc\ iso _TestParseErrorUnknownFunction is UnitTest
  fun name(): String => "Template parse error: unknown function"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? => Template.parse("{{ unknown(x) }}")? })


class \nodoc\ iso _TestParseErrorMalformedStmt is UnitTest
  fun name(): String => "Template parse error: malformed statement"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? => Template.parse("{{ 3bad }}")? })
    h.assert_error({() ? => Template.parse("{{ foo( }}")? })


class \nodoc\ iso _TestParseIncompleteDelimiters is UnitTest
  fun name(): String => "Template parse: incomplete delimiters are literal"

  fun apply(h: TestHelper)? =>
    // Missing }} causes text to be treated as literal
    let template = Template.parse("Hello {{ name")?
    h.assert_eq[String](
      "Hello {{ name", template.render(TemplateValues)?)


// ---------------------------------------------------------------------------
// Template render tests (Step 6)
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropLiteralIdentity is Property1[String]
  fun name(): String => "Render: literal text with no {{ is identity"

  fun gen(): Generator[String] =>
    _Generators.literal_text()

  fun ref property(text: String, h: PropertyHelper) ? =>
    let template = Template.parse(text)?
    h.assert_eq[String](text, template.render(TemplateValues)?)


class \nodoc\ iso _PropRenderDeterminism is Property1[String]
  fun name(): String => "Render: same template + values = same output"

  fun gen(): Generator[String] =>
    _Generators.literal_text()

  fun ref property(text: String, h: PropertyHelper) ? =>
    let template = Template.parse(text)?
    let values = TemplateValues
    let r1 = template.render(values)?
    let r2 = template.render(values)?
    h.assert_eq[String](r1, r2)


class \nodoc\ iso _PropVariableSubstitution is Property1[(String, String)]
  fun name(): String => "Render: {{ n }} with values(n)=v renders as v"

  fun gen(): Generator[(String, String)] =>
    Generators.zip2[String, String](
      _Generators.valid_name(),
      _Generators.template_value_string())

  fun ref property(sample: (String, String), h: PropertyHelper) ? =>
    (let n, let v) = sample
    let source: String val = "{{ " + n + " }}"
    let template = Template.parse(source)?
    let values = TemplateValues
    values(n) = v
    h.assert_eq[String](v, template.render(values)?)


class \nodoc\ iso _PropMissingVariableRendersEmpty is Property1[String]
  fun name(): String =>
    "Render: {{ n }} with no values renders empty"

  fun gen(): Generator[String] =>
    _Generators.valid_name()

  fun ref property(n: String, h: PropertyHelper) ? =>
    let source: String val = "{{ " + n + " }}"
    let template = Template.parse(source)?
    h.assert_eq[String]("", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderNestedLoop is UnitTest
  fun name(): String => "Render: nested for loops"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    // Build a list of items, each with a sub-list
    let item1_subs = Map[String, TemplateValue]
    item1_subs("subs") = TemplateValue(
      [TemplateValue("a"); TemplateValue("b")])
    let item2_subs = Map[String, TemplateValue]
    item2_subs("subs") = TemplateValue(
      [TemplateValue("c")])

    values("items") = TemplateValue(
      [TemplateValue("i1", item1_subs)
       TemplateValue("i2", item2_subs)])

    let template = Template.parse(
      "{{ for item in items }}[{{ for sub in item.subs }}" +
      "{{ sub }}{{ end }}]{{ end }}")?
    h.assert_eq[String]("[ab][c]", template.render(values)?)


class \nodoc\ iso _TestRenderLoopWithIf is UnitTest
  fun name(): String => "Render: if inside loop"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues

    let item1_props = Map[String, TemplateValue]
    item1_props("active") = TemplateValue("yes")
    let item2_props = Map[String, TemplateValue]
    // item2 has no "active" property

    values("items") = TemplateValue(
      [TemplateValue("A", item1_props)
       TemplateValue("B", item2_props)])

    let template = Template.parse(
      "{{ for x in items }}{{ if x.active }}*{{ end }}{{ end }}")?
    h.assert_eq[String]("*", template.render(values)?)


class \nodoc\ iso _TestRenderIfNotEmptyWithLoop is UnitTest
  fun name(): String => "Render: ifnotempty guarding a loop"

  fun apply(h: TestHelper)? =>
    // Non-empty case
    let values = TemplateValues
    values("items") = TemplateValue(
      [TemplateValue("x"); TemplateValue("y")])
    let template = Template.parse(
      "{{ ifnotempty items }}" +
      "{{ for i in items }}{{ i }}{{ end }}" +
      "{{ end }}")?
    h.assert_eq[String]("xy", template.render(values)?)

    // Empty case
    let values2 = TemplateValues
    values2("items") = TemplateValue([])
    h.assert_eq[String]("", template.render(values2)?)


class \nodoc\ iso _TestRenderAdjacentPlaceholders is UnitTest
  fun name(): String => "Render: adjacent placeholders concatenate"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ a }}{{ b }}{{ c }}")?
    let values = TemplateValues
    values("a") = "1"
    values("b") = "2"
    values("c") = "3"
    h.assert_eq[String]("123", template.render(values)?)


class \nodoc\ iso _TestRenderLoopVariableShadowing is UnitTest
  fun name(): String => "Render: loop variable shadows then restores outer"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "outer"
    values("items") = TemplateValue(
      [TemplateValue("inner1"); TemplateValue("inner2")])

    let template = Template.parse(
      "{{ x }}-{{ for x in items }}{{ x }}{{ end }}-{{ x }}")?
    h.assert_eq[String](
      "outer-inner1inner2-outer", template.render(values)?)


// ---------------------------------------------------------------------------
// Function call tests (Step 7)
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestCallWithNestedProp is UnitTest
  fun name(): String => "Call: function with dotted property argument"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    let user_props = Map[String, TemplateValue]
    user_props("name") = TemplateValue("alice")
    values("user") = TemplateValue("u", user_props)

    let ctx = TemplateContext(
      recover
        let functions = Map[String, {(String): String}]
        functions("upper") = {(s) =>
          let out = s.clone()
          out.upper_in_place()
          consume out
        }
        functions
      end
    )
    let template = Template.parse("{{ upper(user.name) }}", ctx)?
    h.assert_eq[String]("ALICE", template.render(values)?)


class \nodoc\ iso _TestCallArgMissing is UnitTest
  fun name(): String => "Call: missing argument value errors"

  fun apply(h: TestHelper) =>
    let ctx = TemplateContext(
      recover
        let functions = Map[String, {(String): String}]
        functions("f") = {(s) => s}
        functions
      end
    )
    h.assert_error({() ? =>
      let template = Template.parse("{{ f(missing) }}", ctx)?
      template.render(TemplateValues)?
    })


class \nodoc\ iso _TestCallMultipleFunctions is UnitTest
  fun name(): String => "Call: multiple function calls in template"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "ab"
    values("y") = "cd"

    let ctx = TemplateContext(
      recover
        let functions = Map[String, {(String): String}]
        functions("double") = {(s) => s + s}
        functions("rev") = {(s) =>
          let out = recover iso String(s.size()) end
          var i = s.size()
          while i > 0 do
            i = i - 1
            try out.push(s(i)?) end
          end
          consume out
        }
        functions
      end
    )
    let template = Template.parse(
      "{{ double(x) }}-{{ rev(y) }}", ctx)?
    h.assert_eq[String]("abab-dc", template.render(values)?)


// ---------------------------------------------------------------------------
// from_file test (Step 8)
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestFromFile is UnitTest
  fun name(): String => "Template from_file"

  fun apply(h: TestHelper)? =>
    let auth = FileAuth(h.env.root)

    // Parse fixture file
    let path = FilePath(auth, "templates/_test_fixture.txt")
    let template = Template.from_file(path)?
    let values = TemplateValues
    values("name") = "world"
    h.assert_eq[String]("Hello world", template.render(values)?)

    // Non-existent file errors
    h.assert_error({() ? =>
      let bad_path = FilePath(FileAuth(h.env.root),
        "templates/_nonexistent.txt")
      Template.from_file(bad_path)?
    })
