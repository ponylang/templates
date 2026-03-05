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
    test(Property1UnitTest[String](_PropValidPipeParsesToPipeNode))
    test(Property1UnitTest[String](_PropValidLoopParsesToLoopNode))
    test(Property1UnitTest[String](_PropValidIfParsesToIfNode))
    test(Property1UnitTest[String](_PropValidIfNotParsesToIfNotNode))
    test(Property1UnitTest[String](_PropValidElseIfParsesToElseIfNode))
    test(Property1UnitTest[box->String](_PropInvalidStmtErrors))
    test(_TestParserNodeFields)
    test(_TestParserPipeNodeFields)
    test(_TestParserKeywordAmbiguity)

    // Template parse error tests (Step 5)
    test(_TestParseErrorUnclosedBlock)
    test(_TestParseErrorEndWithoutBlock)
    test(_TestParseErrorUnknownFilter)
    test(_TestParseErrorFilterArityMismatch)
    test(_TestParseErrorMalformedStmt)
    test(_TestParseIncompleteDelimiters)
    test(_TestParseErrorElseElseIf)
    test(_TestParserPipeNotInControlFlow)

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

    // Filter pipe render tests
    test(Property1UnitTest[String](_PropPipeBasicFilter))
    test(Property1UnitTest[(String, String)](_PropPipeDefaultMissing))
    test(Property1UnitTest[(String, String, String)](
      _PropPipeDefaultPresent))
    test(_TestRenderPipeUpper)
    test(_TestRenderPipeLower)
    test(_TestRenderPipeTrim)
    test(_TestRenderPipeCapitalize)
    test(_TestRenderPipeTitle)
    test(_TestRenderPipeDefault)
    test(_TestRenderPipeReplace)
    test(_TestRenderPipeChain)
    test(_TestRenderPipeDottedSource)
    test(_TestRenderPipeVariableArg)
    test(_TestRenderPipeInsideLoop)
    test(_TestRenderPipeInsideIf)
    test(_TestRenderPipeDefaultThenUpper)
    test(_TestRenderPipeCustomFilter)
    test(_TestRenderPipeOverrideBuiltin)

    // Include parser tests
    test(Property1UnitTest[String](_PropValidIncludeParsesToIncludeNode))
    test(_TestParserIncludeNodeFields)
    test(_TestParserIncludeKeywordAmbiguity)

    // Include parse error tests
    test(_TestParseErrorMissingPartial)
    test(_TestParseErrorCircularInclude)

    // Include render tests
    test(_TestRenderInclude)
    test(_TestRenderIncludeInsideIf)
    test(_TestRenderIncludeInsideLoop)
    test(_TestRenderNestedIncludes)
    test(_TestRenderMultipleIncludes)
    test(_TestRenderIncludeWithBlocks)

    // Extends/block parser tests
    test(Property1UnitTest[String](_PropValidExtendsParsesToExtendsNode))
    test(Property1UnitTest[String](_PropValidBlockParsesToBlockNode))
    test(_TestParserExtendsBlockNodeFields)
    test(_TestParserExtendsBlockKeywordAmbiguity)

    // Extends/block parse error tests
    test(_TestParseErrorExtendsNotFirst)
    test(_TestParseErrorExtendsMissingBase)
    test(_TestParseErrorCircularExtends)
    test(_TestParseErrorElseAfterBlock)
    test(_TestParseErrorElseIfAfterBlock)
    test(_TestParseErrorDuplicateBlock)

    // Inheritance render tests
    test(_TestRenderInheritanceBasic)
    test(_TestRenderInheritanceMultipleBlocks)
    test(_TestRenderInheritanceEmptyDefault)
    test(_TestRenderInheritanceBlockInsideIf)
    test(_TestRenderInheritanceMultiLevel)
    test(_TestRenderInheritanceWithIncludes)
    test(_TestRenderInheritanceBlockWithVariables)
    test(_TestRenderBlocksWithoutExtends)

    // Default value render tests (using pipe syntax)
    test(Property1UnitTest[(String, String)](_PropDefaultWhenMissing))
    test(Property1UnitTest[(String, String, String)](_PropDefaultWhenPresent))
    test(_TestRenderDefaultBasic)
    test(_TestRenderDefaultWithDottedProp)
    test(_TestRenderDefaultInsideLoop)
    test(_TestRenderDefaultInsideIf)
    test(_TestRenderDefaultWithBraces)

    // Trim syntax tests
    test(_TestTrimLeftOnly)
    test(_TestTrimRightOnly)
    test(_TestTrimBoth)
    test(_TestTrimWithIf)
    test(_TestTrimWithFor)
    test(_TestTrimWithInclude)
    test(_TestTrimWithExtends)
    test(_TestTrimAdjacentTags)
    test(_TestTrimAtStart)
    test(_TestTrimAtEnd)
    test(_TestTrimProducesEmptyLiteral)
    test(Property1UnitTest[String](_PropTrimDeterminism))

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
        // Reject names starting with "block" + alpha/underscore
        // (parses as _BlockNode, same as "iffy" → _IfNode)
        if (s.size() >= 6) and s.at("block", 0) then
          try
            let c = s(5)?
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

  fun valid_pipe_stmt(): Generator[String] =>
    """
    Generates valid pipe expressions like `prop | upper` or
    `prop | default("val")`. Uses only built-in filter names with correct
    arities.
    """
    Generators.map2[String, String, String](
      valid_prop_stmt(), filter_arg_string(),
      {(prop, arg) =>
        let depth = prop.size() % 3
        if depth == 0 then
          prop + " | upper"
        elseif depth == 1 then
          prop + " | default(\"" + arg + "\")"
        else
          prop + " | trim | upper"
        end
      })

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

  fun valid_include_stmt(): Generator[String] =>
    """
    Generates `include "name"` where name matches `[a-zA-Z0-9_-]+`.
    """
    let chars: String val =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
    Generator[String](
      object is GenObj[String]
        fun generate(rnd: Randomness): String^ =>
          let len = rnd.usize(1, 20)
          let name = recover iso String(len) end
          var i: USize = 0
          while i < len do
            try name.push(chars(rnd.usize(0, chars.size() - 1))?) end
            i = i + 1
          end
          "include \"" + consume name + "\""
      end)

  fun valid_extends_stmt(): Generator[String] =>
    """
    Generates `extends "name"` where name matches `[a-zA-Z0-9_-]+`.
    """
    let chars: String val =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
    Generator[String](
      object is GenObj[String]
        fun generate(rnd: Randomness): String^ =>
          let len = rnd.usize(1, 20)
          let name = recover iso String(len) end
          var i: USize = 0
          while i < len do
            try name.push(chars(rnd.usize(0, chars.size() - 1))?) end
            i = i + 1
          end
          "extends \"" + consume name + "\""
      end)

  fun valid_block_stmt(): Generator[String] =>
    """
    Generates `block name` where name is a valid identifier.
    """
    valid_name().map[String]({(name) => "block " + name })

  fun filter_arg_string(): Generator[String] =>
    """
    Generates printable ASCII strings excluding `"`, length 0-30, for use
    as filter arguments in `| filter("...")`. Braces are allowed because the
    parser uses quote-aware delimiter scanning.
    """
    // Printable ASCII: space (0x20) through ~ (0x7E), excluding " (0x22)
    let chars: String val =
      " !#$%&'()*+,-./0123456789:;<=>?@"
      + "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`"
      + "abcdefghijklmnopqrstuvwxyz{|}~"
    Generator[String](
      object is GenObj[String]
        fun generate(rnd: Randomness): String^ =>
          let len = rnd.usize(0, 30)
          let s = recover iso String(len) end
          var i: USize = 0
          while i < len do
            try s.push(chars(rnd.usize(0, chars.size() - 1))?) end
            i = i + 1
          end
          consume s
      end)

  fun invalid_stmt(): Generator[box->String] =>
    """
    Generates invalid statement strings, one per distinct failure mode.
    """
    Generators.one_of[String]([
      ""           // empty
      "3abc"       // starts with digit
      "foo@bar"    // invalid character
      "for x"      // incomplete loop (no "in")
      "for x in"   // loop with no source
      "foo..bar"   // double dot
      ".foo"       // leading dot
      "for x y z"  // invalid loop syntax
      "end."       // trailing dot after end
      "include \"\"" // empty include name
      "include \""   // unclosed quote
      "foo |"       // incomplete pipe
      "foo | |"     // double pipe
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


class \nodoc\ iso _StmtParserTest is UnitTest
  fun name(): String => "Template statement parser"

  fun apply(h: TestHelper) =>
    h.assert_no_error({()? => _StmtParser.parse("end")? as _EndNode })
    h.assert_no_error(
      {()? => _StmtParser.parse("foo | upper")? as _PipeNode })
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


class \nodoc\ iso _PropValidPipeParsesToPipeNode is Property1[String]
  fun name(): String => "Parser: valid pipe parses to _PipeNode"

  fun gen(): Generator[String] =>
    _Generators.valid_pipe_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _PipeNode


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

    // "foo | upper" → _PipeNode(source=_PropNode("foo"), filters=[...])
    match _StmtParser.parse("foo | upper")?
    | let pipe: _PipeNode =>
      h.assert_eq[String]("foo", pipe.source.name)
      h.assert_eq[USize](0, pipe.source.props.size())
      h.assert_eq[USize](1, pipe.filters.size())
      h.assert_eq[String]("upper", pipe.filters(0)?.name)
      h.assert_eq[USize](0, pipe.filters(0)?.args.size())
    else h.fail("expected _PipeNode"); error
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


class \nodoc\ iso _TestParserPipeNodeFields is UnitTest
  fun name(): String => "Parser: pipe node field correctness"

  fun apply(h: TestHelper)? =>
    // "name | upper" → single 0-arg filter
    match _StmtParser.parse("name | upper")?
    | let pipe: _PipeNode =>
      h.assert_eq[String]("name", pipe.source.name)
      h.assert_eq[USize](1, pipe.filters.size())
      h.assert_eq[String]("upper", pipe.filters(0)?.name)
      h.assert_eq[USize](0, pipe.filters(0)?.args.size())
    else h.fail("expected _PipeNode for name | upper"); error
    end

    // 'name | default("x")' → single 1-arg filter with string literal
    match _StmtParser.parse("name | default(\"x\")")?
    | let pipe: _PipeNode =>
      h.assert_eq[String]("name", pipe.source.name)
      h.assert_eq[USize](1, pipe.filters.size())
      h.assert_eq[String]("default", pipe.filters(0)?.name)
      h.assert_eq[USize](1, pipe.filters(0)?.args.size())
      match pipe.filters(0)?.args(0)?
      | let s: String => h.assert_eq[String]("x", s)
      else h.fail("expected String arg"); error
      end
    else h.fail("expected _PipeNode for default"); error
    end

    // "a.b | trim | upper" → dotted source, two filters
    match _StmtParser.parse("a.b | trim | upper")?
    | let pipe: _PipeNode =>
      h.assert_eq[String]("a", pipe.source.name)
      h.assert_eq[USize](1, pipe.source.props.size())
      h.assert_eq[String]("b", pipe.source.props(0)?)
      h.assert_eq[USize](2, pipe.filters.size())
      h.assert_eq[String]("trim", pipe.filters(0)?.name)
      h.assert_eq[String]("upper", pipe.filters(1)?.name)
    else h.fail("expected _PipeNode for chain"); error
    end

    // "name | default(fallback)" → variable arg
    match _StmtParser.parse("name | default(fallback)")?
    | let pipe: _PipeNode =>
      h.assert_eq[USize](1, pipe.filters.size())
      h.assert_eq[USize](1, pipe.filters(0)?.args.size())
      match pipe.filters(0)?.args(0)?
      | let p: _PropNode =>
        h.assert_eq[String]("fallback", p.name)
      else h.fail("expected _PropNode arg"); error
      end
    else h.fail("expected _PipeNode for variable arg"); error
    end

    // 'name | replace("a", "b")' → two string literal args
    match _StmtParser.parse("name | replace(\"a\", \"b\")")?
    | let pipe: _PipeNode =>
      h.assert_eq[USize](1, pipe.filters.size())
      h.assert_eq[String]("replace", pipe.filters(0)?.name)
      h.assert_eq[USize](2, pipe.filters(0)?.args.size())
      match pipe.filters(0)?.args(0)?
      | let s: String => h.assert_eq[String]("a", s)
      else h.fail("expected String arg 0"); error
      end
      match pipe.filters(0)?.args(1)?
      | let s: String => h.assert_eq[String]("b", s)
      else h.fail("expected String arg 1"); error
      end
    else h.fail("expected _PipeNode for replace"); error
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


class \nodoc\ iso _TestParseErrorUnknownFilter is UnitTest
  fun name(): String => "Template parse error: unknown filter"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? => Template.parse("{{ x | nonexistent }}")? })


