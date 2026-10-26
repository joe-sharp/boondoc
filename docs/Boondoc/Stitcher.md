# Class: Boondoc::Stitcher

- **Defined in:** [`lib/boondoc/stitcher.rb`](../../lib/boondoc/stitcher.rb)

Loads the extra files and keeps their relative links working after the move.

## Constants

### <a id="constant-MARKDOWN"></a>`MARKDOWN`

```ruby
MARKDOWN = /\.(?:md|markdown)\z/i
```

## Attributes

### <a id="method-i-files"></a>`#files`

```ruby
attr_reader :files
```

**Returns:**

- (`Array<`[`ExtraFile`](ExtraFile.md)`>`) — the README (if any) first, then the other files

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(config, assets: Assets.new(config))`](#method-i-initialize) |  |
| [`#find(name)`](#method-i-find) | Finds a stitched file by path, file name, or file name without extension. |
| [`#readme`](#method-i-readme) |  |
| [`#relocated_content(file)`](#method-i-relocated_content) | Rewrites relative links and image paths so they still point at the same thing from the file's new location in the output directory. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(config, assets: Assets.new(config))
```

**Parameters:**

- `config` ([`Config`](Config.md))
- `assets` ([`Assets`](Assets.md)) — the files that are copied into the output, which links follow to their copies

### <a id="method-i-find"></a>`#find`

```ruby
def find(name)
```

Finds a stitched file by path, file name, or file name without extension.

**Parameters:**

- `name` (`String`)

**Returns:**

- ([`ExtraFile`](ExtraFile.md), `nil`)

### <a id="method-i-readme"></a>`#readme`

```ruby
def readme
```

**Returns:**

- ([`ExtraFile`](ExtraFile.md), `nil`)

### <a id="method-i-relocated_content"></a>`#relocated_content`

```ruby
def relocated_content(file)
```

Rewrites relative links and image paths so they still point at the same
thing from the file's new location in the output directory. A path to a
file that is copied into the output points at the copy.

**Parameters:**

- `file` ([`ExtraFile`](ExtraFile.md))

**Returns:**

- (`String`) — the file's content with links adjusted
