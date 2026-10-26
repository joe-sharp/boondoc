# Class: Boondoc::Model::ConstantObject

- **Inherits:** [`Boondoc::Model::CodeObject`](CodeObject.md)
- **Defined in:** [`lib/boondoc/model/code_object.rb`](../../../lib/boondoc/model/code_object.rb)

A constant that is not a class or module.

## Attributes

### <a id="method-i-value"></a>`#value`

```ruby
attr_reader :value
```

**Returns:**

- (`String`) — the source of the assigned value

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(name, namespace, value: '')`](#method-i-initialize) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(name, namespace, value: '')
```

**Parameters:**

- `name` (`String`)
- `namespace` ([`NamespaceObject`](NamespaceObject.md))
- `value` (`String`)

## Inherited methods

- From [`Boondoc::Model::CodeObject`](CodeObject.md): [`#add_file`](CodeObject.md#method-i-add_file), [`#docstring`](CodeObject.md#method-i-docstring), [`#docstring=`](CodeObject.md#method-i-docstring-3D), [`#files`](CodeObject.md#method-i-files), [`#name`](CodeObject.md#method-i-name), [`#namespace`](CodeObject.md#method-i-namespace), [`#path`](CodeObject.md#method-i-path), [`#private_api?`](CodeObject.md#method-i-private_api-3F), [`#root?`](CodeObject.md#method-i-root-3F), [`#visibility`](CodeObject.md#method-i-visibility), [`#visibility=`](CodeObject.md#method-i-visibility-3D)