class \nodoc\ iso _TestParseErrorFilterArityMismatch is UnitTest
  fun name(): String => "Template parse error: filter arity mismatch"

  fun apply(h: TestHelper) =>
    // upper takes 0 args, giving it 1 should fail
    h.assert_error({() ? =>
      Template.parse("{{ x | upper(\"a\") }}")?
    })

    // default takes 1 arg, giving it 0 should fail
    h.assert_error({() ? =>
      Template.parse("{{ x | default }}")?
    })

    // replace takes 2 args, giving it 1 should fail
    h.assert_error({() ? =>
      Template.parse("{{ x | replace(\"a\") }}")?
    })


class \nodoc\ iso _TestParseErrorMalformedStmt is UnitTest
  fun name(): String => "Template parse error: malformed statement"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? => Template.parse("{{ 3bad }}")? })


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


class \nodoc\ iso _TestParserPipeNotInControlFlow is UnitTest
  fun name(): String =>
    "Parser: pipe not allowed in control flow positions"

  fun apply(h: TestHelper) =>
    // if name | upper → should fail
    h.assert_error({() ? =>
      _StmtParser.parse("if name | upper")?
    })

    // ifnot name | upper → should fail
    h.assert_error({() ? =>
      _StmtParser.parse("ifnot name | upper")?
    })

    // for x in items | upper → should fail
    h.assert_error({() ? =>
      _StmtParser.parse("for x in items | upper")?
    })

    // elseif name | upper → should fail
    h.assert_error({() ? =>
      _StmtParser.parse("elseif name | upper")?
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
// Filter pipe render tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropPipeBasicFilter is Property1[String]
  fun name(): String =>
    "Render: {{ name | upper }} always equals name.upper()"

  fun gen(): Generator[String] =>
    _Generators.template_value_string()

  fun ref property(val': String, h: PropertyHelper) ? =>
    let template = Template.parse("{{ x | upper }}")?
    let values = TemplateValues
    values("x") = val'
    let expected = val'.clone()
    expected.upper_in_place()
    h.assert_eq[String](consume expected, template.render(values)?)


class \nodoc\ iso _PropPipeDefaultMissing
  is Property1[(String, String)]
  fun name(): String =>
    "Render: missing var with default always returns fallback"

  fun gen(): Generator[(String, String)] =>
    Generators.zip2[String, String](
      _Generators.valid_name(),
      _Generators.filter_arg_string())

  fun ref property(sample: (String, String), h: PropertyHelper) ? =>
    (let n, let fallback) = sample
    let source: String val =
      "{{ " + n + " | default(\"" + fallback + "\") }}"
    let template = Template.parse(source)?
    h.assert_eq[String](fallback, template.render(TemplateValues)?)


class \nodoc\ iso _PropPipeDefaultPresent
  is Property1[(String, String, String)]
  fun name(): String =>
    "Render: present var with default always returns the var"

  fun gen(): Generator[(String, String, String)] =>
    Generators.zip3[String, String, String](
      _Generators.valid_name(),
      _Generators.template_value_string()
        .filter({(s: String): (String^, Bool) =>
          // Only non-empty strings; empty would trigger the default
          let ok = s.size() > 0
          (consume s, ok)
        }),
      _Generators.filter_arg_string())

  fun ref property(
    sample: (String, String, String),
    h: PropertyHelper)
  ? =>
    (let n, let actual_val, let fallback) = sample
    let source: String val =
      "{{ " + n + " | default(\"" + fallback + "\") }}"
    let template = Template.parse(source)?
    let values = TemplateValues
    values(n) = actual_val
    h.assert_eq[String](actual_val, template.render(values)?)


class \nodoc\ iso _TestRenderPipeUpper is UnitTest
  fun name(): String => "Render: pipe upper filter"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ name | upper }}")?
    let values = TemplateValues
    values("name") = "hello"
    h.assert_eq[String]("HELLO", template.render(values)?)


class \nodoc\ iso _TestRenderPipeLower is UnitTest
  fun name(): String => "Render: pipe lower filter"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ name | lower }}")?
    let values = TemplateValues
    values("name") = "HELLO"
    h.assert_eq[String]("hello", template.render(values)?)


