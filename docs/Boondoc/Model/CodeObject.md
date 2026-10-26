# Class: Boondoc::Model::CodeObject

- **Defined in:** [`lib/boondoc/model/code_object.rb`](../../../lib/boondoc/model/code_object.rb)

Base class for everything that can be documented.

## Attributes

### <a id="method-i-docstring"></a><a id="method-i-docstring-3D"></a>`#docstring`

```ruby
attr_accessor :docstring
```

**Returns:**

- ([`Docstring`](Docstring.md))

### <a id="method-i-files"></a>`#files`

```ruby
attr_reader :files
```

**Returns:**

- (`Array<Array(String, Integer)>`) — `[file, line]` pairs where the object is defined

### <a id="method-i-name"></a>`#name`

```ruby
attr_reader :name
```

**Returns:**

- (`String`) — the unqualified name

### <a id="method-i-namespace"></a>`#namespace`

```ruby
attr_reader :namespace
```

**Returns:**

- ([`NamespaceObject`](NamespaceObject.md), `nil`) — the enclosing namespace (nil only for the root)

### <a id="method-i-visibility"></a><a id="method-i-visibility-3D"></a>`#visibility`

```ruby
attr_accessor :visibility
```

**Returns:**

- (`Symbol`) — `:public`, `:protected`, or `:private`

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(name, namespace)`](#method-i-initialize) |  |
| [`#add_file(file, line)`](#method-i-add_file) | Records a definition site, ignoring duplicates. |
| [`#path`](#method-i-path) | Returns the fully qualified path, such as `Foo::Bar#baz` |
| [`#private_api?`](#method-i-private_api-3F) | Returns true when tagged `@private` or `@api private` |
| [`#root?`](#method-i-root-3F) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(name, namespace)
```

**Parameters:**

- `name` (`String`)
- `namespace` ([`NamespaceObject`](NamespaceObject.md), `nil`)

### <a id="method-i-add_file"></a>`#add_file`

```ruby
def add_file(file, line)
```

Records a definition site, ignoring duplicates.

**Parameters:**

- `file` (`String`)
- `line` (`Integer`)

**Returns:**

- (`void`)

### <a id="method-i-path"></a>`#path`

```ruby
def path
```

**Returns:**

- (`String`) — the fully qualified path, such as `Foo::Bar#baz`

### <a id="method-i-private_api-3F"></a>`#private_api?`

```ruby
def private_api?
```

**Returns:**

- (`Boolean`) — true when tagged `@private` or `@api private`

### <a id="method-i-root-3F"></a>`#root?`

```ruby
def root?
```

**Returns:**

- (`Boolean`)
