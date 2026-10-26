# Class: Boondoc::Context

- **Defined in:** [`lib/boondoc/context.rb`](../../lib/boondoc/context.rb)

Everything the renderers need to produce a page.

## Attributes

### <a id="method-i-assets"></a>`#assets`

```ruby
attr_reader :assets
```

### <a id="method-i-config"></a>`#config`

```ruby
attr_reader :config
```

### <a id="method-i-filter"></a>`#filter`

```ruby
attr_reader :filter
```

### <a id="method-i-linker"></a>`#linker`

```ruby
attr_reader :linker
```

### <a id="method-i-path_map"></a>`#path_map`

```ruby
attr_reader :path_map
```

### <a id="method-i-registry"></a>`#registry`

```ruby
attr_reader :registry
```

### <a id="method-i-reporter"></a>`#reporter`

```ruby
attr_reader :reporter
```

### <a id="method-i-stitcher"></a>`#stitcher`

```ruby
attr_reader :stitcher
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(config:, registry:, reporter:)`](#method-i-initialize) |  |
| [`#aliases(namespace, scope)`](#method-i-aliases) | The aliases of the methods of a namespace, found without scanning every method for each one. |
| [`#meths(namespace, scope)`](#method-i-meths) | The methods of a namespace in one scope, sorted once per run. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(config:, registry:, reporter:)
```

**Parameters:**

- `config` ([`Config`](Config.md))
- `registry` ([`Model::Registry`](Model/Registry.md))
- `reporter` ([`Reporter`](Reporter.md))

### <a id="method-i-aliases"></a>`#aliases`

```ruby
def aliases(namespace, scope)
```

The aliases of the methods of a namespace, found without scanning every
method for each one.

**Parameters:**

- `namespace` ([`Model::NamespaceObject`](Model/NamespaceObject.md))
- `scope` (`Symbol`) — `:instance` or `:class`

**Returns:**

- (`Hash{String => Array<`[`Model::MethodObject`](Model/MethodObject.md)`>}`) — aliases keyed by the name they alias

### <a id="method-i-meths"></a>`#meths`

```ruby
def meths(namespace, scope)
```

The methods of a namespace in one scope, sorted once per run.

Nothing changes the registry while pages are rendered, so the list can be
kept for the lifetime of the context. Keeping it here rather than in the
model matters because the parser changes `children` directly.

**Parameters:**

- `namespace` ([`Model::NamespaceObject`](Model/NamespaceObject.md))
- `scope` (`Symbol`) — `:instance` or `:class`

**Returns:**

- (`Array<`[`Model::MethodObject`](Model/MethodObject.md)`>`) — see [`Model::NamespaceObject#meths`](Model/NamespaceObject.md#method-i-meths)