class \nodoc\ iso _TestRenderPipeTrim is UnitTest
  fun name(): String => "Render: pipe trim filter"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ name | trim }}")?
    let values = TemplateValues
    values("name") = "  hello  "
    h.assert_eq[String]("hello", template.render(values)?)


class \nodoc\ iso _TestRenderPipeCapitalize is UnitTest
  fun name(): String => "Render: pipe capitalize filter"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ name | capitalize }}")?

    let v1 = TemplateValues
    v1("name") = "hello WORLD"
    h.assert_eq[String]("Hello world", template.render(v1)?)

    let v2 = TemplateValues
    v2("name") = ""
    h.assert_eq[String]("", template.render(v2)?)

    let v3 = TemplateValues
    v3("name") = "a"
    h.assert_eq[String]("A", template.render(v3)?)


class \nodoc\ iso _TestRenderPipeTitle is UnitTest
  fun name(): String => "Render: pipe title filter"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ name | title }}")?

    // Basic title case
    let v1 = TemplateValues
    v1("name") = "hello world"
    h.assert_eq[String]("Hello World", template.render(v1)?)

    // Already uppercased letters get lowered
    let v2 = TemplateValues
    v2("name") = "hELLO wORLD"
    h.assert_eq[String]("Hello World", template.render(v2)?)

    // Empty string
    let v3 = TemplateValues
    v3("name") = ""
    h.assert_eq[String]("", template.render(v3)?)

    // Single word
    let v4 = TemplateValues
    v4("name") = "hello"
    h.assert_eq[String]("Hello", template.render(v4)?)

    // Multiple whitespace types
    let v5 = TemplateValues
    v5("name") = "hello\tworld\nnow"
    h.assert_eq[String]("Hello\tWorld\nNow", template.render(v5)?)

    // Multiple consecutive spaces preserved
    let v6 = TemplateValues
    v6("name") = "hello  world"
    h.assert_eq[String]("Hello  World", template.render(v6)?)


