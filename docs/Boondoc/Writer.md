# Class: Boondoc::Writer

- **Defined in:** [`lib/boondoc/writer.rb`](../../lib/boondoc/writer.rb)

Writes generated pages and removes pages left over from earlier runs.

A manifest in the output directory records what Boondoc wrote, so only its
own files are ever deleted or silently overwritten. A page whose content has
not changed is not written again.

## Constants

### <a id="constant-MANIFEST"></a>`MANIFEST`

```ruby
MANIFEST = ".boondoc-manifest"
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(output_dir, reporter, force: false)`](#method-i-initialize) |  |
| [`#write(pages, assets: {})`](#method-i-write) | Returns stale files that were removed |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(output_dir, reporter, force: false)
```

**Parameters:**

- `output_dir` (`String`) — absolute path of the output directory
- `reporter` ([`Reporter`](Reporter.md))
- `force` (`Boolean`) — overwrite files that Boondoc did not generate

### <a id="method-i-write"></a>`#write`

```ruby
def write(pages, assets: {})
```

**Parameters:**

- `pages` (`Hash{String => String}`) — content keyed by path relative to the output directory
- `assets` (`Hash{String => String}`) — absolute source paths of files to copy, keyed by
  the path relative to the output directory

**Returns:**

- (`Array<String>`) — stale files that were removed

**Raises:**

- ([`Error`](Error.md)) — when a page would overwrite a file Boondoc did not generate,
  or would be written outside the output directory or through a symlink
