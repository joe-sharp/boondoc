# Module: Boondoc::TypeParser

- **Defined in:** [`lib/boondoc/type_parser.rb`](../../lib/boondoc/type_parser.rb)

Splits a YARD type list such as `[String, Hash{Symbol => Array<Integer>}]`.

## Constants

### <a id="constant-OPENERS"></a>`OPENERS`

```ruby
OPENERS = { '[' => ']', '<' => '>', '(' => ')', '{' => '}' }.freeze
```

### <a id="constant-OPERATOR_DUCK_TYPE"></a>`OPERATOR_DUCK_TYPE`

```ruby
OPERATOR_DUCK_TYPE = /#(?:<=>|<<|>>|[<>]=?|\[\]=?)/
```

Duck types naming an operator method that contains bracket characters.

## Class methods

| Method | Summary |
| --- | --- |
| [`.extract(text)`](#method-c-extract) | Takes a leading bracketed type list off a string. |
| [`.split(list)`](#method-c-split) | Splits on top-level commas, leaving nested brackets intact. |

### <a id="method-c-extract"></a>`.extract`

```ruby
def self.extract(text)
```

Takes a leading bracketed type list off a string.

**Parameters:**

- `text` (`String`)

**Returns:**

- (`Array(Array<String>, String)`, `Array(nil, String)`) — the types (nil
  when the text does not start with `[`) and the remaining text

### <a id="method-c-split"></a>`.split`

```ruby
def self.split(list)
```

Splits on top-level commas, leaving nested brackets intact.

**Parameters:**

- `list` (`String`) — the text between the outer brackets

**Returns:**

- (`Array<String>`)