class \nodoc\ iso _TestRenderPipeDefault is UnitTest
  fun name(): String => "Render: pipe default filter"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ name | default(\"anon\") }}")?

    // Missing → default
    h.assert_eq[String]("anon", template.render(TemplateValues)?)

    // Present → actual value
    let values = TemplateValues
    values("name") = "Alice"
    h.assert_eq[String]("Alice", template.render(values)?)

    // Empty string → default (empty triggers default filter)
    let v2 = TemplateValues
    v2("name") = ""
    h.assert_eq[String]("anon", template.render(v2)?)


class \nodoc\ iso _TestRenderPipeReplace is UnitTest
  fun name(): String => "Render: pipe replace filter"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ msg | replace(\"world\", \"pony\") }}")?
    let values = TemplateValues
    values("msg") = "hello world"
    h.assert_eq[String]("hello pony", template.render(values)?)


class \nodoc\ iso _TestRenderPipeChain is UnitTest
  fun name(): String => "Render: chained filters"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ name | trim | upper }}")?
    let values = TemplateValues
    values("name") = "  hello  "
    h.assert_eq[String]("HELLO", template.render(values)?)


class \nodoc\ iso _TestRenderPipeDottedSource is UnitTest
  fun name(): String => "Render: pipe with dotted source"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ user.name | upper }}")?
    let values = TemplateValues
    let user_props = Map[String, TemplateValue]
    user_props("name") = TemplateValue("alice")
    values("user") = TemplateValue("u", user_props)
    h.assert_eq[String]("ALICE", template.render(values)?)


class \nodoc\ iso _TestRenderPipeVariableArg is UnitTest
  fun name(): String => "Render: pipe filter with variable argument"

  fun apply(h: TestHelper)? =>
    let template = Template.parse("{{ name | default(fallback) }}")?
    let values = TemplateValues
    values("fallback") = "anon"

    // name missing → resolve fallback variable → "anon"
    h.assert_eq[String]("anon", template.render(values)?)

    // name present → actual value
    values("name") = "Alice"
    h.assert_eq[String]("Alice", template.render(values)?)


class \nodoc\ iso _TestRenderPipeInsideLoop is UnitTest
  fun name(): String => "Render: pipe inside for loop"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ for name in names }}{{ name | upper }} {{ end }}")?
    let values = TemplateValues
    values("names") = TemplateValue(
      [TemplateValue("alice"); TemplateValue("bob")])
    h.assert_eq[String]("ALICE BOB ", template.render(values)?)


class \nodoc\ iso _TestRenderPipeInsideIf is UnitTest
  fun name(): String => "Render: pipe inside conditional"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if show }}{{ name | upper }}{{ end }}")?

    let v1 = TemplateValues
    v1("show") = "yes"
    v1("name") = "alice"
    h.assert_eq[String]("ALICE", template.render(v1)?)

    h.assert_eq[String]("", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderPipeDefaultThenUpper is UnitTest
  fun name(): String =>
    "Render: default then upper (migration from old syntax)"

  fun apply(h: TestHelper)? =>
    // Old: {{ upper(name | default("anon")) }}
    // New: {{ name | default("anon") | upper }}
    let template = Template.parse(
      "{{ name | default(\"anon\") | upper }}")?

    // Missing → default → upper
    h.assert_eq[String]("ANON", template.render(TemplateValues)?)

    // Present → actual → upper
    let values = TemplateValues
    values("name") = "alice"
    h.assert_eq[String]("ALICE", template.render(values)?)


class \nodoc\ iso _TestRenderPipeCustomFilter is UnitTest
  fun name(): String => "Render: custom filter via TemplateContext"

  fun apply(h: TestHelper)? =>
    let ctx = TemplateContext(
      recover val
        let filters = Map[String, AnyFilter]
        filters("double") = recover val
          object is Filter
            fun apply(input: String): String =>
              input + input
          end
        end
        filters
      end
    )
    let template = Template.parse("{{ x | double }}", ctx)?
    let values = TemplateValues
    values("x") = "ab"
    h.assert_eq[String]("abab", template.render(values)?)


class \nodoc\ iso _TestRenderPipeOverrideBuiltin is UnitTest
  fun name(): String => "Render: override built-in filter"

  fun apply(h: TestHelper)? =>
    // Override "upper" with a filter that returns "OVERRIDDEN"
    let ctx = TemplateContext(
      recover val
        let filters = Map[String, AnyFilter]
        filters("upper") = recover val
          object is Filter
            fun apply(input: String): String =>
              "OVERRIDDEN"
          end
        end
        filters
      end
    )
    let template = Template.parse("{{ x | upper }}", ctx)?
    let values = TemplateValues
    values("x") = "hello"
    h.assert_eq[String]("OVERRIDDEN", template.render(values)?)


// ---------------------------------------------------------------------------
// Include parser tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropValidIncludeParsesToIncludeNode is Property1[String]
  fun name(): String => "Parser: valid include parses to _IncludeNode"

  fun gen(): Generator[String] =>
    _Generators.valid_include_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _IncludeNode


class \nodoc\ iso _TestParserIncludeNodeFields is UnitTest
  fun name(): String => "Parser: include node field correctness"

  fun apply(h: TestHelper)? =>
    // include "header" → _IncludeNode(name="header")
    match _StmtParser.parse("include \"header\"")?
    | let inc: _IncludeNode =>
      h.assert_eq[String]("header", inc.name)
    else h.fail("expected _IncludeNode"); error
    end

    // include "my-partial" → name with hyphen
    match _StmtParser.parse("include \"my-partial\"")?
    | let inc: _IncludeNode =>
      h.assert_eq[String]("my-partial", inc.name)
    else h.fail("expected _IncludeNode with hyphen"); error
    end

    // include "a1_b2" → name with digits and underscores
    match _StmtParser.parse("include \"a1_b2\"")?
    | let inc: _IncludeNode =>
      h.assert_eq[String]("a1_b2", inc.name)
    else h.fail("expected _IncludeNode with digits"); error
    end


class \nodoc\ iso _TestParserIncludeKeywordAmbiguity is UnitTest
  fun name(): String => "Parser: include keyword ambiguity"

  fun apply(h: TestHelper) =>
    // bare "include" → _PropNode (no quoted string follows)
    h.assert_no_error({() ? =>
      _StmtParser.parse("include")? as _PropNode
    })

    // "includefoo" → _PropNode (no space + quote)
    h.assert_no_error({() ? =>
      _StmtParser.parse("includefoo")? as _PropNode
    })


// ---------------------------------------------------------------------------
// Include parse error tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestParseErrorMissingPartial is UnitTest
  fun name(): String => "Template parse error: missing partial"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? =>
      Template.parse("{{ include \"missing\" }}")?
    })


