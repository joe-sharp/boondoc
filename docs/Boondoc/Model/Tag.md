# Class: Boondoc::Model::Tag

- **Inherits:** `Struct`
- **Defined in:** [`lib/boondoc/model/docstring.rb`](../../../lib/boondoc/model/docstring.rb)

One `@tag` from a docstring.

Which fields are set depends on the tag: `@param` uses `name`, `types` and
`text`; `@example` uses `name` as its title; `@option` adds `key` and
`default`; `@overload` carries a `signature` and a nested `docstring`.

## Attributes

### <a id="method-i-default"></a><a id="method-i-default-3D"></a>`#default`

```ruby
attr_accessor :default
```

### <a id="method-i-docstring"></a><a id="method-i-docstring-3D"></a>`#docstring`

```ruby
attr_accessor :docstring
```

### <a id="method-i-key"></a><a id="method-i-key-3D"></a>`#key`

```ruby
attr_accessor :key
```

### <a id="method-i-name"></a><a id="method-i-name-3D"></a>`#name`

```ruby
attr_accessor :name
```

### <a id="method-i-signature"></a><a id="method-i-signature-3D"></a>`#signature`

```ruby
attr_accessor :signature
```

### <a id="method-i-tag_name"></a><a id="method-i-tag_name-3D"></a>`#tag_name`

```ruby
attr_accessor :tag_name
```

### <a id="method-i-text"></a><a id="method-i-text-3D"></a>`#text`

```ruby
attr_accessor :text
```

### <a id="method-i-types"></a><a id="method-i-types-3D"></a>`#types`

```ruby
attr_accessor :types
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(**)`](#method-i-initialize) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(**)
```
