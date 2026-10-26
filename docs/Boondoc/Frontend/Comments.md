# Class: Boondoc::Frontend::Comments

- **Defined in:** [`lib/boondoc/frontend/comments.rb`](../../../lib/boondoc/frontend/comments.rb)

Finds the comment block that documents a given line of a parsed file.

## Constants

### <a id="constant-DIRECTIVE"></a>`DIRECTIVE`

```ruby
DIRECTIVE = /^\s*@!\w/
```

### <a id="constant-IGNORED"></a>`IGNORED`

```ruby
IGNORED = /\A#(?:!|\s*(?:rubocop:|frozen_string_literal:|encoding:|typed:|:nodoc:))/
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(result)`](#method-i-initialize) |  |
| [`#directive_lines`](#method-i-directive_lines) | Returns last lines of comment blocks that contain YARD directives |
| [`#docstring_for(line)`](#method-i-docstring_for) | Returns the text of the comment block ending on the line above |
| [`#nodoc?(line)`](#method-i-nodoc-3F) | Returns true when the line carries a trailing `# :nodoc:` |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(result)
```

**Parameters:**

- `result` (`::Prism::ParseResult`)

### <a id="method-i-directive_lines"></a>`#directive_lines`

```ruby
def directive_lines
```

**Returns:**

- (`Array<Integer>`) — last lines of comment blocks that contain YARD directives

### <a id="method-i-docstring_for"></a>`#docstring_for`

```ruby
def docstring_for(line)
```

**Parameters:**

- `line` (`Integer`) — the line a definition starts on

**Returns:**

- (`String`, `nil`) — the text of the comment block ending on the line above

### <a id="method-i-nodoc-3F"></a>`#nodoc?`

```ruby
def nodoc?(line)
```

**Parameters:**

- `line` (`Integer`)

**Returns:**

- (`Boolean`) — true when the line carries a trailing `# :nodoc:`