class \nodoc\ iso _TestParseErrorCircularInclude is UnitTest
  fun name(): String => "Template parse error: circular include"

  fun apply(h: TestHelper) =>
    // Self-include
    h.assert_error({() ? =>
      let partials = recover val
        let m = Map[String, String]
        m("self") = "{{ include \"self\" }}"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse("{{ include \"self\" }}", ctx)?
    })

    // Mutual cycle: a includes b, b includes a
    h.assert_error({() ? =>
      let partials = recover val
        let m = Map[String, String]
        m("a") = "{{ include \"b\" }}"
        m("b") = "{{ include \"a\" }}"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse("{{ include \"a\" }}", ctx)?
    })


// ---------------------------------------------------------------------------
// Include render tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestRenderInclude is UnitTest
  fun name(): String => "Render: basic include with variable substitution"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("greeting") = "Hello {{ name }}!"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(">> {{ include \"greeting\" }} <<", ctx)?
    let values = TemplateValues
    values("name") = "world"
    h.assert_eq[String](">> Hello world! <<", template.render(values)?)


class \nodoc\ iso _TestRenderIncludeInsideIf is UnitTest
  fun name(): String => "Render: include inside conditional"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("badge") = "[{{ role }}]"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(
      "{{ if role }}{{ include \"badge\" }}{{ end }}", ctx)?

    // With role
    let v1 = TemplateValues
    v1("role") = "admin"
    h.assert_eq[String]("[admin]", template.render(v1)?)

    // Without role
    h.assert_eq[String]("", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderIncludeInsideLoop is UnitTest
  fun name(): String => "Render: include inside loop"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("item") = "<{{ x }}>"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(
      "{{ for x in items }}{{ include \"item\" }}{{ end }}", ctx)?
    let values = TemplateValues
    values("items") = TemplateValue(
      [TemplateValue("a"); TemplateValue("b"); TemplateValue("c")])
    h.assert_eq[String]("<a><b><c>", template.render(values)?)


class \nodoc\ iso _TestRenderNestedIncludes is UnitTest
  fun name(): String => "Render: nested includes (A includes B includes C)"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("a") = "[{{ include \"b\" }}]"
      m("b") = "({{ include \"c\" }})"
      m("c") = "{{ x }}"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse("{{ include \"a\" }}", ctx)?
    let values = TemplateValues
    values("x") = "deep"
    h.assert_eq[String]("[(deep)]", template.render(values)?)


class \nodoc\ iso _TestRenderMultipleIncludes is UnitTest
  fun name(): String => "Render: multiple includes in one template"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("header") = "=={{ title }}=="
      m("footer") = "--end--"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(
      "{{ include \"header\" }}\nbody\n{{ include \"footer\" }}", ctx)?
    let values = TemplateValues
    values("title") = "Page"
    h.assert_eq[String]("==Page==\nbody\n--end--", template.render(values)?)


class \nodoc\ iso _TestRenderIncludeWithBlocks is UnitTest
  fun name(): String => "Render: include containing its own blocks"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("list") =
        "{{ if items }}{{ for i in items }}{{ i }},{{ end }}{{ else }}none{{ end }}"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse("Items: {{ include \"list\" }}", ctx)?

    // With items
    let v1 = TemplateValues
    v1("items") = TemplateValue(
      [TemplateValue("x"); TemplateValue("y")])
    h.assert_eq[String]("Items: x,y,", template.render(v1)?)

    // Without items (empty sequence)
    let v2 = TemplateValues
    v2("items") = TemplateValue(Array[TemplateValue])
    h.assert_eq[String]("Items: none", template.render(v2)?)


// ---------------------------------------------------------------------------
// Extends/block parser tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropValidExtendsParsesToExtendsNode is Property1[String]
  fun name(): String => "Parser: valid extends parses to _ExtendsNode"

  fun gen(): Generator[String] =>
    _Generators.valid_extends_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _ExtendsNode


class \nodoc\ iso _PropValidBlockParsesToBlockNode is Property1[String]
  fun name(): String => "Parser: valid block parses to _BlockNode"

  fun gen(): Generator[String] =>
    _Generators.valid_block_stmt()

  fun ref property(stmt: String, h: PropertyHelper) ? =>
    _StmtParser.parse(stmt)? as _BlockNode


class \nodoc\ iso _TestParserExtendsBlockNodeFields is UnitTest
  fun name(): String => "Parser: extends and block node field correctness"

  fun apply(h: TestHelper)? =>
    // extends "base" → _ExtendsNode(name="base")
    match _StmtParser.parse("extends \"base\"")?
    | let ext: _ExtendsNode =>
      h.assert_eq[String]("base", ext.name)
    else h.fail("expected _ExtendsNode"); error
    end

    // extends "my-layout" → name with hyphen
    match _StmtParser.parse("extends \"my-layout\"")?
    | let ext: _ExtendsNode =>
      h.assert_eq[String]("my-layout", ext.name)
    else h.fail("expected _ExtendsNode with hyphen"); error
    end

    // block content → _BlockNode(name="content")
    match _StmtParser.parse("block content")?
    | let blk: _BlockNode =>
      h.assert_eq[String]("content", blk.name)
    else h.fail("expected _BlockNode"); error
    end

    // block head → _BlockNode(name="head")
    match _StmtParser.parse("block head")?
    | let blk: _BlockNode =>
      h.assert_eq[String]("head", blk.name)
    else h.fail("expected _BlockNode"); error
    end


class \nodoc\ iso _TestParserExtendsBlockKeywordAmbiguity is UnitTest
  fun name(): String => "Parser: extends/block keyword ambiguity"

  fun apply(h: TestHelper) =>
    // bare "extends" → _PropNode (no quoted string follows)
    h.assert_no_error({() ? =>
      _StmtParser.parse("extends")? as _PropNode
    })

    // "extendsfoo" → _PropNode (no space + quote)
    h.assert_no_error({() ? =>
      _StmtParser.parse("extendsfoo")? as _PropNode
    })

    // bare "block" → _PropNode (no space + name follows)
    h.assert_no_error({() ? =>
      _StmtParser.parse("block")? as _PropNode
    })

    // "blockfoo" → _BlockNode("foo") (like "iffy" → _IfNode)
    h.assert_no_error({() ? =>
      match _StmtParser.parse("blockfoo")?
      | let blk: _BlockNode =>
        if blk.name != "foo" then error end
      else error
      end
    })


// ---------------------------------------------------------------------------
// Extends/block parse error tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestParseErrorExtendsNotFirst is UnitTest
  fun name(): String => "Template parse error: extends not first statement"

  fun apply(h: TestHelper) =>
    // extends after a variable substitution
    h.assert_error({() ? =>
      let partials = recover val
        let m = Map[String, String]
        m("base") = "base content"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse("{{ name }}{{ extends \"base\" }}", ctx)?
    })

    // extends after an if block
    h.assert_error({() ? =>
      let partials = recover val
        let m = Map[String, String]
        m("base") = "base content"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse(
        "{{ if x }}y{{ end }}{{ extends \"base\" }}", ctx)?
    })


class \nodoc\ iso _TestParseErrorExtendsMissingBase is UnitTest
  fun name(): String => "Template parse error: extends references missing base"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? =>
      Template.parse("{{ extends \"nonexistent\" }}")?
    })


