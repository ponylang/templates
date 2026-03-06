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

    // String literal pipe source tests
    test(_TestRenderPipeLiteralSource)
    test(_TestRenderPipeLiteralChain)
    test(_TestRenderPipeLiteralDefault)
    test(_TestRenderPipeLiteralReplace)
    test(_TestParserPipeLiteralSource)
    test(Property1UnitTest[String](_PropPipeLiteralUpper))

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

    // Comment tests
    test(Property1UnitTest[String](_PropCommentInvisible))
    test(Property1UnitTest[(String, String)](_PropCommentBodyIrrelevant))
    test(_TestCommentBasic)
    test(_TestCommentWithTrim)
    test(_TestCommentBeforeExtends)
    test(_TestCommentInsideIf)
    test(_TestCommentInsideLoop)
    test(_TestCommentInsideElse)
    test(_TestCommentAsOnlyBlockContent)
    test(_TestCommentAdjacent)
    test(_TestCommentBetweenLiterals)
    test(_TestCommentMinimal)
    test(_TestCommentWithQuotes)

    // Raw block tests
    test(Property1UnitTest[String](_PropRawBlockContentIdentity))
    test(Property1UnitTest[String](_PropRawBlockSurroundingLiteralsPreserved))
    test(_TestRawBasic)
    test(_TestRawWithTrim)
    test(_TestRawWithTemplateDelimiters)
    test(_TestRawInsideIf)
    test(_TestRawInsideLoop)
    test(_TestRawInsideElse)
    test(_TestRawBeforeExtends)
    test(_TestRawAdjacent)
    test(_TestRawBetweenLiterals)
    test(_TestRawEmpty)
    test(_TestRawUnclosed)
    test(_TestRawMinimal)
    test(_TestRawWithBraces)

    // from_file test (Step 8)
    test(_TestFromFile)

    // HTML context state machine tests
    test(_TestContextText)
    test(_TestContextTag)
    test(_TestContextAttrDq)
    test(_TestContextAttrSq)
    test(_TestContextUnqAttrError)
    test(_TestContextComment)
    test(_TestContextScript)
    test(_TestContextStyle)
    test(_TestContextRcdata)
    test(_TestContextUrlAttr)
    test(_TestContextJsAttr)
    test(_TestContextCssAttr)
    test(_TestContextClone)
    test(_TestContextBranchConsistency)
    test(_TestContextCaseInsensitiveTags)
    test(_TestContextScriptWithAttrs)
    test(_TestContextClosingTag)
    test(_TestContextCaseInsensitiveClose)
    test(_TestContextCloseTagWhitespace)
    test(Property1UnitTest[String](_PropContextTextRoundtrip))

    // HTML escape function tests
    test(_TestEscapeHtmlText)
    test(_TestEscapeHtmlAttr)
    test(_TestEscapeUrl)
    test(_TestEscapeUrlPercentEncoding)
    test(_TestEscapeUrlNoFalsePositive)
    test(_TestEscapeJs)
    test(_TestEscapeJsControlChars)
    test(_TestEscapeCss)
    test(_TestEscapeCssFormat)
    test(_TestEscapeComment)
    test(_TestEscapeRcdata)
    test(_TestEscapeErrorContext)
    test(Property1UnitTest[String](_PropEscapeHtmlNoUnescapedChars))
    test(Property1UnitTest[String](_PropEscapeRcdataNoUnescapedChars))

    // RenderableValue tests
    test(_TestHtmlEscapingRenderer)
    test(_TestNoEscapeRenderer)

    // HtmlTemplate tests
    test(_TestHtmlTemplateBasicEscaping)
    test(_TestHtmlTemplateAttrEscaping)
    test(_TestHtmlTemplateUrlEscaping)
    test(_TestHtmlTemplateUnescaped)
    test(_TestHtmlTemplateUnescapedConvenience)
    test(_TestHtmlTemplatePipeEscaping)
    test(_TestHtmlTemplateIfBranchConsistency)
    test(_TestHtmlTemplateLoopPreservesContext)
    test(_TestHtmlTemplateErrorInTagName)
    test(_TestHtmlTemplateErrorUnquotedAttr)
    test(_TestHtmlTemplateScriptContext)
    test(_TestHtmlTemplateCommentContext)
    test(_TestHtmlTemplateCssAttrContext)
    test(_TestHtmlTemplateRcdataContext)
    test(Property1UnitTest[String](_PropHtmlTemplateEscapesInText))


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
        // Reject "raw" exactly (reserved keyword for raw blocks)
        if s == "raw" then return (consume s, false) end
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

  fun pipe_source_string(): Generator[String] =>
    """
    Generates printable ASCII strings excluding `"`, length 0-50, for use
    as string literal pipe sources in `{{ "..." | filter }}`. Same character
    set as `filter_arg_string` (printable ASCII minus double quote).
    """
    filter_arg_string()

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

  fun comment_body(): Generator[String] =>
    """
    Generates printable ASCII strings 0-30 chars, excluding `}` so that `}}`
    can never appear inside the comment body.
    """
    let chars: String val =
      " !\"#$%&'()*+,-./"
      + "0123456789:;<=>?@"
      + "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`"
      + "abcdefghijklmnopqrstuvwxyz{|~"
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

  fun raw_body(): Generator[String] =>
    """
    Generates printable ASCII strings 0-30 chars, excluding `{` so that `{{`
    can never form inside the generated content and accidentally create
    `{{end}}`.
    """
    let chars: String val =
      " !\"#$%&'()*+,-./"
      + "0123456789:;<=>?@"
      + "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`"
      + "abcdefghijklmnopqrstuvwxyz|}~"
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
      match pipe.source
      | let src: _PropNode =>
        h.assert_eq[String]("foo", src.name)
        h.assert_eq[USize](0, src.props.size())
      else h.fail("expected _PropNode source"); error
      end
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
      match pipe.source
      | let src: _PropNode =>
        h.assert_eq[String]("name", src.name)
      else h.fail("expected _PropNode source"); error
      end
      h.assert_eq[USize](1, pipe.filters.size())
      h.assert_eq[String]("upper", pipe.filters(0)?.name)
      h.assert_eq[USize](0, pipe.filters(0)?.args.size())
    else h.fail("expected _PipeNode for name | upper"); error
    end

    // 'name | default("x")' → single 1-arg filter with string literal
    match _StmtParser.parse("name | default(\"x\")")?
    | let pipe: _PipeNode =>
      match pipe.source
      | let src: _PropNode =>
        h.assert_eq[String]("name", src.name)
      else h.fail("expected _PropNode source"); error
      end
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
      match pipe.source
      | let src: _PropNode =>
        h.assert_eq[String]("a", src.name)
        h.assert_eq[USize](1, src.props.size())
        h.assert_eq[String]("b", src.props(0)?)
      else h.fail("expected _PropNode source"); error
      end
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
// String literal pipe source tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestRenderPipeLiteralSource is UnitTest
  fun name(): String => "Render: string literal pipe source"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("HELLO",
      Template.parse("{{ \"hello\" | upper }}")?.render(TemplateValues)?)


