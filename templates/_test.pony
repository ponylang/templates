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
    test(Property1UnitTest[String](_PropValidIfNotParsesToIfNotNode))
    test(Property1UnitTest[String](_PropValidElseIfParsesToElseIfNode))
    test(Property1UnitTest[box->String](_PropInvalidStmtErrors))
    test(_TestParserNodeFields)
    test(_TestParserKeywordAmbiguity)

    // Template parse error tests (Step 5)
    test(_TestParseErrorUnclosedBlock)
    test(_TestParseErrorEndWithoutBlock)
    test(_TestParseErrorUnknownFunction)
    test(_TestParseErrorMalformedStmt)
    test(_TestParseIncompleteDelimiters)
    test(_TestParseErrorElseElseIf)

    // Template render tests (Step 6)
    test(Property1UnitTest[String](_PropLiteralIdentity))
    test(Property1UnitTest[String](_PropRenderDeterminism))
    test(Property1UnitTest[(String, String)](_PropVariableSubstitution))
    test(Property1UnitTest[String](_PropMissingVariableRendersEmpty))
    test(_TestRenderNestedLoop)
    test(_TestRenderLoopWithIf)
    test(_TestRenderIfWithSequence)
    test(_TestRenderIfElseWithSequence)
    test(_TestRenderIfNotWithSequence)
    test(_TestRenderIfGuardingLoop)
    test(_TestRenderAdjacentPlaceholders)
    test(_TestRenderLoopVariableShadowing)

    // ifnot render tests
    test(_TestRenderIfNot)
    test(_TestRenderIfNotElse)
    test(_TestRenderIfNotElseIf)
    test(_TestRenderIfNotElseIfElse)
    test(_TestRenderIfNotInsideLoop)
    test(_TestRenderNestedIfNotWithIf)

    // Else/elseif render tests
    test(_TestRenderIfElse)
    test(_TestRenderIfElseIf)
    test(_TestRenderIfElseIfElse)
    test(_TestRenderMultipleElseIfs)
    test(_TestRenderIfElseInsideLoop)
    test(_TestRenderNestedIfElse)

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
    - Names starting with "if" + alpha/underscore (parse as _IfNode or
      _IfNotNode)
    - Names starting with "else" (parse as _ElseNode, _ElseIfNode, or error)
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
        // Reject names starting with "else" (parses as _ElseNode or
        // _ElseIfNode)
        if s.at("else", 0) then return (consume s, false) end
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

  fun valid_ifnot_stmt(): Generator[String] =>
    """
    Generates `ifnot prop` — an ifnot statement.
    """
    valid_prop_stmt().map[String]({(prop) => "ifnot " + prop })

  fun valid_elseif_stmt(): Generator[String] =>
    """
    Generates `elseif prop` — an elseif statement.
    """
    valid_prop_stmt().map[String]({(prop) => "elseif " + prop })

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
      {()? => _StmtParser.parse("ifnot spam")? as _IfNotNode })


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


class \nodoc\ iso _PropValidIfNotParsesToIfNotNode is Property1[String]
  fun name(): String => "Parser: valid ifnot parses to _IfNotNode"

  fun gen(): Generator[String] =>
    _Generators.valid_ifnot_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _IfNotNode


