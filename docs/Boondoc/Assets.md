# Class: Boondoc::Assets

- **Defined in:** [`lib/boondoc/assets.rb`](../../lib/boondoc/assets.rb)

The files that are copied into the output directory next to the pages: images, video, PDFs,
and anything else a page links to or embeds.

Two kinds are copied. The ones named by the `assets` option are always copied. Each entry is a
file, a directory (everything under it), or a glob, optionally followed by `:DIR` to copy into
that directory of the output instead of keeping the project path. Hidden files, symlinks that
leave the project, and anything in the output directory are skipped. With `copy_linked_assets`
the files that pages embed are copied too, as they are found while the pages are rendered, so
[`#files`](#method-i-files) is only complete once rendering has finished.

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(config)`](#method-i-initialize) |  |
| [`#copy_for(path, embedded: false)`](#method-i-copy_for) | Finds the copy of a path written in a page. |
| [`#files`](#method-i-files) | Returns absolute source paths, keyed by the path relative to |
| [`#output_for(absolute, embedded: false)`](#method-i-output_for) | Where a file will be in the output directory, when it is copied there. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(config)
```

**Parameters:**

- `config` ([`Config`](Config.md))

**Raises:**

- ([`Error`](Error.md)) — when a named file is outside the project, or two files would be copied to the same path

### <a id="method-i-copy_for"></a>`#copy_for`

```ruby
def copy_for(path, embedded: false)
```

Finds the copy of a path written in a page. A path is first read relative to the output
directory, as YARD's `--asset` paths are, and then relative to the project.

**Parameters:**

- `path` (`String`) — a path without any fragment or query
- `embedded` (`Boolean`) — whether the page embeds the file rather than linking to it

**Returns:**

- (`String`, `nil`) — the path relative to the output directory, or nil when nothing is copied

### <a id="method-i-files"></a>`#files`

```ruby
def files
```

**Returns:**

- (`Hash{String => String}`) — absolute source paths, keyed by the path relative to
  the output directory that each is copied to

### <a id="method-i-output_for"></a>`#output_for`

```ruby
def output_for(absolute, embedded: false)
```

Where a file will be in the output directory, when it is copied there.

**Parameters:**

- `absolute` (`String`) — absolute path of a file in the project
- `embedded` (`Boolean`) — whether the page embeds the file, as an image does

**Returns:**

- (`String`, `nil`) — the path relative to the output directory, or nil when the file is not copied
