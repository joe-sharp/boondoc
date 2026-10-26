# Class: Boondoc::Model::Docstring

- **Defined in:** [`lib/boondoc/model/docstring.rb`](../../../lib/boondoc/model/docstring.rb)

A parsed documentation comment: free markdown text plus tags.

## Attributes

### <a id="method-i-directives"></a>`#directives`

```ruby
attr_reader :directives
```

**Returns:**

- (`Array<String>`) — names of YARD directives (`@!macro`, ...) found in the comment

### <a id="method-i-tags"></a>`#tags`

```ruby
attr_reader :tags
```

**Returns:**

- (`Array<`[`Tag`](Tag.md)`>`)

### <a id="method-i-text"></a>`#text`

```ruby
attr_reader :text
```

**Returns:**

- (`String`) — the markdown body, without tags

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(text = '', tags = [], directives = [])`](#method-i-initialize) |  |
| [`#empty?`](#method-i-empty-3F) | Returns true when there is neither text nor tags |
| [`#summary`](#method-i-summary) | Returns the first sentence of the first paragraph, on one line; |
| [`#tag(name)`](#method-i-tag) | Returns the first tag with that name |
| [`#tag?(name)`](#method-i-tag-3F) |  |
| [`#tags_named(name)`](#method-i-tags_named) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(text = '', tags = [], directives = [])
```

**Parameters:**

- `text` (`String`)
- `tags` (`Array<`[`Tag`](Tag.md)`>`)
- `directives` (`Array<String>`)

### <a id="method-i-empty-3F"></a>`#empty?`

```ruby
def empty?
```

**Returns:**

- (`Boolean`) — true when there is neither text nor tags

### <a id="method-i-summary"></a>`#summary`

```ruby
def summary
```

**Returns:**

- (`String`) — the first sentence of the first paragraph, on one line;
  falls back to the `@return` description when there is no body

### <a id="method-i-tag"></a>`#tag`

```ruby
def tag(name)
```

**Parameters:**

- `name` (`String`)

**Returns:**

- ([`Tag`](Tag.md), `nil`) — the first tag with that name

### <a id="method-i-tag-3F"></a>`#tag?`

```ruby
def tag?(name)
```

**Parameters:**

- `name` (`String`)

**Returns:**

- (`Boolean`)

### <a id="method-i-tags_named"></a>`#tags_named`

```ruby
def tags_named(name)
```

**Parameters:**

- `name` (`String`) — tag name without the `@`

**Returns:**

- (`Array<`[`Tag`](Tag.md)`>`)