class \nodoc\ iso _PropValidElseIfParsesToElseIfNode is Property1[String]
  fun name(): String => "Parser: valid elseif parses to _ElseIfNode"

  fun gen(): Generator[String] =>
    _Generators.valid_elseif_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _ElseIfNode


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

    // "ifnot active" → _IfNotNode(value=_PropNode("active", []))
    match _StmtParser.parse("ifnot active")?
    | let i: _IfNotNode =>
      h.assert_eq[String]("active", i.value.name)
      h.assert_eq[USize](0, i.value.props.size())
    else h.fail("expected _IfNotNode"); error
    end

    // "  foo  " → _PropNode(name="foo") (whitespace stripped)
    match _StmtParser.parse("  foo  ")?
    | let p: _PropNode =>
      h.assert_eq[String]("foo", p.name)
      h.assert_eq[USize](0, p.props.size())
    else h.fail("expected _PropNode for stripped input"); error
    end

    // "else" → _ElseNode
    match _StmtParser.parse("else")?
    | _ElseNode => None
    else h.fail("expected _ElseNode"); error
    end

    // "elseif active" → _ElseIfNode(value=_PropNode("active", []))
    match _StmtParser.parse("elseif active")?
    | let ei: _ElseIfNode =>
      h.assert_eq[String]("active", ei.value.name)
      h.assert_eq[USize](0, ei.value.props.size())
    else h.fail("expected _ElseIfNode"); error
    end

    // "elseif a.b" → _ElseIfNode with dotted prop
    match _StmtParser.parse("elseif a.b")?
    | let ei: _ElseIfNode =>
      h.assert_eq[String]("a", ei.value.name)
      h.assert_eq[USize](1, ei.value.props.size())
      h.assert_eq[String]("b", ei.value.props(0)?)
    else h.fail("expected _ElseIfNode with dotted prop"); error
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

    // "ifnotemptyxyz" → _IfNotNode(value=_PropNode("emptyxyz"))
    h.assert_no_error({() ? =>
      match _StmtParser.parse("ifnotemptyxyz")?
      | let i: _IfNotNode =>
        if i.value.name != "emptyxyz" then error end
      else error
      end
    })

    // "ifnotx" → _IfNotNode(value=_PropNode("x"))
    h.assert_no_error({() ? =>
      match _StmtParser.parse("ifnotx")?
      | let i: _IfNotNode =>
        if i.value.name != "x" then error end
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

    // "ifnot" → _IfNode(value=_PropNode("not"))
    h.assert_no_error({() ? =>
      match _StmtParser.parse("ifnot")?
      | let i: _IfNode =>
        if i.value.name != "not" then error end
      else error
      end
    })

    // "ifnotempty" → _IfNotNode(value=_PropNode("empty"))
    // (ifnot rule matches before if rule, consuming "ifnot" + "empty")
    h.assert_no_error({() ? =>
      match _StmtParser.parse("ifnotempty")?
      | let i: _IfNotNode =>
        if i.value.name != "empty" then error end
      else error
      end
    })

    // "elseiffoo" → _ElseIfNode(value=_PropNode("foo"))
    h.assert_no_error({() ? =>
      match _StmtParser.parse("elseiffoo")?
      | let ei: _ElseIfNode =>
        if ei.value.name != "foo" then error end
      else error
      end
    })

    // "elsewhere" → error (else matches, "where" is leftover → pos < expected)
    h.assert_error({() ? => _StmtParser.parse("elsewhere")? })


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
      Template.parse("{{ ifnot flag }}body")?
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


class \nodoc\ iso _TestParseErrorElseElseIf is UnitTest
  fun name(): String => "Template parse error: else/elseif misuse"

  fun apply(h: TestHelper) =>
    // else at top level
    h.assert_error({() ? => Template.parse("{{ else }}")? })

    // elseif at top level
    h.assert_error({() ? => Template.parse("{{ elseif x }}")? })

    // Double else
    h.assert_error({() ? =>
      Template.parse("{{ if a }}A{{ else }}B{{ else }}C{{ end }}")?
    })

    // elseif after else
    h.assert_error({() ? =>
      Template.parse("{{ if a }}A{{ else }}B{{ elseif c }}C{{ end }}")?
    })

    // else in a for loop
    h.assert_error({() ? =>
      Template.parse("{{ for x in xs }}{{ else }}{{ end }}")?
    })

    // elseif in a for loop
    h.assert_error({() ? =>
      Template.parse("{{ for x in xs }}{{ elseif y }}{{ end }}")?
    })

    // Double else in ifnot
    h.assert_error({() ? =>
      Template.parse(
        "{{ ifnot a }}A{{ else }}B{{ else }}C{{ end }}")?
    })

    // elseif after else in ifnot
    h.assert_error({() ? =>
      Template.parse(
        "{{ ifnot a }}A{{ else }}B{{ elseif c }}C{{ end }}")?
    })

    // Unclosed elseif chain
    h.assert_error({() ? =>
      Template.parse("{{ if a }}A{{ elseif b }}B")?
    })


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


class \nodoc\ iso _TestRenderIfWithSequence is UnitTest
  fun name(): String => "Render: if with sequence truthiness"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ if items }}yes{{ end }}")?

    // Empty sequence → falsy, renders empty
    let v1 = TemplateValues
    v1("items") = TemplateValue([])
    h.assert_eq[String]("", template.render(v1)?)

    // Non-empty sequence → truthy, renders body
    let v2 = TemplateValues
    v2("items") = TemplateValue([TemplateValue("a")])
    h.assert_eq[String]("yes", template.render(v2)?)

    // String value → truthy, renders body (unchanged behavior)
    let v3 = TemplateValues
    v3("items") = "hello"
    h.assert_eq[String]("yes", template.render(v3)?)


