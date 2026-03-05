primitive Upper is Filter
  """
  Converts the input to uppercase (ASCII).

  ```
  {{ name | upper }}
  ```
  """
  fun apply(input: String): String =>
    let out = input.clone()
    out.upper_in_place()
    consume out

primitive Lower is Filter
  """
  Converts the input to lowercase (ASCII).

  ```
  {{ name | lower }}
  ```
  """
  fun apply(input: String): String =>
    let out = input.clone()
    out.lower_in_place()
    consume out

primitive Trim is Filter
  """
  Strips leading and trailing whitespace from the input.

  ```
  {{ name | trim }}
  ```
  """
  fun apply(input: String): String =>
    let out = input.clone()
    out.strip()
    consume out

primitive Capitalize is Filter
  """
  Capitalizes the first character and lowercases the rest (ASCII).

  ```
  {{ name | capitalize }}
  ```
  """
  fun apply(input: String): String =>
    if input.size() == 0 then return "" end
    let out = recover iso String(input.size()) end
    var first = true
    for byte in input.values() do
      if first then
        if (byte >= 'a') and (byte <= 'z') then
          out.push(byte - 0x20)
        else
          out.push(byte)
        end
        first = false
      else
        if (byte >= 'A') and (byte <= 'Z') then
          out.push(byte + 0x20)
        else
          out.push(byte)
        end
      end
    end
    consume out

primitive Default is Filter2
  """
  Returns `arg1` when the input is empty, otherwise returns the input.

  ```
  {{ name | default("Anonymous") }}
  ```
  """
  fun apply(input: String, arg1: String): String =>
    if input.size() == 0 then arg1 else input end

primitive Title is Filter
  """
  Converts the input to title case (first character of each word uppercased,
  rest lowercased, ASCII only). Words are delimited by whitespace.

  ```
  {{ name | title }}
  ```
  """
  fun apply(input: String): String =>
    if input.size() == 0 then return "" end
    let out = recover iso String(input.size()) end
    var word_start = true
    for byte in input.values() do
      if (byte == ' ') or (byte == '\t') or (byte == '\n')
        or (byte == '\r')
      then
        out.push(byte)
        word_start = true
      elseif word_start then
        if (byte >= 'a') and (byte <= 'z') then
          out.push(byte - 0x20)
        else
          out.push(byte)
        end
        word_start = false
      else
        if (byte >= 'A') and (byte <= 'Z') then
          out.push(byte + 0x20)
        else
          out.push(byte)
        end
      end
    end
    consume out

primitive Replace is Filter3
  """
  Replaces all occurrences of `arg1` with `arg2` in the input.

  ```
  {{ name | replace("old", "new") }}
  ```
  """
  fun apply(input: String, arg1: String, arg2: String): String =>
    let out = input.clone()
    out.replace(arg1, arg2)
    consume out
