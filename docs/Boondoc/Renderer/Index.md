# Class: Boondoc::Renderer::Index

- **Inherits:** [`Boondoc::Renderer::Base`](Base.md)
- **Defined in:** [`lib/boondoc/renderer/index.rb`](../../../lib/boondoc/renderer/index.rb)

Renders the index page (README plus tables of contents) and stitched files.

## Instance methods

| Method | Summary |
| --- | --- |
| [`#render`](#method-i-render) | Returns the index page |
| [`#render_file(file)`](#method-i-render_file) | Returns a stitched file with its links and references resolved |

### <a id="method-i-render"></a>`#render`

```ruby
def render
```

**Returns:**

- (`String`) — the index page

### <a id="method-i-render_file"></a>`#render_file`

```ruby
def render_file(file)
```

**Parameters:**

- `file` ([`ExtraFile`](../ExtraFile.md))

**Returns:**

- (`String`) — a stitched file with its links and references resolved

## Inherited methods

- From [`Boondoc::Renderer::Base`](Base.md): [`#initialize`](Base.md#method-i-initialize)
