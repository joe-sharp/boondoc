# Class: Boondoc::ExtraFile

- **Inherits:** `Struct`
- **Defined in:** [`lib/boondoc/stitcher.rb`](../../lib/boondoc/stitcher.rb)

A non-API file (README, changelog, guide) that is copied into the output.

## Attributes

### <a id="method-i-content"></a><a id="method-i-content-3D"></a>`#content`

```ruby
attr_accessor :content
```

### <a id="method-i-output"></a><a id="method-i-output-3D"></a>`#output`

```ruby
attr_accessor :output
```

### <a id="method-i-readme"></a><a id="method-i-readme-3D"></a>`#readme`

```ruby
attr_accessor :readme
```

### <a id="method-i-source"></a><a id="method-i-source-3D"></a>`#source`

```ruby
attr_accessor :source
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#title`](#method-i-title) | Returns the first top-level heading, or the file name |

### <a id="method-i-title"></a>`#title`

```ruby
def title
```

**Returns:**

- (`String`) — the first top-level heading, or the file name
