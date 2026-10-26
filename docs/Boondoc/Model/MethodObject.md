# Class: Boondoc::Model::MethodObject

- **Inherits:** [`Boondoc::Model::CodeObject`](CodeObject.md)
- **Defined in:** [`lib/boondoc/model/code_object.rb`](../../../lib/boondoc/model/code_object.rb)

A method or attribute.

## Attributes

### <a id="method-i-alias_for"></a>`#alias_for`

```ruby
attr_reader :alias_for
```

**Returns:**

- (`String`, `nil`) — name of the method this one aliases

### <a id="method-i-attribute"></a>`#attribute`

```ruby
attr_reader :attribute
```

**Returns:**

- (`Symbol`, `nil`) — `:reader` or `:writer` when defined by `attr_*`

### <a id="method-i-parameters"></a><a id="method-i-parameters-3D"></a>`#parameters`

```ruby
attr_accessor :parameters
```

**Returns:**

- (`String`, `nil`) — the parameter list as written, without parentheses

### <a id="method-i-scope"></a>`#scope`

```ruby
attr_reader :scope
```

**Returns:**

- (`Symbol`) — `:instance` or `:class`

## Class methods

| Method | Summary |
| --- | --- |
| [`.path_for(namespace, scope, name)`](#method-c-path_for) | Returns the path a method with that name and scope would have |

### <a id="method-c-path_for"></a>`.path_for`

```ruby
def self.path_for(namespace, scope, name)
```

**Parameters:**

- `namespace` ([`NamespaceObject`](NamespaceObject.md))
- `scope` (`Symbol`) — `:instance` or `:class`
- `name` (`String`)

**Returns:**

- (`String`) — the path a method with that name and scope would have

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(name, namespace, scope: :instance, parameters: nil, attribute: nil, alias_for: nil)`](#method-i-initialize) |  |
| [`#display_name`](#method-i-display_name) | Returns the name with its separator, such as `#each` |
| [`#path`](#method-i-path) |  |
| [`#separator`](#method-i-separator) | Returns `#` for instance methods, `.` for class methods |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(name, namespace, scope: :instance, parameters: nil, attribute: nil, alias_for: nil)
```

**Parameters:**

- `name` (`String`)
- `namespace` ([`NamespaceObject`](NamespaceObject.md))
- `scope` (`Symbol`)
- `parameters` (`String`, `nil`)
- `attribute` (`Symbol`, `nil`)
- `alias_for` (`String`, `nil`)

### <a id="method-i-display_name"></a>`#display_name`

```ruby
def display_name
```

**Returns:**

- (`String`) — the name with its separator, such as `#each`

### <a id="method-i-path"></a>`#path`

```ruby
def path
```

**Returns:**

- (`String`)

### <a id="method-i-separator"></a>`#separator`

```ruby
def separator
```

**Returns:**

- (`String`) — `#` for instance methods, `.` for class methods

## Inherited methods

- From [`Boondoc::Model::CodeObject`](CodeObject.md): [`#add_file`](CodeObject.md#method-i-add_file), [`#docstring`](CodeObject.md#method-i-docstring), [`#docstring=`](CodeObject.md#method-i-docstring-3D), [`#files`](CodeObject.md#method-i-files), [`#name`](CodeObject.md#method-i-name), [`#namespace`](CodeObject.md#method-i-namespace), [`#private_api?`](CodeObject.md#method-i-private_api-3F), [`#root?`](CodeObject.md#method-i-root-3F), [`#visibility`](CodeObject.md#method-i-visibility), [`#visibility=`](CodeObject.md#method-i-visibility-3D)
