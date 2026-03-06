use "collections"

primitive _ParserCommon
  fun parse_template(
    source: String,
    ctx: TemplateContext val,
    include_stack: Array[String] box = []
  ): Array[_Part] box? =>
    match _check_extends(source)?
    | let base_name: String =>
      for name in include_stack.values() do
        if name == base_name then error end
      end
      let child_parts = _parse(source, ctx, include_stack)?
      let overrides = _extract_blocks(child_parts)?
      let base_source = ctx.partials(base_name)?
      let new_stack = Array[String](include_stack.size() + 1)
      for name in include_stack.values() do
        new_stack.push(name)
      end
      new_stack.push(base_name)
      _apply_overrides(parse_template(base_source, ctx, new_stack)?, overrides)
    else
      _parse(source, ctx, include_stack)?
    end

  fun _parse(
    source: String,
    ctx: TemplateContext val,
    include_stack: Array[String] box = []
  ): Array[_Part] box? =>
    var parts: Array[_Part] = []
    var current_parts = parts
    var open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _IfNotElse | _BlockNode), Array[_Part], Bool)] = []
    var first_stmt: Bool = true
    var trim_next_literal: Bool = false
    var prev_end: ISize = 0
    while prev_end < source.size().isize() do
      let scan_result = _scan_next_block(source, prev_end)?
      let block =
        match scan_result
        | let b: _BlockScan => b
        | None => break
        end

      if block.start_pos != prev_end then
        var literal = source.substring(prev_end.isize(), block.start_pos)
        if trim_next_literal then literal.lstrip() end
        if block.left_trim then literal.rstrip() end
        if literal.size() > 0 then
          current_parts.push((_Literal, consume literal))
        end
      end
      trim_next_literal = block.right_trim

      match block.kind
      | _CommentBlock =>
        prev_end = block.end_pos + 2
        continue
      | _RawBlock =>
        let raw_content = block.stmt_source
        if raw_content.size() > 0 then
          current_parts.push((_Literal, raw_content))
        end
        first_stmt = false
        prev_end = block.end_pos + 2
        continue
      end

      match _StmtParser.parse(block.stmt_source)?
      | _EndNode => current_parts = _parse_end(open, parts)?
      | _ElseNode => current_parts = _parse_else(open)?
      | let else_if: _ElseIfNode =>
        current_parts = _parse_elseif_stmt(open, else_if)?
      | let prop: _PropNode => current_parts.push(prop)
      | let pipe: _PipeNode =>
        current_parts.push(_resolve_pipe(pipe, ctx)?)
      | let if': _IfNode =>
        current_parts = Array[_Part]
        open.push((if', current_parts, false))
      | let ifnot: _IfNotNode =>
        current_parts = Array[_Part]
        open.push((ifnot, current_parts, false))
      | let loop: _LoopNode =>
        current_parts = Array[_Part]
        open.push((loop, current_parts, false))
      | let inc: _IncludeNode =>
        let partial_source = ctx.partials(inc.name)?
        for name in include_stack.values() do
          if name == inc.name then error end
        end
        let new_stack = Array[String](include_stack.size() + 1)
        for name in include_stack.values() do
          new_stack.push(name)
        end
        new_stack.push(inc.name)
        let inline_parts = _parse(partial_source, ctx, new_stack)?
        for p in inline_parts.values() do
          current_parts.push(p)
        end
      | let ext: _ExtendsNode =>
        if not first_stmt then error end
      | let blk: _BlockNode =>
        current_parts = Array[_Part]
        open.push((blk, current_parts, false))
      end

      first_stmt = false
      prev_end = block.end_pos + 2
    end

    if prev_end < source.size().isize() then
      var trailing = source.substring(prev_end.isize())
      if trim_next_literal then trailing.lstrip() end
      if trailing.size() > 0 then
        parts.push((_Literal, consume trailing))
      end
    end

    if open.size() > 0 then error end

    consume parts

  fun _resolve_pipe(
    pipe: _PipeNode,
    ctx: TemplateContext val
  ): _Pipe box? =>
    """
    Resolve a parsed `_PipeNode` into a renderable `_Pipe` by looking up
    each filter by name and validating its arity.
    """
    let resolved = Array[(AnyFilter, Array[_ResolvedArg] box)]
    for step in pipe.filters.values() do
      let filter = ctx.filters(step.name)?
      let args = Array[_ResolvedArg]
      for arg in step.args.values() do
        match arg
        | let s: String => args.push(s)
        | let p: _PropNode => args.push(p)
        end
      end
      // Validate arity
      match filter
      | let _: Filter val =>
        if args.size() != 0 then error end
      | let _: Filter2 val =>
        if args.size() != 1 then error end
      | let _: Filter3 val =>
        if args.size() != 2 then error end
      end
      resolved.push((filter, consume args))
    end
    _Pipe(pipe.source, consume resolved)

  fun _parse_end(
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _IfNotElse | _BlockNode), Array[_Part], Bool)],
    parts: Array[_Part]
  ): Array[_Part]? =>
    (let stmt, let body, _) = open.pop()?

    let node: _Part =
      match stmt
      | let if': _IfNode => _If(if'.value, body)
      | let ifnot: _IfNotNode => _IfNot(ifnot.value, body)
      | let ie: _IfElse => _If(ie.value, ie.if_body, body)
      | let ie: _IfNotElse => _IfNot(ie.value, ie.if_body, body)
      | let loop: _LoopNode => _Loop(loop.target, loop.source, body)
      | let blk: _BlockNode => _Block(blk.name, body)
      end

    // Auto-close elseif chain entries
    var current_node: _Part = node
    while open.size() > 0 do
      if open(open.size() - 1)?._3 then
        (let outer_stmt, let outer_body, _) = open.pop()?
        match outer_stmt
        | let ie: _IfElse =>
          outer_body.push(current_node)
          current_node = _If(ie.value, ie.if_body, outer_body)
        | let ie: _IfNotElse =>
          outer_body.push(current_node)
          current_node = _IfNot(ie.value, ie.if_body, outer_body)
        else
          // auto_close should only be set on _IfElse/_IfNotElse entries
          error
        end
      else
        break
      end
    end

    let next_current =
      if open.size() == 0 then parts
      else open(open.size() - 1)?._2
      end

    next_current.push(current_node)
    next_current

  fun _parse_else(
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _IfNotElse | _BlockNode), Array[_Part], Bool)]
  ): Array[_Part]? =>
    (let stmt, let if_body, _) = open.pop()?
    match stmt
    | let if': _IfNode =>
      let else_body = Array[_Part]
      open.push((_IfElse(if'.value, if_body), else_body, false))
      else_body
    | let ifnot: _IfNotNode =>
      let else_body = Array[_Part]
      open.push((_IfNotElse(ifnot.value, if_body), else_body, false))
      else_body
    else
      error // else only valid inside an if or ifnot block
    end

  fun _parse_elseif_stmt(
    open: Array[((_IfNode | _IfNotNode | _LoopNode | _IfElse | _IfNotElse | _BlockNode), Array[_Part], Bool)],
    else_if: _ElseIfNode
  ): Array[_Part]? =>
    (let stmt, let if_body, _) = open.pop()?
    match stmt
    | let if': _IfNode =>
      let else_body = Array[_Part]
      open.push((_IfElse(if'.value, if_body), else_body, true))
      let else_if_body = Array[_Part]
      open.push((_IfNode(else_if.value), else_if_body, false))
      else_if_body
    | let ifnot: _IfNotNode =>
      let else_body = Array[_Part]
      open.push((_IfNotElse(ifnot.value, if_body), else_body, true))
      let else_if_body = Array[_Part]
      open.push((_IfNode(else_if.value), else_if_body, false))
      else_if_body
    else
      error // elseif only valid inside an if or ifnot block
    end

  fun _check_extends(source: String): (String | None)? =>
    var search_from: ISize = 0
    while search_from < source.size().isize() do
      let scan_result' = _scan_next_block(source, search_from)?
      let block =
        match scan_result'
        | let b: _BlockScan => b
        | None => return None
        end

      match block.kind
      | _CommentBlock =>
        search_from = block.end_pos + 2
        continue
      | _RawBlock => return None
      end

      match _StmtParser.parse(block.stmt_source)?
      | let ext: _ExtendsNode => return ext.name
      else return None
      end
    end
    None

  fun _extract_blocks(
    parts: Array[_Part] box
  ): Map[String, Array[_Part] box]? =>
    let blocks = Map[String, Array[_Part] box]
    for part in parts.values() do
      match part
      | let blk: _Block box =>
        if blocks.contains(blk.name) then error end
        blocks(blk.name) = blk.body
      end
    end
    blocks

  fun _apply_overrides(
    parts: Array[_Part] box,
    overrides: Map[String, Array[_Part] box] box
  ): Array[_Part] box =>
    let result = Array[_Part]
    for part in parts.values() do
      match part
      | let blk: _Block box =>
        try
          let override_body = overrides(blk.name)?
          for p in override_body.values() do
            result.push(p)
          end
        else
          result.push(
            _Block(blk.name, _apply_overrides(blk.body, overrides)))
        end
      | let if': _If box =>
        let new_else: (Array[_Part] box | None) =
          match if'.else_body
          | let eb: Array[_Part] box =>
            _apply_overrides(eb, overrides)
          else None
          end
        result.push(
          _If(if'.value, _apply_overrides(if'.body, overrides), new_else))
      | let ifnot: _IfNot box =>
        let new_else: (Array[_Part] box | None) =
          match ifnot.else_body
          | let eb: Array[_Part] box =>
            _apply_overrides(eb, overrides)
          else None
          end
        result.push(
          _IfNot(
            ifnot.value,
            _apply_overrides(ifnot.body, overrides),
            new_else))
      | let loop: _Loop box =>
        result.push(
          _Loop(
            loop.target,
            loop.source,
            _apply_overrides(loop.body, overrides)))
      else
        result.push(part)
      end
    end
    result

  fun _scan_next_block(
    source: String,
    from: ISize
  ): (_BlockScan | None)? =>
    """
    Scan for the next `{{ }}` block starting from `from`. Returns a
    `_BlockScan` with the extracted statement content and metadata, or
    `None` if no more blocks are found (missing `{{` or `}}`).
    Errors on unclosed raw blocks.
    """
    let start_pos =
      try source.find("{{" where offset = from)?
      else return None
      end
    let is_comment = _is_comment_open(source, start_pos)
    if (not is_comment) and _is_raw_open(source, start_pos) then
      return _scan_raw_block(source, start_pos)?
    end
    // Comments don't use quote-aware scanning — a `"` inside a comment
    // body is literal text, not a string delimiter.
    let end_pos =
      try
        if is_comment then source.find("}}" where offset = start_pos + 2)?
        else _find_close_delim(source, start_pos + 2)?
        end
      else return None
      end

    let left_trim =
      try source((start_pos + 2).usize())? == '-'
      else false
      end
    let stmt_start: ISize =
      if left_trim then start_pos + 3 else start_pos + 2 end
    let right_trim =
      try
        (end_pos > stmt_start) and (source((end_pos - 1).usize())? == '-')
      else false
      end
    let stmt_end: ISize =
      if right_trim then end_pos - 1 else end_pos end

    _BlockScan(
      source.substring(stmt_start, stmt_end),
      start_pos,
      end_pos,
      left_trim,
      right_trim,
      if is_comment then _CommentBlock else _RegularBlock end)

  fun _is_comment_open(source: String, start_pos: ISize): Bool =>
    """
    Check whether the `{{ }}` block starting at `start_pos` is a comment.
    Peeks past the opening `{{` and optional `-` trim marker to see if the
    next non-whitespace character is `!`.
    """
    var i = (start_pos + 2).usize()
    let limit = source.size()
    // Skip optional trim marker
    try if source(i)? == '-' then i = i + 1 end end
    // Skip whitespace
    while i < limit do
      try
        let c = source(i)?
        if (c == ' ') or (c == '\t') then i = i + 1
        else return c == '!'
        end
      else return false
      end
    end
    false

  fun _is_raw_open(source: String, start_pos: ISize): Bool =>
    """
    Check whether the `{{ }}` block starting at `start_pos` is a raw block
    opener. Peeks past `{{`, optional `-` trim marker, and optional whitespace
    to see if the next content is the `raw` keyword followed by a word
    boundary (space, tab, `-`, or `}`).
    """
    var i = (start_pos + 2).usize()
    let limit = source.size()
    // Skip optional trim marker
    try if source(i)? == '-' then i = i + 1 end end
    // Skip whitespace
    while i < limit do
      try
        let c = source(i)?
        if (c == ' ') or (c == '\t') then i = i + 1
        else break
        end
      else return false
      end
    end
    // Check for "raw" keyword
    if (i + 3) > limit then return false end
    try
      if (source(i)? != 'r')
        or (source(i + 1)? != 'a')
        or (source(i + 2)? != 'w')
      then
        return false
      end
    else return false
    end
    // Check word boundary: next char must be space, tab, -, or }
    if (i + 3) == limit then return false end
    try
      let c = source(i + 3)?
      (c == ' ') or (c == '\t') or (c == '-') or (c == '}')
    else false
    end

  fun _find_raw_end(
    source: String,
    from: ISize
  ): (ISize, ISize, Bool, Bool)? =>
    """
    Scan forward from `from` looking for `{{ end }}` (with optional trim/
    whitespace). Returns `(start_pos, end_pos, left_trim, right_trim)` of the
    closing `{{end}}` tag, or errors if not found.
    """
    var search = from
    while search < source.size().isize() do
      let open_pos = source.find("{{" where offset = search)?
      let close_pos = source.find("}}" where offset = open_pos + 2)?

      // Extract content between {{ and }}
      let lt =
        try source((open_pos + 2).usize())? == '-'
        else false
        end
      let content_start: ISize =
        if lt then open_pos + 3 else open_pos + 2 end
      let rt =
        try
          (close_pos > content_start)
            and (source((close_pos - 1).usize())? == '-')
        else false
        end
      let content_end: ISize =
        if rt then close_pos - 1 else close_pos end

      let inner = source.substring(content_start, content_end)
      inner.strip()

      if inner == "end" then
        return (open_pos, close_pos, lt, rt)
      end

      search = close_pos + 2
    end
    error

  fun _scan_raw_block(source: String, start_pos: ISize): _BlockScan? =>
    """
    Scan a `{{raw}}...{{end}}` raw block starting at `start_pos`. Returns a
    `_BlockScan` with `kind = _RawBlock` whose `stmt_source` is the literal
    content between the raw open tag and the matching `{{end}}`.
    """
    // Find closing }} of the {{raw}} tag
    let raw_close =
      try source.find("}}" where offset = start_pos + 2)?
      else error
      end

    // Determine trim flags on raw open tag
    let outer_left_trim =
      try source((start_pos + 2).usize())? == '-'
      else false
      end
    let raw_stmt_start: ISize =
      if outer_left_trim then start_pos + 3 else start_pos + 2 end
    let raw_right_trim =
      try
        (raw_close > raw_stmt_start)
          and (source((raw_close - 1).usize())? == '-')
      else false
      end

    // Find matching {{end}}
    let content_start = raw_close + 2
    (let end_open, let end_close, let end_left_trim, let outer_right_trim) =
      _find_raw_end(source, content_start)?

    // Extract raw content between raw close and end open
    var content = source.substring(content_start, end_open)

    // Apply internal trim: raw open's right-trim → lstrip content,
    // end tag's left-trim → rstrip content
    if raw_right_trim then content.lstrip() end
    if end_left_trim then content.rstrip() end

    _BlockScan(
      consume content,
      start_pos,
      end_close,
      outer_left_trim,
      outer_right_trim,
      _RawBlock)

  fun _find_close_delim(source: String, from: ISize): ISize? =>
    """
    Find the closing `}}` delimiter starting from `from`, skipping over
    double-quoted strings so that `}}` inside a filter argument like
    `default("a}}b")` is not treated as the closing delimiter.
    """
    var i = from
    let limit = source.size().isize()
    while i < (limit - 1) do
      if source(i.usize())? == '"' then
        // Skip to closing quote
        i = i + 1
        while i < limit do
          if source(i.usize())? == '"' then break end
          i = i + 1
        end
      elseif
        (source(i.usize())? == '}') and (source((i + 1).usize())? == '}')
      then
        return i
      end
      i = i + 1
    end
    error
