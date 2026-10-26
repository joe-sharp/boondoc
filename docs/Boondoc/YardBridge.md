# Class: Boondoc::YardBridge

- **Defined in:** [`lib/boondoc/yard_bridge.rb`](../../lib/boondoc/yard_bridge.rb)

Optional second pass that uses YARD to expand macros and directives.

Prism stays the source of truth. YARD only contributes objects that Prism
could not see (those created by `@!method`, `@!attribute`, or an attached
macro) and the expanded docstrings of objects whose comment uses a directive.

The `yard` gem is loaded on demand and is not a dependency of boondoc.

## Constants

### <a id="constant-DEFAULT_SUPERCLASSES"></a>`DEFAULT_SUPERCLASSES`

```ruby
DEFAULT_SUPERCLASSES = %w[Object BasicObject].freeze
```

### <a id="constant-ERROR_LEVEL"></a>`ERROR_LEVEL`

```ruby
ERROR_LEVEL = 3
```

The "error" severity, which has the same value in every YARD logger implementation.

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(registry, reporter)`](#method-i-initialize) |  |
| [`#merge(files, root:)`](#method-i-merge) | Returns how many objects were added from YARD |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(registry, reporter)
```

**Parameters:**

- `registry` ([`Model::Registry`](Model/Registry.md))
- `reporter` ([`Reporter`](Reporter.md))

### <a id="method-i-merge"></a>`#merge`

```ruby
def merge(files, root:)
```

**Parameters:**

- `files` (`Array<String>`) — the Ruby files that contain YARD directives, relative to `root`
- `root` (`String`) — the project directory. YARD is given absolute paths, so the
  working directory does not matter, and the files it records are made relative again.

**Returns:**

- (`Integer`) — how many objects were added from YARD

**Raises:**

- ([`Error`](Error.md)) — when the yard gem is not installed
