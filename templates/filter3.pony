interface val Filter
  """
  A filter that takes only the piped input value, with no extra arguments.

  Template syntax: `{{ value | myfilter }}`
  """
  fun apply(input: String): String
    """
    Apply the filter to the input value and return the result.
    """

interface val Filter2
  """
  A filter that takes the piped input value and one extra argument.

  Template syntax: `{{ value | myfilter("arg1") }}` or
  `{{ value | myfilter(var) }}` where `var` is a template variable.
  """
  fun apply(input: String, arg1: String): String
    """
    Apply the filter to the input value with one extra argument.
    """

interface val Filter3
  """
  A filter that takes the piped input value and two extra arguments.

  Template syntax: `{{ value | myfilter("arg1", "arg2") }}` or with
  template variables as arguments.
  """
  fun apply(input: String, arg1: String, arg2: String): String
    """
    Apply the filter to the input value with two extra arguments.
    """

// Type alias for any filter arity.
// A filter registered in `TemplateContext` can be any of the three arities.
type AnyFilter is (Filter val | Filter2 val | Filter3 val)