class \nodoc\ iso _TestRenderIfElseWithSequence is UnitTest
  fun name(): String => "Render: if/else with empty sequence falls to else"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if items }}has items{{ else }}no items{{ end }}")?

    // Empty sequence → else branch
    let v1 = TemplateValues
    v1("items") = TemplateValue([])
    h.assert_eq[String]("no items", template.render(v1)?)

    // Non-empty sequence → if body
    let v2 = TemplateValues
    v2("items") = TemplateValue([TemplateValue("a")])
    h.assert_eq[String]("has items", template.render(v2)?)


class \nodoc\ iso _TestRenderIfNotWithSequence is UnitTest
  fun name(): String => "Render: ifnot with sequence truthiness"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ ifnot items }}empty{{ end }}")?

    // Empty sequence → ifnot body rendered
    let v1 = TemplateValues
    v1("items") = TemplateValue([])
    h.assert_eq[String]("empty", template.render(v1)?)

    // Non-empty sequence → empty
    let v2 = TemplateValues
    v2("items") = TemplateValue([TemplateValue("a")])
    h.assert_eq[String]("", template.render(v2)?)


class \nodoc\ iso _TestRenderIfGuardingLoop is UnitTest
  fun name(): String => "Render: if guarding a loop with sequences"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if items }}" +
      "{{ for i in items }}{{ i }}{{ end }}" +
      "{{ end }}")?

    // Non-empty case
    let v1 = TemplateValues
    v1("items") = TemplateValue(
      [TemplateValue("x"); TemplateValue("y")])
    h.assert_eq[String]("xy", template.render(v1)?)

    // Empty case
    let v2 = TemplateValues
    v2("items") = TemplateValue([])
    h.assert_eq[String]("", template.render(v2)?)


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


class \nodoc\ iso _TestRenderIfElse is UnitTest
  fun name(): String => "Render: if/else branches"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ if flag }}yes{{ else }}no{{ end }}")?

    // Value present → if body
    let values = TemplateValues
    values("flag") = "true"
    h.assert_eq[String]("yes", template.render(values)?)

    // Value absent → else body
    h.assert_eq[String]("no", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderIfElseIf is UnitTest
  fun name(): String => "Render: if/elseif branches"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if a }}A{{ elseif b }}B{{ end }}")?

    // First matches
    let v1 = TemplateValues
    v1("a") = "yes"
    h.assert_eq[String]("A", template.render(v1)?)

    // Second matches
    let v2 = TemplateValues
    v2("b") = "yes"
    h.assert_eq[String]("B", template.render(v2)?)

    // Neither matches → empty
    h.assert_eq[String]("", template.render(TemplateValues)?)

    // Both match → first wins
    let v3 = TemplateValues
    v3("a") = "yes"
    v3("b") = "yes"
    h.assert_eq[String]("A", template.render(v3)?)


class \nodoc\ iso _TestRenderIfElseIfElse is UnitTest
  fun name(): String => "Render: if/elseif/else branches"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if a }}A{{ elseif b }}B{{ else }}C{{ end }}")?

    // First matches
    let v1 = TemplateValues
    v1("a") = "yes"
    h.assert_eq[String]("A", template.render(v1)?)

    // Second matches
    let v2 = TemplateValues
    v2("b") = "yes"
    h.assert_eq[String]("B", template.render(v2)?)

    // None match → else body
    h.assert_eq[String]("C", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderMultipleElseIfs is UnitTest
  fun name(): String => "Render: multiple elseif chain"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if a }}A{{ elseif b }}B{{ elseif c }}C{{ else }}D{{ end }}")?

    let v1 = TemplateValues
    v1("a") = "yes"
    h.assert_eq[String]("A", template.render(v1)?)

    let v2 = TemplateValues
    v2("b") = "yes"
    h.assert_eq[String]("B", template.render(v2)?)

    let v3 = TemplateValues
    v3("c") = "yes"
    h.assert_eq[String]("C", template.render(v3)?)

    h.assert_eq[String]("D", template.render(TemplateValues)?)

    // Multiple match → first wins
    let v5 = TemplateValues
    v5("b") = "yes"
    v5("c") = "yes"
    h.assert_eq[String]("B", template.render(v5)?)


class \nodoc\ iso _TestRenderIfElseInsideLoop is UnitTest
  fun name(): String => "Render: if/else inside for loop"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues

    let item1_props = Map[String, TemplateValue]
    item1_props("active") = TemplateValue("yes")
    let item2_props = Map[String, TemplateValue]

    values("items") = TemplateValue(
      [TemplateValue("A", item1_props)
       TemplateValue("B", item2_props)])

    let template = Template.parse(
      "{{ for x in items }}" +
      "{{ if x.active }}+{{ else }}-{{ end }}" +
      "{{ end }}")?
    h.assert_eq[String]("+-", template.render(values)?)


