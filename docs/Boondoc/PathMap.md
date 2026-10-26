# Class: Boondoc::PathMap

- **Defined in:** [`lib/boondoc/path_map.rb`](../../lib/boondoc/path_map.rb)

Maps objects to output files and anchors, and computes relative links.

## Constants

### <a id="constant-TOP_LEVEL"></a>`TOP_LEVEL`

```ruby
TOP_LEVEL = 'top-level.md'
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(config, registry)`](#method-i-initialize) |  |
| [`#anchor_for(object)`](#method-i-anchor_for) | Returns the anchor inside its file; nil for namespaces |
| [`#file_for(object)`](#method-i-file_for) | Returns output file, relative to the output directory. Classes and |
| [`#href(object, from:)`](#method-i-href) | Returns a relative link to the object |
| [`#relative(file, from)`](#method-i-relative) | Returns frozen; each distinct link is worked out once, because |
| [`#source_href(source, from:)`](#method-i-source_href) | Returns a relative link from the output file to a project file |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(config, registry)
```

**Parameters:**

- `config` ([`Config`](Config.md))
- `registry` ([`Model::Registry`](Model/Registry.md)) — consulted for classes and modules whose
  names differ only by case

### <a id="method-i-anchor_for"></a>`#anchor_for`

```ruby
def anchor_for(object)
```

**Parameters:**

- `object` ([`Model::CodeObject`](Model/CodeObject.md))

**Returns:**

- (`String`, `nil`) — the anchor inside its file; nil for namespaces

### <a id="method-i-file_for"></a>`#file_for`

```ruby
def file_for(object)
```

**Parameters:**

- `object` ([`Model::CodeObject`](Model/CodeObject.md))

**Returns:**

- (`String`) — output file, relative to the output directory. Classes and
  modules whose names differ only by case get their kind appended, such as
  `CLI.class.md` and `Cli.module.md`, so that the files stay apart on
  case-insensitive filesystems.

### <a id="method-i-href"></a>`#href`

```ruby
def href(object, from:)
```

**Parameters:**

- `object` ([`Model::CodeObject`](Model/CodeObject.md))
- `from` (`String`) — the output file the link is written in

**Returns:**

- (`String`) — a relative link to the object

### <a id="method-i-relative"></a>`#relative`

```ruby
def relative(file, from)
```

**Parameters:**

- `file` (`String`) — output file to link to
- `from` (`String`) — output file the link is written in

**Returns:**

- (`String`) — frozen; each distinct link is worked out once, because
  the same few targets are linked many times in a run

### <a id="method-i-source_href"></a>`#source_href`

```ruby
def source_href(source, from:)
```

**Parameters:**

- `source` (`String`) — a path relative to the project root
- `from` (`String`) — output file the link is written in

**Returns:**

- (`String`) — a relative link from the output file to a project file
