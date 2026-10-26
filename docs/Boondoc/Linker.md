# Class: Boondoc::Linker

- **Defined in:** [`lib/boondoc/linker.rb`](../../lib/boondoc/linker.rb)

Turns YARD-style references in markdown into relative links.

Handles `{Foo#bar}`, `{Foo#bar custom text}`, `{https://example.com text}`,
`{file:GUIDE.md}`, and the include forms `{include:Foo}` and
`{include:file:path.md}`. Code blocks and code spans are left untouched.

## Constants

### <a id="constant-CONSTANT"></a>`CONSTANT`

```ruby
CONSTANT = /(?:::)?[A-Z]\w*(?:::[A-Z]\w*)*/
```

### <a id="constant-CONSTANT_REFERENCE"></a>`CONSTANT_REFERENCE`

```ruby
CONSTANT_REFERENCE = /\A#{CONSTANT}(?:[#.].+)?\z/
```

### <a id="constant-INCLUDE"></a>`INCLUDE`

```ruby
INCLUDE = /\{include:(?<file>file:)?(?<target>[^{}\s]+)\}/
```

### <a id="constant-MAX_INCLUDE_DEPTH"></a>`MAX_INCLUDE_DEPTH`

```ruby
MAX_INCLUDE_DEPTH = 5
```

### <a id="constant-METHOD_REFERENCE"></a>`METHOD_REFERENCE`

```ruby
METHOD_REFERENCE = /\A[#.][^\s]/
```

### <a id="constant-REFERENCE"></a>`REFERENCE`

```ruby
REFERENCE = /(?<escape>\\)?\{(?<target>[^{}\s]+)(?:\s+(?<title>[^{}]+?))?\}/
```

### <a id="constant-URL"></a>`URL`

```ruby
URL = %r{\A(?:[a-z][a-z0-9+.-]*://|mailto:)}i
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(config:, registry:, filter:, path_map:, stitcher:, reporter:, assets: Assets.new(config))`](#method-i-initialize) |  |
| [`#link(object, from:, label: nil)`](#method-i-link) | Returns a markdown link, or just the label when the object is not rendered |
| [`#text(text, object:, from:, assets: true)`](#method-i-text) | Expands includes and resolves references in a piece of markdown, then points paths to copied assets at their copies. |
| [`#types(types, object:, from:)`](#method-i-types) | Formats a type list, linking every constant that is documented. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(config:, registry:, filter:, path_map:, stitcher:, reporter:, assets: Assets.new(config))
```

**Parameters:**

- `config` ([`Config`](Config.md))
- `registry` ([`Model::Registry`](Model/Registry.md))
- `filter` ([`Filter`](Filter.md))
- `path_map` ([`PathMap`](PathMap.md))
- `stitcher` ([`Stitcher`](Stitcher.md))
- `assets` ([`Assets`](Assets.md)) — the files copied into the output, which image paths may name
- `reporter` ([`Reporter`](Reporter.md))

### <a id="method-i-link"></a>`#link`

```ruby
def link(object, from:, label: nil)
```

**Parameters:**

- `object` ([`Model::CodeObject`](Model/CodeObject.md))
- `from` (`String`) — the output file the link is written in
- `label` (`String`, `nil`) — link text; defaults to the object's path in a code span

**Returns:**

- (`String`) — a markdown link, or just the label when the object is not rendered

### <a id="method-i-text"></a>`#text`

```ruby
def text(text, object:, from:, assets: true)
```

Expands includes and resolves references in a piece of markdown, then points
paths to copied assets at their copies.

**Parameters:**

- `text` (`String`)
- `object` ([`Model::CodeObject`](Model/CodeObject.md)) — where the text was written; references
  are looked up relative to it
- `from` (`String`) — the output file the text will appear in
- `assets` (`Boolean`) — whether to rewrite asset paths; false for stitched files,
  whose paths [`Stitcher`](Stitcher.md) has already rewritten

**Returns:**

- (`String`)

### <a id="method-i-types"></a>`#types`

```ruby
def types(types, object:, from:)
```

Formats a type list, linking every constant that is documented.

**Parameters:**

- `types` (`Array<String>`, `nil`)
- `object` ([`Model::CodeObject`](Model/CodeObject.md))
- `from` (`String`)

**Returns:**

- (`String`, `nil`) — such as `` `Array<`[`Foo`](Foo.md)`>`, `nil` ``