class \nodoc\ iso _TestRenderPipeLiteralChain is UnitTest
  fun name(): String => "Render: string literal pipe chain"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("HELLO",
      Template.parse("{{ \"  hello  \" | trim | upper }}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRenderPipeLiteralDefault is UnitTest
  fun name(): String => "Render: string literal pipe default"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("fallback",
      Template.parse("{{ \"\" | default(\"fallback\") }}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRenderPipeLiteralReplace is UnitTest
  fun name(): String => "Render: string literal pipe replace"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("hello pony",
      Template.parse(
        "{{ \"hello world\" | replace(\"world\", \"pony\") }}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestParserPipeLiteralSource is UnitTest
  fun name(): String => "Parser: pipe literal source is String"

  fun apply(h: TestHelper)? =>
    match _StmtParser.parse("\"hello\" | upper")?
    | let pipe: _PipeNode =>
      match pipe.source
      | let s: String =>
        h.assert_eq[String]("hello", s)
      else h.fail("expected String source"); error
      end
      h.assert_eq[USize](1, pipe.filters.size())
      h.assert_eq[String]("upper", pipe.filters(0)?.name)
    else h.fail("expected _PipeNode"); error
    end


class \nodoc\ iso _PropPipeLiteralUpper is Property1[String]
  """
  For any generated string, `{{ "<string>" | upper }}` equals
  `string.upper()`.
  """
  fun name(): String => "Prop: string literal pipe upper"

  fun gen(): Generator[String] =>
    // Printable ASCII 0x20-0x7E excluding double quote (0x22), matching the
    // string_char rule in the parser grammar.
    _Generators.pipe_source_string()

  fun property(sample: String, h: PropertyHelper)? =>
    let source = recover val
      "{{ \"" + sample + "\" | upper }}"
    end
    let result = Template.parse(source)?.render(TemplateValues)?
    h.assert_eq[String](sample.upper(), result)


// ---------------------------------------------------------------------------
// Comment tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropCommentInvisible is Property1[String]
  """
  For any generated comment body, `{{! body }}` renders as empty string.
  """
  fun name(): String => "Prop: comment renders as empty string"

  fun gen(): Generator[String] =>
    _Generators.comment_body()

  fun property(sample: String, h: PropertyHelper)? =>
    let source = recover val "{{!" + sample + "}}" end
    h.assert_eq[String]("",
      Template.parse(source)?.render(TemplateValues)?)


class \nodoc\ iso _PropCommentBodyIrrelevant
  is Property1[(String, String)]
  """
  Two templates differing only in comment body render identically, proving
  comment content is truly discarded.
  """
  fun name(): String => "Prop: comment body is irrelevant to output"

  fun gen(): Generator[(String, String)] =>
    Generators.zip2[String, String](
      _Generators.comment_body(),
      _Generators.comment_body())

  fun property(sample: (String, String), h: PropertyHelper)? =>
    (let body1, let body2) = sample
    let source1 = recover val "before{{!" + body1 + "}}after" end
    let source2 = recover val "before{{!" + body2 + "}}after" end
    let r1 = Template.parse(source1)?.render(TemplateValues)?
    let r2 = Template.parse(source2)?.render(TemplateValues)?
    h.assert_eq[String](r1, r2)


class \nodoc\ iso _TestCommentBasic is UnitTest
  fun name(): String => "Comment: basic comment is invisible"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("hello  world",
      Template.parse("hello {{! ignored }} world")?.render(TemplateValues)?)


class \nodoc\ iso _TestCommentWithTrim is UnitTest
  fun name(): String => "Comment: trim markers with comments"

  fun apply(h: TestHelper)? =>
    // Right-trim strips leading whitespace from following literal
    h.assert_eq[String]("helloworld",
      Template.parse("hello{{! comment -}}   world")?
        .render(TemplateValues)?)
    // Left-trim strips trailing whitespace from preceding literal
    h.assert_eq[String]("helloworld",
      Template.parse("hello   {{-! comment }}world")?
        .render(TemplateValues)?)
    // Both trims
    h.assert_eq[String]("helloworld",
      Template.parse("hello   {{-! comment -}}   world")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestCommentBeforeExtends is UnitTest
  fun name(): String => "Comment: comment before extends is transparent"

  fun apply(h: TestHelper)? =>
    let partials = recover val
      let p = Map[String, String]
      p("base") = "BASE:{{ block main }}default{{ end }}"
      p
    end
    let ctx = TemplateContext(where partials' = partials)
    // Comment before extends — should work fine
    let child = "{{! layout comment }}{{ extends \"base\" }}{{ block main }}override{{ end }}"
    h.assert_eq[String]("BASE:override",
      Template.parse(child, ctx)?.render(TemplateValues)?)
    // Extends after a non-comment block should still fail
    h.assert_error({()? =>
      Template.parse(
        "{{ x }}{{ extends \"base\" }}{{ block main }}override{{ end }}",
        ctx)?
    })


class \nodoc\ iso _TestCommentInsideIf is UnitTest
  fun name(): String => "Comment: inside if body"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("show") = "yes"
    h.assert_eq[String]("visible",
      Template.parse("{{ if show }}{{! hidden note }}visible{{ end }}")?
        .render(values)?)


class \nodoc\ iso _TestCommentInsideLoop is UnitTest
  fun name(): String => "Comment: inside loop body"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("items") = TemplateValue(
      [TemplateValue("a"); TemplateValue("b")])
    h.assert_eq[String]("ab",
      Template.parse(
        "{{ for x in items }}{{! loop comment }}{{ x }}{{ end }}")?
        .render(values)?)


class \nodoc\ iso _TestCommentInsideElse is UnitTest
  fun name(): String => "Comment: inside else branch"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("fallback",
      Template.parse(
        "{{ if missing }}yes{{ else }}{{! else comment }}fallback{{ end }}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestCommentAsOnlyBlockContent is UnitTest
  fun name(): String => "Comment: as sole content of if/loop body"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("show") = "yes"
    // Comment as only content of if body produces empty body
    h.assert_eq[String]("",
      Template.parse("{{ if show }}{{! only a comment }}{{ end }}")?
        .render(values)?)
    // Comment as only content of loop body
    values("items") = TemplateValue(
      [TemplateValue("a"); TemplateValue("b")])
    h.assert_eq[String]("",
      Template.parse(
        "{{ for x in items }}{{! only a comment }}{{ end }}")?
        .render(values)?)


class \nodoc\ iso _TestCommentAdjacent is UnitTest
  fun name(): String => "Comment: multiple adjacent comments"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("ab",
      Template.parse("a{{! one }}{{! two }}{{! three }}b")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestCommentBetweenLiterals is UnitTest
  fun name(): String => "Comment: between literals produces concatenation"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("ab",
      Template.parse("a{{! comment }}b")?.render(TemplateValues)?)


class \nodoc\ iso _TestCommentMinimal is UnitTest
  fun name(): String => "Comment: minimal forms"

  fun apply(h: TestHelper)? =>
    // Just the exclamation mark, no body
    h.assert_eq[String]("",
      Template.parse("{{!}}")?.render(TemplateValues)?)
    // Exclamation mark with whitespace
    h.assert_eq[String]("",
      Template.parse("{{! }}")?.render(TemplateValues)?)


class \nodoc\ iso _TestCommentWithQuotes is UnitTest
  fun name(): String => "Comment: double quotes inside comment body"

  fun apply(h: TestHelper)? =>
    // A " inside a comment must not trigger quote-aware delimiter scanning
    h.assert_eq[String]("ab",
      Template.parse("a{{! she said \"hello\" }}b")?
        .render(TemplateValues)?)
    // Single unmatched quote
    h.assert_eq[String]("ab",
      Template.parse("a{{! it's a \" quote }}b")?
        .render(TemplateValues)?)
    // Single } inside comment (legal — only }} closes)
    h.assert_eq[String]("ab",
      Template.parse("a{{! single } brace }}b")?
        .render(TemplateValues)?)


// ---------------------------------------------------------------------------
// Raw block tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropRawBlockContentIdentity is Property1[String]
  """
  For any generated raw body, `{{raw}}<body>{{end}}` renders as `<body>`.
  """
  fun name(): String => "Prop: raw block content is identity"

  fun gen(): Generator[String] =>
    _Generators.raw_body()

  fun property(sample: String, h: PropertyHelper)? =>
    let source = recover val "{{raw}}" + sample + "{{end}}" end
    h.assert_eq[String](sample,
      Template.parse(source)?.render(TemplateValues)?)


class \nodoc\ iso _PropRawBlockSurroundingLiteralsPreserved
  is Property1[String]
  """
  Literals before and after a raw block are preserved in the output.
  """
  fun name(): String => "Prop: raw block preserves surrounding literals"

  fun gen(): Generator[String] =>
    _Generators.raw_body()

  fun property(sample: String, h: PropertyHelper)? =>
    let source = recover val "before{{raw}}" + sample + "{{end}}after" end
    let expected = recover val "before" + sample + "after" end
    h.assert_eq[String](expected,
      Template.parse(source)?.render(TemplateValues)?)


class \nodoc\ iso _TestRawBasic is UnitTest
  fun name(): String => "Raw: basic raw block passes through delimiters"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("{{ name }}",
      Template.parse("{{raw}}{{ name }}{{end}}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawWithTrim is UnitTest
  fun name(): String => "Raw: trim markers on raw/end tags"

  fun apply(h: TestHelper)? =>
    // External trim: left-trim on raw strips preceding whitespace
    h.assert_eq[String]("beforecontent after",
      Template.parse("before   {{- raw }}content{{end}} after")?
        .render(TemplateValues)?)
    // External trim: right-trim on end strips following whitespace
    h.assert_eq[String]("before contentafter",
      Template.parse("before {{raw}}content{{end -}}   after")?
        .render(TemplateValues)?)
    // Internal trim: right-trim on raw lstrips content
    h.assert_eq[String]("content",
      Template.parse("{{raw -}}   content{{end}}")?
        .render(TemplateValues)?)
    // Internal trim: left-trim on end rstrips content
    h.assert_eq[String]("content",
      Template.parse("{{raw}}content   {{- end}}")?
        .render(TemplateValues)?)
    // Both internal trims
    h.assert_eq[String]("content",
      Template.parse("{{raw -}}   content   {{- end}}")?
        .render(TemplateValues)?)
    // All four trims
    h.assert_eq[String]("content",
      Template.parse("   {{- raw -}}   content   {{- end -}}   ")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawWithTemplateDelimiters is UnitTest
  fun name(): String => "Raw: template syntax passes through literally"

  fun apply(h: TestHelper)? =>
    // Note: {{ end }} cannot appear inside raw content because it closes the
    // raw block. Other template syntax passes through fine.
    h.assert_eq[String]("{{ if flag }}yes{{ else }}no",
      Template.parse(
        "{{raw}}{{ if flag }}yes{{ else }}no{{end}}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawInsideIf is UnitTest
  fun name(): String => "Raw: raw block inside if body"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("show") = "yes"
    h.assert_eq[String]("{{ x }}",
      Template.parse(
        "{{ if show }}{{raw}}{{ x }}{{end}}{{ end }}")?
        .render(values)?)
    // When condition is false, raw content not rendered
    h.assert_eq[String]("",
      Template.parse(
        "{{ if show }}{{raw}}{{ x }}{{end}}{{ end }}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawInsideLoop is UnitTest
  fun name(): String => "Raw: raw block inside loop body"

  fun apply(h: TestHelper)? =>
    let values = TemplateValues
    values("items") = TemplateValue(
      [TemplateValue("a"); TemplateValue("b")])
    h.assert_eq[String]("{{ x }}{{ x }}",
      Template.parse(
        "{{ for item in items }}{{raw}}{{ x }}{{end}}{{ end }}")?
        .render(values)?)


class \nodoc\ iso _TestRawInsideElse is UnitTest
  fun name(): String => "Raw: raw block inside else branch"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("{{ fallback }}",
      Template.parse(
        "{{ if missing }}yes{{ else }}{{raw}}{{ fallback }}{{end}}{{ end }}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawBeforeExtends is UnitTest
  fun name(): String => "Raw: raw block before extends prevents extends"

  fun apply(h: TestHelper) =>
    h.assert_error({()? =>
      let partials = recover val
        let m = Map[String, String]
        m("base") = "base content"
        m
      end
      let ctx = TemplateContext(where partials' = partials)
      Template.parse(
        "{{raw}}literal{{end}}{{ extends \"base\" }}", ctx)?
    })


class \nodoc\ iso _TestRawAdjacent is UnitTest
  fun name(): String => "Raw: multiple adjacent raw blocks"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("{{ a }}{{ b }}",
      Template.parse(
        "{{raw}}{{ a }}{{end}}{{raw}}{{ b }}{{end}}")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawBetweenLiterals is UnitTest
  fun name(): String => "Raw: raw block between regular literals"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("before{{ x }}after",
      Template.parse("before{{raw}}{{ x }}{{end}}after")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawEmpty is UnitTest
  fun name(): String => "Raw: empty raw block"

  fun apply(h: TestHelper)? =>
    h.assert_eq[String]("beforeafter",
      Template.parse("before{{raw}}{{end}}after")?
        .render(TemplateValues)?)


class \nodoc\ iso _TestRawUnclosed is UnitTest
  fun name(): String => "Raw: unclosed raw block is a parse error"

  fun apply(h: TestHelper) =>
    h.assert_error({()? =>
      Template.parse("{{raw}}content without end")?
    })
    // Missing end entirely
    h.assert_error({()? =>
      Template.parse("{{raw}}{{ stuff }}")?
    })


class \nodoc\ iso _TestRawMinimal is UnitTest
  fun name(): String => "Raw: minimal forms with and without whitespace"

  fun apply(h: TestHelper)? =>
    // No whitespace
    h.assert_eq[String]("x",
      Template.parse("{{raw}}x{{end}}")?.render(TemplateValues)?)
    // Whitespace in tags
    h.assert_eq[String]("x",
      Template.parse("{{ raw }}x{{ end }}")?.render(TemplateValues)?)
    // Whitespace in raw tag only
    h.assert_eq[String]("x",
      Template.parse("{{ raw }}x{{end}}")?.render(TemplateValues)?)


class \nodoc\ iso _TestRawWithBraces is UnitTest
  fun name(): String => "Raw: content with single braces and non-end blocks"

  fun apply(h: TestHelper)? =>
    // Single braces pass through
    h.assert_eq[String]("a{b}c",
      Template.parse("{{raw}}a{b}c{{end}}")?.render(TemplateValues)?)
    // Non-end {{ }} blocks inside raw are literal
    h.assert_eq[String]("{{ if x }}",
      Template.parse("{{raw}}{{ if x }}{{end}}")?.render(TemplateValues)?)
    // {{ for ... }} inside raw is literal
    h.assert_eq[String]("{{ for i in items }}{{ i }}",
      Template.parse("{{raw}}{{ for i in items }}{{ i }}{{end}}")?
        .render(TemplateValues)?)


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


// ---------------------------------------------------------------------------
// HTML context state machine tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestContextText is UnitTest
  fun name(): String => "HtmlContext: text is default state"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    h.assert_is[HtmlContext](CtxText, t.context())
    t.feed("hello world")
    h.assert_is[HtmlContext](CtxText, t.context())

class \nodoc\ iso _TestContextTag is UnitTest
  fun name(): String => "HtmlContext: inside tag is error"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<div")
    h.assert_is[HtmlContext](CtxError, t.context())

class \nodoc\ iso _TestContextAttrDq is UnitTest
  fun name(): String => "HtmlContext: double-quoted attr value"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<div class=\"")
    h.assert_is[HtmlContext](CtxHtmlAttr, t.context())
    t.feed("foo\"")
    // After closing quote, back in tag
    h.assert_is[HtmlContext](CtxError, t.context())

class \nodoc\ iso _TestContextAttrSq is UnitTest
  fun name(): String => "HtmlContext: single-quoted attr value"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<div class='")
    h.assert_is[HtmlContext](CtxHtmlAttr, t.context())

class \nodoc\ iso _TestContextUnqAttrError is UnitTest
  fun name(): String => "HtmlContext: unquoted attr value is error"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<div class=")
    // Before attr val, still error
    h.assert_is[HtmlContext](CtxError, t.context())
    t.feed("x")
    // In unquoted attr val — error context
    h.assert_is[HtmlContext](CtxError, t.context())

class \nodoc\ iso _TestContextComment is UnitTest
  fun name(): String => "HtmlContext: HTML comment"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<!--")
    t.feed_close_tag("<!--")
    h.assert_is[HtmlContext](CtxComment, t.context())
    t.feed(" comment text -->")
    t.feed_close_tag(" comment text -->")
    h.assert_is[HtmlContext](CtxText, t.context())

class \nodoc\ iso _TestContextScript is UnitTest
  fun name(): String => "HtmlContext: script tag"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<script>")
    h.assert_is[HtmlContext](CtxScript, t.context())
    t.feed("var x = 1;")
    t.feed_close_tag("var x = 1;")
    h.assert_is[HtmlContext](CtxScript, t.context())
    let closing = "</script>"
    t.feed(closing)
    t.feed_close_tag(closing)
    h.assert_is[HtmlContext](CtxText, t.context())

class \nodoc\ iso _TestContextStyle is UnitTest
  fun name(): String => "HtmlContext: style tag"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<style>")
    h.assert_is[HtmlContext](CtxStyle, t.context())
    let closing = "</style>"
    t.feed(closing)
    t.feed_close_tag(closing)
    h.assert_is[HtmlContext](CtxText, t.context())

class \nodoc\ iso _TestContextRcdata is UnitTest
  fun name(): String => "HtmlContext: title/textarea RCDATA"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<title>")
    h.assert_is[HtmlContext](CtxRcdata, t.context())
    let closing = "</title>"
    t.feed(closing)
    t.feed_close_tag(closing)
    h.assert_is[HtmlContext](CtxText, t.context())

class \nodoc\ iso _TestContextUrlAttr is UnitTest
  fun name(): String => "HtmlContext: URL attributes"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<a href=\"")
    h.assert_is[HtmlContext](CtxUrlAttr, t.context())

class \nodoc\ iso _TestContextJsAttr is UnitTest
  fun name(): String => "HtmlContext: JS event attributes"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<div onclick=\"")
    h.assert_is[HtmlContext](CtxJsAttr, t.context())

class \nodoc\ iso _TestContextCssAttr is UnitTest
  fun name(): String => "HtmlContext: style attribute"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<div style=\"")
    h.assert_is[HtmlContext](CtxCssAttr, t.context())

class \nodoc\ iso _TestContextClone is UnitTest
  fun name(): String => "HtmlContext: clone preserves state"

  fun apply(h: TestHelper) =>
    let t: _HtmlContextTracker ref = _HtmlContextTracker
    t.feed("<div class=\"")
    let t2 = t.clone()
    h.assert_true(t.eq(t2))
    t.feed("foo\"")
    // Original advanced, clone stayed
    h.assert_false(t.eq(t2))
    h.assert_is[HtmlContext](CtxHtmlAttr, t2.context())

class \nodoc\ iso _TestContextBranchConsistency is UnitTest
  fun name(): String => "HtmlContext: branch consistency check"

  fun apply(h: TestHelper) =>
    // Both branches end in text — consistent
    let t1: _HtmlContextTracker ref = _HtmlContextTracker
    t1.feed("<p>")
    let t2 = t1.clone()
    t1.feed("hello")
    t2.feed("world")
    h.assert_true(t1.eq(t2))

    // One branch opens a tag — inconsistent
    let t3: _HtmlContextTracker ref = _HtmlContextTracker
    t3.feed("<p>")
    let t4 = t3.clone()
    t3.feed("<div>")
    t4.feed("<a href=\"")
    h.assert_false(t3.eq(t4))

class \nodoc\ iso _TestContextCaseInsensitiveTags is UnitTest
  fun name(): String => "HtmlContext: case-insensitive tag matching"

  fun apply(h: TestHelper) =>
    let t1 = _HtmlContextTracker
    t1.feed("<SCRIPT>")
    h.assert_is[HtmlContext](CtxScript, t1.context())

    let t2 = _HtmlContextTracker
    t2.feed("<Script>")
    h.assert_is[HtmlContext](CtxScript, t2.context())

    let t3 = _HtmlContextTracker
    t3.feed("<STYLE>")
    h.assert_is[HtmlContext](CtxStyle, t3.context())

    let t4 = _HtmlContextTracker
    t4.feed("<TITLE>")
    h.assert_is[HtmlContext](CtxRcdata, t4.context())

class \nodoc\ iso _TestContextScriptWithAttrs is UnitTest
  fun name(): String => "HtmlContext: script tag with attributes"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<script type=\"text/javascript\">")
    h.assert_is[HtmlContext](CtxScript, t.context())

class \nodoc\ iso _TestContextClosingTag is UnitTest
  fun name(): String => "HtmlContext: closing tag returns to text"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<div>hello</div>")
    h.assert_is[HtmlContext](CtxText, t.context())

class \nodoc\ iso _TestContextCaseInsensitiveClose is UnitTest
  fun name(): String => "HtmlContext: case-insensitive closing tags"

  fun apply(h: TestHelper) =>
    let t = _HtmlContextTracker
    t.feed("<script>")
    h.assert_is[HtmlContext](CtxScript, t.context())
    let closing = "</SCRIPT>"
    t.feed(closing)
    t.feed_close_tag(closing)
    h.assert_is[HtmlContext](CtxText, t.context())

class \nodoc\ iso _TestContextCloseTagWhitespace is UnitTest
  fun name(): String => "HtmlContext: closing tag with whitespace before >"

  fun apply(h: TestHelper) =>
    // </script > is a valid closing tag per the HTML spec
    let t1 = _HtmlContextTracker
    t1.feed("<script>")
    let closing1 = "</script >"
    t1.feed(closing1)
    t1.feed_close_tag(closing1)
    h.assert_is[HtmlContext](CtxText, t1.context())

    // Multiple whitespace chars
    let t2 = _HtmlContextTracker
    t2.feed("<style>")
    let closing2 = "</style\t\n >"
    t2.feed(closing2)
    t2.feed_close_tag(closing2)
    h.assert_is[HtmlContext](CtxText, t2.context())

    // No whitespace still works
    let t3 = _HtmlContextTracker
    t3.feed("<script>")
    let closing3 = "</script>"
    t3.feed(closing3)
    t3.feed_close_tag(closing3)
    h.assert_is[HtmlContext](CtxText, t3.context())

class \nodoc\ iso _PropContextTextRoundtrip is Property1[String]
  fun name(): String => "HtmlContext: text without < stays in text state"

  fun gen(): Generator[String] =>
    // Generate strings of lowercase letters — no < to stay in text state
    Generators.ascii(0, 50)
      .filter({(s: String): (String, Bool) =>
        var ok = true
        for c in s.values() do
          if c == '<' then ok = false; break end
        end
        (s, ok)
      })

  fun property(arg1: String, h: PropertyHelper) =>
    let t = _HtmlContextTracker
    t.feed(arg1)
    h.assert_is[HtmlContext](CtxText, t.context())


// ---------------------------------------------------------------------------
// HTML escape function tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestEscapeHtmlText is UnitTest
  fun name(): String => "HtmlEscape: text escapes all five chars"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("&amp;&lt;&gt;&#34;&#39;",
      _HtmlEscape.html_text("&<>\"'"))
    h.assert_eq[String]("hello", _HtmlEscape.html_text("hello"))
    h.assert_eq[String]("", _HtmlEscape.html_text(""))
    h.assert_eq[String]("a&amp;b&lt;c", _HtmlEscape.html_text("a&b<c"))

class \nodoc\ iso _TestEscapeHtmlAttr is UnitTest
  fun name(): String => "HtmlEscape: attr uses same escaping as text"

  fun apply(h: TestHelper) =>
    h.assert_eq[String](_HtmlEscape.html_text("a<b"),
      _HtmlEscape.html_attr("a<b"))

class \nodoc\ iso _TestEscapeUrl is UnitTest
  fun name(): String => "HtmlEscape: URL filters dangerous schemes"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("#ZgotmplZ",
      _HtmlEscape.url_attr("javascript:alert(1)"))
    h.assert_eq[String]("#ZgotmplZ",
      _HtmlEscape.url_attr("vbscript:run"))
    h.assert_eq[String]("#ZgotmplZ",
      _HtmlEscape.url_attr("data:text/html,<script>"))
    // Safe URLs pass through (with encoding)
    let result = _HtmlEscape.url_attr("https://example.com")
    h.assert_true(result.contains("example.com"))
    h.assert_false(result.contains("#ZgotmplZ"))

class \nodoc\ iso _TestEscapeJs is UnitTest
  fun name(): String => "HtmlEscape: JS escapes special chars"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("\\\\", _HtmlEscape.js_string("\\"))
    h.assert_eq[String]("\\'", _HtmlEscape.js_string("'"))
    h.assert_eq[String]("\\\"", _HtmlEscape.js_string("\""))
    h.assert_eq[String]("\\x3c", _HtmlEscape.js_string("<"))
    h.assert_eq[String]("\\x3e", _HtmlEscape.js_string(">"))
    h.assert_eq[String]("\\x26", _HtmlEscape.js_string("&"))
    h.assert_eq[String]("hello", _HtmlEscape.js_string("hello"))

class \nodoc\ iso _TestEscapeCss is UnitTest
  fun name(): String => "HtmlEscape: CSS escapes unsafe chars"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("hello", _HtmlEscape.css_value("hello"))
    // Colon should be escaped
    let result = _HtmlEscape.css_value(":")
    h.assert_false(result == ":")

class \nodoc\ iso _TestEscapeComment is UnitTest
  fun name(): String => "HtmlEscape: comment strips dashes"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("ab", _HtmlEscape.comment("a--b"))
    h.assert_eq[String]("hello", _HtmlEscape.comment("hello"))
    h.assert_eq[String]("", _HtmlEscape.comment("--"))

class \nodoc\ iso _TestEscapeRcdata is UnitTest
  fun name(): String => "HtmlEscape: RCDATA escapes < and &"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("&amp;&lt;", _HtmlEscape.rcdata("&<"))
    h.assert_eq[String]("hello", _HtmlEscape.rcdata("hello"))
    h.assert_eq[String]("a&amp;b&lt;c>d", _HtmlEscape.rcdata("a&b<c>d"))

class \nodoc\ iso _TestEscapeUrlPercentEncoding is UnitTest
  fun name(): String => "HtmlEscape: URL percent-encodes special chars"

  fun apply(h: TestHelper) =>
    // Space should be percent-encoded, result then HTML-entity-encoded
    let result = _HtmlEscape.url_attr("hello world")
    h.assert_true(result.contains("%20"))
    h.assert_false(result.contains(" "))

class \nodoc\ iso _TestEscapeUrlNoFalsePositive is UnitTest
  fun name(): String => "HtmlEscape: URL allows data: in path/query"

  fun apply(h: TestHelper) =>
    // "data:" in a query parameter should not be blocked
    let result = _HtmlEscape.url_attr("https://example.com/?q=data:foo")
    h.assert_false(result == "#ZgotmplZ")

class \nodoc\ iso _TestEscapeJsControlChars is UnitTest
  fun name(): String => "HtmlEscape: JS escapes control and high bytes"

  fun apply(h: TestHelper) =>
    // Control char (0x01) should be hex-escaped
    let ctrl = recover val String.>push(0x01) end
    let result = _HtmlEscape.js_string(ctrl)
    h.assert_eq[String]("\\x01", result)
    // High byte (0x80) should be hex-escaped
    let high = recover val String.>push(0x80) end
    let result2 = _HtmlEscape.js_string(high)
    h.assert_eq[String]("\\x80", result2)

class \nodoc\ iso _TestEscapeCssFormat is UnitTest
  fun name(): String => "HtmlEscape: CSS escape format is \\HH<space>"

  fun apply(h: TestHelper) =>
    // Colon (0x3a) should be escaped as \3a followed by a space
    h.assert_eq[String]("\\3a ", _HtmlEscape.css_value(":"))
    // Semicolon (0x3b) should be escaped as \3b followed by a space
    h.assert_eq[String]("\\3b ", _HtmlEscape.css_value(";"))

class \nodoc\ iso _TestEscapeErrorContext is UnitTest
  fun name(): String => "HtmlEscape: error context returns raw string"

  fun apply(h: TestHelper) =>
    let raw = "<script>alert('xss')</script>"
    h.assert_eq[String](raw, _HtmlEscape.for_context(CtxError, raw))

class \nodoc\ iso _PropEscapeHtmlNoUnescapedChars is Property1[String]
  fun name(): String =>
    "HtmlEscape: html_text output never contains raw & < > \" '"

  fun gen(): Generator[String] =>
    Generators.ascii(0, 100)

  fun property(arg1: String, h: PropertyHelper) =>
    let escaped = _HtmlEscape.html_text(arg1)
    // Check that no raw special chars remain (they should all be entities)
    var i: USize = 0
    while i < escaped.size() do
      try
        let c = escaped(i)?
        match c
        | '<' => h.fail("unescaped < at position " + i.string())
        | '>' => h.fail("unescaped > at position " + i.string())
        | '"' => h.fail("unescaped \" at position " + i.string())
        | '\'' => h.fail("unescaped ' at position " + i.string())
        | '&' =>
          // & is OK only if it starts an entity
          if not _starts_entity(escaped, i) then
            h.fail("bare & at position " + i.string())
          end
        end
      end
      i = i + 1
    end

  fun _starts_entity(s: String, pos: USize): Bool =>
    // Check for &amp; &lt; &gt; &#34; &#39;
    if s.substring(pos.isize(), (pos + 5).isize()) == "&amp;" then
      return true
    end
    if s.substring(pos.isize(), (pos + 4).isize()) == "&lt;" then
      return true
    end
    if s.substring(pos.isize(), (pos + 4).isize()) == "&gt;" then
      return true
    end
    if s.substring(pos.isize(), (pos + 5).isize()) == "&#34;" then
      return true
    end
    if s.substring(pos.isize(), (pos + 5).isize()) == "&#39;" then
      return true
    end
    false

class \nodoc\ iso _PropEscapeRcdataNoUnescapedChars is Property1[String]
  fun name(): String =>
    "HtmlEscape: rcdata output never contains raw < or &"

  fun gen(): Generator[String] =>
    Generators.ascii(0, 100)

  fun property(arg1: String, h: PropertyHelper) =>
    let escaped = _HtmlEscape.rcdata(arg1)
    var i: USize = 0
    while i < escaped.size() do
      try
        let c = escaped(i)?
        match c
        | '<' => h.fail("unescaped < at position " + i.string())
        | '&' =>
          if not _starts_entity(escaped, i) then
            h.fail("bare & at position " + i.string())
          end
        end
      end
      i = i + 1
    end

  fun _starts_entity(s: String, pos: USize): Bool =>
    if s.substring(pos.isize(), (pos + 5).isize()) == "&amp;" then
      return true
    end
    if s.substring(pos.isize(), (pos + 4).isize()) == "&lt;" then
      return true
    end
    false


// ---------------------------------------------------------------------------
// RenderableValue tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestHtmlEscapingRenderer is UnitTest
  fun name(): String => "RenderableValue: HtmlEscapingRenderer escapes"

  fun apply(h: TestHelper) =>
    let result = _HtmlEscapingRenderer.render(CtxText, "<script>")
    h.assert_eq[String]("&lt;script&gt;", result)

class \nodoc\ iso _TestNoEscapeRenderer is UnitTest
  fun name(): String => "RenderableValue: NoEscapeRenderer passes through"

  fun apply(h: TestHelper) =>
    let result = _NoEscapeRenderer.render(CtxText, "<script>")
    h.assert_eq[String]("<script>", result)


// ---------------------------------------------------------------------------
// HtmlTemplate tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestHtmlTemplateBasicEscaping is UnitTest
  fun name(): String => "HtmlTemplate: escapes variables in text context"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<p>{{ name }}</p>")?
      let v = TemplateValues
      v("name") = "<script>alert('xss')</script>"
      let result = t.render(v)?
      h.assert_eq[String](
        "<p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>", result)
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateAttrEscaping is UnitTest
  fun name(): String => "HtmlTemplate: escapes in attribute context"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<div class=\"{{ cls }}\">hello</div>")?
      let v = TemplateValues
      v("cls") = "a\"b&c"
      let result = t.render(v)?
      h.assert_eq[String](
        "<div class=\"a&#34;b&amp;c\">hello</div>", result)
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateUrlEscaping is UnitTest
  fun name(): String => "HtmlTemplate: escapes in URL attribute context"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<a href=\"{{ url }}\">link</a>")?
      let v = TemplateValues
      v("url") = "javascript:alert(1)"
      let result = t.render(v)?
      // Dangerous scheme should be replaced with #ZgotmplZ
      h.assert_true(result.contains("#ZgotmplZ"))
      h.assert_false(result.contains("javascript"))
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateUnescaped is UnitTest
  fun name(): String => "HtmlTemplate: unescaped values bypass escaping"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<p>{{ content }}</p>")?
      let v = TemplateValues
      v("content") = TemplateValue.unescaped("<em>bold</em>")
      let result = t.render(v)?
      h.assert_eq[String]("<p><em>bold</em></p>", result)
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateUnescapedConvenience is UnitTest
  fun name(): String =>
    "HtmlTemplate: TemplateValues.unescaped convenience method"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<p>{{ content }}</p>")?
      let v = TemplateValues
      v.unescaped("content", "<em>bold</em>")
      let result = t.render(v)?
      h.assert_eq[String]("<p><em>bold</em></p>", result)
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplatePipeEscaping is UnitTest
  fun name(): String => "HtmlTemplate: pipe results are always escaped"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<p>{{ name | upper }}</p>")?
      let v = TemplateValues
      v("name") = "<b>hi</b>"
      let result = t.render(v)?
      // Even after upper filter, output should be escaped
      h.assert_true(result.contains("&lt;"))
      h.assert_false(result.contains("<b>") or result.contains("<B>"))
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateIfBranchConsistency is UnitTest
  fun name(): String =>
    "HtmlTemplate: rejects inconsistent if/else branches"

  fun apply(h: TestHelper) =>
    // If-body opens a tag, else-body doesn't — inconsistent
    try
      HtmlTemplate.parse(
        "{{ if x }}<div class=\"{{ else }}hello{{ end }}")?
      h.fail("should have errored")
    end

class \nodoc\ iso _TestHtmlTemplateLoopPreservesContext is UnitTest
  fun name(): String => "HtmlTemplate: rejects loop that changes context"

  fun apply(h: TestHelper) =>
    // Loop body opens a tag without closing it
    try
      HtmlTemplate.parse("{{ for x in items }}<div{{ end }}")?
      h.fail("should have errored")
    end

class \nodoc\ iso _TestHtmlTemplateErrorInTagName is UnitTest
  fun name(): String => "HtmlTemplate: rejects variable in tag name"

  fun apply(h: TestHelper) =>
    try
      HtmlTemplate.parse("<{{ tag }}>hello</div>")?
      h.fail("should have errored")
    end

class \nodoc\ iso _TestHtmlTemplateErrorUnquotedAttr is UnitTest
  fun name(): String => "HtmlTemplate: rejects variable in unquoted attr"

  fun apply(h: TestHelper) =>
    try
      HtmlTemplate.parse("<div class={{ cls }}>hello</div>")?
      h.fail("should have errored")
    end

class \nodoc\ iso _TestHtmlTemplateScriptContext is UnitTest
  fun name(): String => "HtmlTemplate: JS-escapes in script context"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse(
        "<script>var x = \"{{ val }}\";</script>")?
      let v = TemplateValues
      v("val") = "a\"b"
      let result = t.render(v)?
      // Should use JS escaping, not HTML escaping
      h.assert_true(result.contains("\\\""))
      h.assert_false(result.contains("&#34;"))
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateCommentContext is UnitTest
  fun name(): String => "HtmlTemplate: strips dashes in comment context"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<!-- {{ note }} -->")?
      let v = TemplateValues
      v("note") = "a--b"
      let result = t.render(v)?
      // Should strip -- sequences
      h.assert_true(result.contains("ab"))
      h.assert_false(result.contains("a--b"))
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateCssAttrContext is UnitTest
  fun name(): String => "HtmlTemplate: CSS-escapes in style attribute"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<div style=\"color: {{ color }}\">x</div>")?
      let v = TemplateValues
      v("color") = "red;} body{background:url(evil)}"
      let result = t.render(v)?
      // CSS escaping should prevent breaking out of the property value
      h.assert_false(result.contains("}"))
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _TestHtmlTemplateRcdataContext is UnitTest
  fun name(): String => "HtmlTemplate: RCDATA-escapes in title element"

  fun apply(h: TestHelper) =>
    try
      let t = HtmlTemplate.parse("<title>{{ page_title }}</title>")?
      let v = TemplateValues
      v("page_title") = "A & B <script>"
      let result = t.render(v)?
      // RCDATA escaping: & and < are escaped, > left as-is for RCDATA
      h.assert_true(result.contains("&amp;"))
      h.assert_true(result.contains("&lt;"))
      h.assert_false(result.contains("<script>"))
    else
      h.fail("unexpected error")
    end

class \nodoc\ iso _PropHtmlTemplateEscapesInText is Property1[String]
  fun name(): String =>
    "HtmlTemplate: rendered text never contains raw < or >"

  fun gen(): Generator[String] =>
    Generators.ascii(1, 50)

  fun property(arg1: String, h: PropertyHelper) =>
    try
      let t = HtmlTemplate.parse("<p>{{ x }}</p>")?
      let v = TemplateValues
      v("x") = arg1
      let result = t.render(v)?
      // Strip the known wrapper to get just the escaped content
      let inner: String val = result.substring(3, result.size().isize() - 4)
      for c in inner.values() do
        match c
        | '<' => h.fail("unescaped < in output")
        | '>' => h.fail("unescaped > in output")
        end
      end
    end
