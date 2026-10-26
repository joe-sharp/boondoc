# Module: Boondoc::Markdown

- **Defined in:** [`lib/boondoc/markdown.rb`](../../lib/boondoc/markdown.rb)

Just enough markdown awareness to leave code alone while rewriting prose.

## Constants

### <a id="constant-FENCE"></a>`FENCE`

```ruby
FENCE = /\A {0,3}(`{3,}|~{3,})/
```

### <a id="constant-INDENTED"></a>`INDENTED`

```ruby
INDENTED = /\A(?: {4}|\t)\s*\S/
```

### <a id="constant-INLINE_CODE"></a>`INLINE_CODE`

```ruby
INLINE_CODE = /(?<!`)(`+)(?!`)(?:(?!\n\s*\n).)+?(?<!`)\1(?!`)/m
```

### <a id="constant-LIST_ITEM"></a>`LIST_ITEM`

```ruby
LIST_ITEM = /\A\s*(?:[-*+]|\d+[.)])\s/
```

## Class methods

| Method | Summary |
| --- | --- |
| [`.map_prose(text, &)`](#method-c-map_prose) | Rewrites the prose of a markdown document, skipping fenced code blocks, indented code blocks and inline code spans. |
| [`.table_cell(text)`](#method-c-table_cell) | Returns the text on one line with pipes escaped |

### <a id="method-c-map_prose"></a>`.map_prose`

```ruby
def self.map_prose(text, &)
```

Rewrites the prose of a markdown document, skipping fenced code blocks,
indented code blocks and inline code spans.

**Parameters:**

- `text` (`String`)

**Yield parameters:**

- `prose` (`String`) — a run of text outside any code

**Yield returns:**

- (`String`) — its replacement

**Returns:**

- (`String`)

### <a id="method-c-table_cell"></a>`.table_cell`

```ruby
def self.table_cell(text)
```

**Parameters:**

- `text` (`String`) — a single table cell

**Returns:**

- (`String`) — the text on one line with pipes escaped