class \nodoc\ iso _TestParseErrorCircularExtends is UnitTest
  fun name(): String => "Template parse error: circular extends"

  fun apply(h: TestHelper) =>
    // Self-extends
    h.assert_error({() ? =>
      let partials = recover val
        let m = Map[String, String]
        m("self") = "{{ extends \"self\" }}"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse("{{ extends \"self\" }}", ctx)?
    })

    // Mutual cycle: a extends b, b extends a
    h.assert_error({() ? =>
      let partials = recover val
        let m = Map[String, String]
        m("a") = "{{ extends \"b\" }}"
        m("b") = "{{ extends \"a\" }}"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse("{{ extends \"a\" }}", ctx)?
    })


class \nodoc\ iso _TestParseErrorElseAfterBlock is UnitTest
  fun name(): String => "Template parse error: else after block"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? =>
      Template.parse("{{ block content }}body{{ else }}alt{{ end }}")?
    })


class \nodoc\ iso _TestParseErrorElseIfAfterBlock is UnitTest
  fun name(): String => "Template parse error: elseif after block"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? =>
      Template.parse(
        "{{ block content }}body{{ elseif x }}alt{{ end }}")?
    })


class \nodoc\ iso _TestParseErrorDuplicateBlock is UnitTest
  fun name(): String =>
    "Template parse error: duplicate block names in child"

  fun apply(h: TestHelper) =>
    h.assert_error({() ? =>
      let partials = recover val
        let m = Map[String, String]
        m("base") = "{{ block slot }}default{{ end }}"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse(
        "{{ extends \"base\" }}" +
        "{{ block slot }}first{{ end }}" +
        "{{ block slot }}second{{ end }}",
        ctx)?
    })


// ---------------------------------------------------------------------------
// Inheritance render tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestRenderInheritanceBasic is UnitTest
  fun name(): String => "Render: basic inheritance overrides one block"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("base") =
        "<head>{{ block head }}default{{ end }}</head>" +
        "<body>{{ block content }}{{ end }}</body>"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(
      "{{ extends \"base\" }}" +
      "{{ block content }}Hello!{{ end }}",
      ctx)?
    let values = TemplateValues
    h.assert_eq[String](
      "<head>default</head><body>Hello!</body>",
      template.render(values)?)


