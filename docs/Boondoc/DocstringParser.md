# Class: Boondoc::DocstringParser

- **Defined in:** [`lib/boondoc/docstring_parser.rb`](../../lib/boondoc/docstring_parser.rb)

Turns the text of a documentation comment into a [`Model::Docstring`](Model/Docstring.md).

A line starting with `@name` begins a tag; indented lines that follow belong
to it. Everything else is the markdown body.

## Constants

### <a id="constant-FENCE"></a>`FENCE`

```ruby
FENCE = /\A\s*(?:```|~~~)/
```

### <a id="constant-NAMED"></a>`NAMED`

```ruby
NAMED = %w[param yieldparam attr attr_reader attr_writer].freeze
```

### <a id="constant-TAG_LINE"></a>`TAG_LINE`

```ruby
TAG_LINE = /\A@(?<directive>!)?(?<name>[a-z_][\w.]*)(?:\s+(?<rest>.*))?\z/i
```

## Class methods

| Method | Summary |
| --- | --- |
| [`.parse(text)`](#method-c-parse) |  |

### <a id="method-c-parse"></a>`.parse`

```ruby
def self.parse(text)
```

**Parameters:**

- `text` (`String`) — comment text with the leading `#` already removed

**Returns:**

- ([`Model::Docstring`](Model/Docstring.md))

## Instance methods

| Method | Summary |
| --- | --- |
| [`#parse(text)`](#method-i-parse) |  |

### <a id="method-i-parse"></a>`#parse`

```ruby
def parse(text)
```

**Parameters:**

- `text` (`String`)

**Returns:**

- ([`Model::Docstring`](Model/Docstring.md))
