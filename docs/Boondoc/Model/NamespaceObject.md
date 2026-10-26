# Class: Boondoc::Model::NamespaceObject

- **Inherits:** [`Boondoc::Model::CodeObject`](CodeObject.md)
- **Defined in:** [`lib/boondoc/model/code_object.rb`](../../../lib/boondoc/model/code_object.rb)

A class, a module, or the top-level namespace.

## Attributes

### <a id="method-i-children"></a>`#children`

```ruby
attr_reader :children
```

**Returns:**

- (`Array<`[`CodeObject`](CodeObject.md)`>`) — everything defined directly inside this namespace

### <a id="method-i-kind"></a><a id="method-i-kind-3D"></a>`#kind`

```ruby
attr_accessor :kind
```

**Returns:**

- (`Symbol`) — `:class`, `:module`, or `:root`

### <a id="method-i-mixins"></a>`#mixins`

```ruby
attr_reader :mixins
```

**Returns:**

- (`Hash{Symbol => Array<String>}`) — mixin names keyed by `:include`, `:extend`, `:prepend`

### <a id="method-i-superclass"></a><a id="method-i-superclass-3D"></a>`#superclass`

```ruby
attr_accessor :superclass
```

**Returns:**

- (`String`, `nil`) — the superclass as written in source

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(name, namespace, kind: :module)`](#method-i-initialize) |  |
| [`#constants`](#method-i-constants) | Returns constants, sorted by name |
| [`#meths(scope)`](#method-i-meths) | Returns methods in that scope, `initialize` first, then by name |
| [`#namespaces`](#method-i-namespaces) | Returns nested classes and modules, sorted by name |
| [`#path`](#method-i-path) | Returns empty for the root |
| [`#root?`](#method-i-root-3F) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(name, namespace, kind: :module)
```

**Parameters:**

- `name` (`String`)
- `namespace` ([`NamespaceObject`](NamespaceObject.md), `nil`)
- `kind` (`Symbol`)

### <a id="method-i-constants"></a>`#constants`

```ruby
def constants
```

**Returns:**

- (`Array<`[`ConstantObject`](ConstantObject.md)`>`) — constants, sorted by name

### <a id="method-i-meths"></a>`#meths`

```ruby
def meths(scope)
```

**Parameters:**

- `scope` (`Symbol`) — `:instance` or `:class`

**Returns:**

- (`Array<`[`MethodObject`](MethodObject.md)`>`) — methods in that scope, `initialize` first, then by name

### <a id="method-i-namespaces"></a>`#namespaces`

```ruby
def namespaces
```

**Returns:**

- (`Array<`[`NamespaceObject`](NamespaceObject.md)`>`) — nested classes and modules, sorted by name

### <a id="method-i-path"></a>`#path`

```ruby
def path
```

**Returns:**

- (`String`) — empty for the root

### <a id="method-i-root-3F"></a>`#root?`

```ruby
def root?
```

**Returns:**

- (`Boolean`)

## Inherited methods

- From [`Boondoc::Model::CodeObject`](CodeObject.md): [`#add_file`](CodeObject.md#method-i-add_file), [`#docstring`](CodeObject.md#method-i-docstring), [`#docstring=`](CodeObject.md#method-i-docstring-3D), [`#files`](CodeObject.md#method-i-files), [`#name`](CodeObject.md#method-i-name), [`#namespace`](CodeObject.md#method-i-namespace), [`#private_api?`](CodeObject.md#method-i-private_api-3F), [`#visibility`](CodeObject.md#method-i-visibility), [`#visibility=`](CodeObject.md#method-i-visibility-3D)