class \nodoc\ iso _TestRenderNestedIfElse is UnitTest
  fun name(): String => "Render: nested if/else blocks"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if a }}{{ if b }}AB{{ else }}A{{ end }}" +
      "{{ else }}{{ if b }}B{{ else }}none{{ end }}{{ end }}")?

    // Both present
    let v1 = TemplateValues
    v1("a") = "yes"
    v1("b") = "yes"
    h.assert_eq[String]("AB", template.render(v1)?)

    // Only a
    let v2 = TemplateValues
    v2("a") = "yes"
    h.assert_eq[String]("A", template.render(v2)?)

    // Only b
    let v3 = TemplateValues
    v3("b") = "yes"
    h.assert_eq[String]("B", template.render(v3)?)

    // Neither
    h.assert_eq[String]("none", template.render(TemplateValues)?)


// ---------------------------------------------------------------------------
// ifnot render tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestRenderIfNot is UnitTest
  fun name(): String => "Render: ifnot renders when absent"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ ifnot name }}Anonymous{{ end }}")?

    // Variable absent → body rendered
    h.assert_eq[String]("Anonymous", template.render(TemplateValues)?)

    // Variable present → empty
    let values = TemplateValues
    values("name") = "Alice"
    h.assert_eq[String]("", template.render(values)?)


class \nodoc\ iso _TestRenderIfNotElse is UnitTest
  fun name(): String => "Render: ifnot/else branches"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ ifnot name }}Anonymous{{ else }}{{ name }}{{ end }}")?

    // Variable absent → ifnot body
    h.assert_eq[String]("Anonymous", template.render(TemplateValues)?)

    // Variable present → else body
    let values = TemplateValues
    values("name") = "Alice"
    h.assert_eq[String]("Alice", template.render(values)?)


class \nodoc\ iso _TestRenderIfNotElseIf is UnitTest
  fun name(): String => "Render: ifnot/elseif branches"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ ifnot a }}no-a{{ elseif b }}has-b{{ end }}")?

    // a absent → ifnot body
    h.assert_eq[String]("no-a", template.render(TemplateValues)?)

    // a present, b present → elseif body
    let v1 = TemplateValues
    v1("a") = "yes"
    v1("b") = "yes"
    h.assert_eq[String]("has-b", template.render(v1)?)

    // a present, b absent → empty
    let v2 = TemplateValues
    v2("a") = "yes"
    h.assert_eq[String]("", template.render(v2)?)


class \nodoc\ iso _TestRenderIfNotElseIfElse is UnitTest
  fun name(): String => "Render: ifnot/elseif/else full chain"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ ifnot a }}no-a{{ elseif b }}has-b{{ else }}fallback{{ end }}")?

    // a absent → ifnot body
    h.assert_eq[String]("no-a", template.render(TemplateValues)?)

    // a present, b present → elseif body
    let v1 = TemplateValues
    v1("a") = "yes"
    v1("b") = "yes"
    h.assert_eq[String]("has-b", template.render(v1)?)

    // a present, b absent → else body
    let v2 = TemplateValues
    v2("a") = "yes"
    h.assert_eq[String]("fallback", template.render(v2)?)


class \nodoc\ iso _TestRenderIfNotInsideLoop is UnitTest
  fun name(): String => "Render: ifnot nested inside for loop"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues

    let item1_props = Map[String, TemplateValue]
    item1_props("label") = TemplateValue("tagged")
    let item2_props = Map[String, TemplateValue]

    values("items") = TemplateValue(
      [TemplateValue("A", item1_props)
       TemplateValue("B", item2_props)])

    let template = Template.parse(
      "{{ for x in items }}" +
      "{{ ifnot x.label }}unlabeled{{ else }}{{ x.label }}{{ end }}," +
      "{{ end }}")?
    h.assert_eq[String]("tagged,unlabeled,", template.render(values)?)


class \nodoc\ iso _TestRenderNestedIfNotWithIf is UnitTest
  fun name(): String => "Render: if nested inside ifnot"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ ifnot a }}{{ if b }}B-no-A{{ else }}no-A-no-B{{ end }}" +
      "{{ else }}has-A{{ end }}")?

    // a absent, b present
    let v1 = TemplateValues
    v1("b") = "yes"
    h.assert_eq[String]("B-no-A", template.render(v1)?)

    // a absent, b absent
    h.assert_eq[String]("no-A-no-B", template.render(TemplateValues)?)

    // a present
    let v2 = TemplateValues
    v2("a") = "yes"
    h.assert_eq[String]("has-A", template.render(v2)?)


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