class \nodoc\ iso _TestRenderInheritanceMultipleBlocks is UnitTest
  fun name(): String =>
    "Render: inheritance overrides subset of blocks"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("base") =
        "{{ block a }}A{{ end }}-{{ block b }}B{{ end }}" +
        "-{{ block c }}C{{ end }}"
      m
    end
    let ctx = TemplateContext(where partials' = partials)

    // Override only 'a' and 'c', leave 'b' as default
    let template = Template.parse(
      "{{ extends \"base\" }}" +
      "{{ block a }}X{{ end }}" +
      "{{ block c }}Z{{ end }}",
      ctx)?
    h.assert_eq[String]("X-B-Z", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderInheritanceEmptyDefault is UnitTest
  fun name(): String => "Render: block with empty default"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("base") = "before{{ block slot }}{{ end }}after"
      m
    end
    let ctx = TemplateContext(where partials' = partials)

    // Without override — empty default
    let t1 = Template.parse(
      "{{ extends \"base\" }}", ctx)?
    h.assert_eq[String]("beforeafter", t1.render(TemplateValues)?)

    // With override — fills slot
    let t2 = Template.parse(
      "{{ extends \"base\" }}{{ block slot }}FILL{{ end }}", ctx)?
    h.assert_eq[String]("beforeFILLafter", t2.render(TemplateValues)?)


class \nodoc\ iso _TestRenderInheritanceBlockInsideIf is UnitTest
  fun name(): String => "Render: block inside if/for in base"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("base") =
        "{{ if show }}{{ block content }}default{{ end }}{{ end }}"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(
      "{{ extends \"base\" }}" +
      "{{ block content }}overridden{{ end }}",
      ctx)?

    // show present → overridden block renders
    let v1 = TemplateValues
    v1("show") = "yes"
    h.assert_eq[String]("overridden", template.render(v1)?)

    // show absent → if body not rendered
    h.assert_eq[String]("", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderInheritanceMultiLevel is UnitTest
  fun name(): String => "Render: multi-level inheritance (3 levels)"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("grandparent") =
        "[{{ block title }}GP{{ end }}|{{ block body }}GP-body{{ end }}]"
      m("parent") =
        "{{ extends \"grandparent\" }}" +
        "{{ block body }}P-body{{ end }}"
      m
    end
    let ctx = TemplateContext(where partials' = partials)

    // Child overrides title, parent already overrode body
    let template = Template.parse(
      "{{ extends \"parent\" }}" +
      "{{ block title }}Child{{ end }}",
      ctx)?
    h.assert_eq[String]("[Child|P-body]", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderInheritanceWithIncludes is UnitTest
  fun name(): String => "Render: inheritance combined with includes"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("nav") = "[NAV]"
      m("base") =
        "{{ include \"nav\" }}{{ block content }}default{{ end }}"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(
      "{{ extends \"base\" }}" +
      "{{ block content }}page{{ end }}",
      ctx)?
    h.assert_eq[String]("[NAV]page", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderInheritanceBlockWithVariables is UnitTest
  fun name(): String => "Render: block overrides using template variables"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let m = Map[String, String]
      m("base") =
        "<title>{{ block title }}Default{{ end }}</title>"
      m
    end
    let ctx = TemplateContext(where partials' = partials)
    let template = Template.parse(
      "{{ extends \"base\" }}" +
      "{{ block title }}{{ page_title }}{{ end }}",
      ctx)?
    let values = TemplateValues
    values("page_title") = "My Page"
    h.assert_eq[String]("<title>My Page</title>", template.render(values)?)


class \nodoc\ iso _TestRenderBlocksWithoutExtends is UnitTest
  fun name(): String =>
    "Render: standalone template with blocks renders defaults"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "before{{ block slot }}DEFAULT{{ end }}after")?
    h.assert_eq[String](
      "beforeDEFAULTafter", template.render(TemplateValues)?)


// ---------------------------------------------------------------------------
// Default value render tests (using pipe syntax)
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropDefaultWhenMissing
  is Property1[(String, String)]
  fun name(): String =>
    "Render: missing variable renders default value"

  fun gen(): Generator[(String, String)] =>
    Generators.zip2[String, String](
      _Generators.valid_name(),
      _Generators.filter_arg_string())

  fun ref property(sample: (String, String), h: PropertyHelper) ? =>
    (let n, let default_val) = sample
    let source: String val =
      "{{ " + n + " | default(\"" + default_val + "\") }}"
    let template = Template.parse(source)?
    h.assert_eq[String](default_val, template.render(TemplateValues)?)


class \nodoc\ iso _PropDefaultWhenPresent
  is Property1[(String, String, String)]
  fun name(): String =>
    "Render: present variable ignores default value"

  fun gen(): Generator[(String, String, String)] =>
    Generators.zip3[String, String, String](
      _Generators.valid_name(),
      _Generators.template_value_string()
        .filter({(s: String): (String^, Bool) =>
          let ok = s.size() > 0
          (consume s, ok)
        }),
      _Generators.filter_arg_string())

  fun ref property(
    sample: (String, String, String),
    h: PropertyHelper)
  ? =>
    (let n, let actual_val, let default_val) = sample
    let source: String val =
      "{{ " + n + " | default(\"" + default_val + "\") }}"
    let template = Template.parse(source)?
    let values = TemplateValues
    values(n) = actual_val
    h.assert_eq[String](actual_val, template.render(values)?)


class \nodoc\ iso _TestRenderDefaultBasic is UnitTest
  fun name(): String => "Render: default value basic cases"

  fun apply(h: TestHelper)? =>
    // Variable present → actual value, default ignored
    let t1 = Template.parse("{{ name | default(\"fallback\") }}")?
    let v1 = TemplateValues
    v1("name") = "Alice"
    h.assert_eq[String]("Alice", t1.render(v1)?)

    // Variable missing → default used
    h.assert_eq[String]("fallback", t1.render(TemplateValues)?)

    // Empty default string
    let t2 = Template.parse("{{ name | default(\"\") }}")?
    h.assert_eq[String]("", t2.render(TemplateValues)?)


class \nodoc\ iso _TestRenderDefaultWithDottedProp is UnitTest
  fun name(): String =>
    "Render: default value with dotted property"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ user.name | default(\"anon\") }}")?

    // Dotted prop present → actual value
    let v1 = TemplateValues
    let user_props = Map[String, TemplateValue]
    user_props("name") = TemplateValue("Alice")
    v1("user") = TemplateValue("u", user_props)
    h.assert_eq[String]("Alice", template.render(v1)?)

    // Top-level name missing → default
    h.assert_eq[String]("anon", template.render(TemplateValues)?)

    // Top-level present but nested prop missing → default
    let v2 = TemplateValues
    v2("user") = TemplateValue("u")
    h.assert_eq[String]("anon", template.render(v2)?)


class \nodoc\ iso _TestRenderDefaultInsideLoop is UnitTest
  fun name(): String => "Render: default value inside loop body"

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
      "{{ x.label | default(\"none\") }}," +
      "{{ end }}")?
    h.assert_eq[String]("tagged,none,", template.render(values)?)


class \nodoc\ iso _TestRenderDefaultInsideIf is UnitTest
  fun name(): String =>
    "Render: default value in body of conditional"

  fun apply(h: TestHelper)? =>
    let template = Template.parse(
      "{{ if show }}{{ title | default(\"Untitled\") }}{{ end }}")?

    // show present, title present
    let v1 = TemplateValues
    v1("show") = "yes"
    v1("title") = "My Page"
    h.assert_eq[String]("My Page", template.render(v1)?)

    // show present, title missing → default used
    let v2 = TemplateValues
    v2("show") = "yes"
    h.assert_eq[String]("Untitled", template.render(v2)?)

    // show absent → body not rendered at all
    h.assert_eq[String]("", template.render(TemplateValues)?)


class \nodoc\ iso _TestRenderDefaultWithBraces is UnitTest
  fun name(): String =>
    "Render: default value containing braces"

  fun apply(h: TestHelper) ? =>
    let values = TemplateValues

    h.assert_eq[String]("a}b",
      Template.parse("{{ x | default(\"a}b\") }}")?.render(values)?)
    h.assert_eq[String]("a}}b",
      Template.parse("{{ x | default(\"a}}b\") }}")?.render(values)?)
    h.assert_eq[String]("a{b",
      Template.parse("{{ x | default(\"a{b\") }}")?.render(values)?)
    h.assert_eq[String]("a{{b",
      Template.parse("{{ x | default(\"a{{b\") }}")?.render(values)?)


// ---------------------------------------------------------------------------
// Trim syntax tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestTrimLeftOnly is UnitTest
  fun name(): String => "Trim: left trim strips trailing whitespace"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "world"
    // {{- strips trailing whitespace (spaces) from preceding literal
    h.assert_eq[String]("helloworld",
      Template.parse("hello   {{- x }}")?.render(values)?)
    // Strips newlines and tabs too
    h.assert_eq[String]("helloworld",
      Template.parse("hello\n\t {{- x }}")?.render(values)?)


class \nodoc\ iso _TestTrimRightOnly is UnitTest
  fun name(): String => "Trim: right trim strips leading whitespace"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "hello"
    // -}} strips leading whitespace from following literal
    h.assert_eq[String]("helloworld",
      Template.parse("{{ x -}}   world")?.render(values)?)
    // Strips newlines and tabs too
    h.assert_eq[String]("helloworld",
      Template.parse("{{ x -}}\n\t world")?.render(values)?)


class \nodoc\ iso _TestTrimBoth is UnitTest
  fun name(): String => "Trim: both trims on same tag"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "middle"
    h.assert_eq[String]("leftmiddleright",
      Template.parse("left   {{- x -}}   right")?.render(values)?)


class \nodoc\ iso _TestTrimWithIf is UnitTest
  fun name(): String => "Trim: with if/end blocks"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("show") = "yes"
    // Trim around if/end strips all adjacent whitespace
    h.assert_eq[String]("beforecontentafter",
      Template.parse(
        "before\n{{- if show -}}\ncontent\n{{- end -}}\nafter")?
        .render(values)?)
    // Selective trim: only right-trim on if, only left-trim on end
    // keeps content whitespace intact
    h.assert_eq[String]("before\ncontent\nafter",
      Template.parse(
        "before\n{{ if show -}}\ncontent\n{{- end }}\nafter")?
        .render(values)?)


class \nodoc\ iso _TestTrimWithFor is UnitTest
  fun name(): String => "Trim: with for loop"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("items") = TemplateValue(
      recover val
        let s = Array[TemplateValue]
        s.push(TemplateValue("a"))
        s.push(TemplateValue("b"))
        s.push(TemplateValue("c"))
        s
      end)
    // Right-trim on for and left-trim on end to avoid blank lines
    // around loop body. Each iteration produces "- <item>\n".
    h.assert_eq[String]("items:\n- a\n- b\n- c\n",
      Template.parse(
        "items:\n{{ for item in items -}}\n- {{ item }}\n{{ end }}")?
        .render(values)?)


class \nodoc\ iso _TestTrimWithInclude is UnitTest
  fun name(): String => "Trim: with include"

  fun apply(h: TestHelper)? =>
    let ctx = TemplateContext(where partials' =
      recover val
        let p = Map[String, String]
        p("part") = "included"
        p
      end)
    h.assert_eq[String]("beforeincludedafter",
      Template.parse(
        "before   {{- include \"part\" -}}   after", ctx)?
        .render(TemplateValues)?)


class \nodoc\ iso _TestTrimWithExtends is UnitTest
  fun name(): String => "Trim: extends with trim markers"

  fun apply(h: TestHelper)? =>
    let ctx = TemplateContext(where partials' =
      recover val
        let p = Map[String, String]
        p("base") = "hello {{ block content }}default{{ end }}"
        p
      end)
    // Trim markers on extends should parse correctly
    let template = Template.parse(
      "{{- extends \"base\" -}}" +
      "{{ block content }}world{{ end }}", ctx)?
    let values = TemplateValues
    h.assert_eq[String]("hello world", template.render(values)?)


class \nodoc\ iso _TestTrimAdjacentTags is UnitTest
  fun name(): String => "Trim: adjacent tags with no literal between"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("a") = "one"
    values("b") = "two"
    // -}} on first tag should strip leading whitespace from text after
    // second tag, even though there's no literal between the two tags
    h.assert_eq[String]("onetwotext",
      Template.parse("{{ a -}}{{ b -}}   text")?.render(values)?)


class \nodoc\ iso _TestTrimAtStart is UnitTest
  fun name(): String => "Trim: left trim at start of template"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "hello"
    // {{- at very start — no preceding literal to strip
    h.assert_eq[String]("hello",
      Template.parse("{{- x }}")?.render(values)?)


class \nodoc\ iso _TestTrimAtEnd is UnitTest
  fun name(): String => "Trim: right trim at end of template"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("x") = "hello"
    // -}} at very end — no following literal to strip
    h.assert_eq[String]("hello",
      Template.parse("{{ x -}}")?.render(values)?)


class \nodoc\ iso _TestTrimProducesEmptyLiteral is UnitTest
  fun name(): String => "Trim: trimming produces empty literal (skipped)"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("a") = "one"
    values("b") = "two"
    // The spaces between tags get fully trimmed away
    h.assert_eq[String]("onetwo",
      Template.parse("{{ a -}}   {{- b }}")?.render(values)?)


class \nodoc\ iso _PropTrimDeterminism is Property1[String]
  """
  Templates with trim markers produce the same output on repeated renders.
  """
  fun name(): String => "Trim: deterministic rendering"

  fun gen(): Generator[String] =>
    _Generators.valid_name()

  fun property(name': String, h: PropertyHelper)? =>
    let source: String val = "  {{- " + name' + " -}}  "
    let template = Template.parse(source)?
    let values = TemplateValues
    values(name') = "val"
    let r1 = template.render(values)?
    let r2 = template.render(values)?
    h.assert_eq[String](r1, r2)


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
