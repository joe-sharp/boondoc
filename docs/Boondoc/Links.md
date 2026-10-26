# Module: Boondoc::Links

- **Defined in:** [`lib/boondoc/links.rb`](../../lib/boondoc/links.rb)

Finds the paths in markdown links, images and HTML attributes so they can be rewritten.

Each path is passed on together with whether it is embedded in the page, as an image, video,
audio, `<source>` or `srcset`, or only linked to. Code blocks and code spans are left alone.

## Constants

### <a id="constant-ATTRIBUTE"></a>`ATTRIBUTE`

```ruby
ATTRIBUTE = /(?<lead>\b(?<name>src|href|poster|data)=["'])(?<target>[^"']+)/
```

### <a id="constant-DEFINITION"></a>`DEFINITION`

```ruby
DEFINITION = /^(?<lead> {0,3}\[(?<label>[^\]]+)\]:\s+<?)(?<target>[^\s>]+)/
```

### <a id="constant-EMBEDDING_ATTRIBUTES"></a>`EMBEDDING_ATTRIBUTES`

```ruby
EMBEDDING_ATTRIBUTES = %w[src poster data].freeze
```

### <a id="constant-EXTERNAL"></a>`EXTERNAL`

```ruby
EXTERNAL = %r{\A(?:[a-z][a-z0-9+.-]*:|[#/\{])}i
```

Targets that are not paths in the project: URLs, anchors, absolute paths, and `{references}`.

### <a id="constant-IMAGE_OPENING"></a>`IMAGE_OPENING`

```ruby
IMAGE_OPENING = /!\[(?:[^\[\]]|\[[^\[\]]*\])*\z/
```

### <a id="constant-IMAGE_REFERENCE"></a>`IMAGE_REFERENCE`

```ruby
IMAGE_REFERENCE = /!\[(?<alt>[^\]]*)\]\[(?<label>[^\]]*)\]/
```

### <a id="constant-INLINE"></a>`INLINE`

```ruby
INLINE = /(?<lead>\]\(\s*<?)(?<target>[^)\s>]+)/
```

### <a id="constant-SRCSET"></a>`SRCSET`

```ruby
SRCSET = /(?<lead>\bsrcset=["'])(?<value>[^"']+)/
```

### <a id="constant-SRCSET_ENTRY"></a>`SRCSET_ENTRY`

```ruby
SRCSET_ENTRY = /(?<url>[^\s,]+)(?<descriptor>\s+\d[\d.]*[wx])?/
```

## Class methods

| Method | Summary |
| --- | --- |
| [`.rewrite(content, &)`](#method-c-rewrite) | Returns the content with every path replaced by the block's result |

### <a id="method-c-rewrite"></a>`.rewrite`

```ruby
def self.rewrite(content, &)
```

**Parameters:**

- `content` (`String`) — markdown

**Yield parameters:**

- `target` (`String`) — a path as written, with any fragment or query still attached
- `embedded` (`Boolean`) — whether the page embeds the file rather than linking to it

**Yield returns:**

- (`String`) — the path to write in its place

**Returns:**

- (`String`) — the content with every path replaced by the block's result
