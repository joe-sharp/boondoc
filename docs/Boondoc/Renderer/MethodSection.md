# Class: Boondoc::Renderer::MethodSection

- **Inherits:** [`Boondoc::Renderer::Base`](Base.md)
- **Defined in:** [`lib/boondoc/renderer/method_section.rb`](../../../lib/boondoc/renderer/method_section.rb)

Renders the detail section for one method or one attribute.

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(context, from)`](#method-i-initialize) |  |
| [`#render(meth)`](#method-i-render) | Returns markdown blocks |
| [`#render_attribute(accessors)`](#method-i-render_attribute) | Renders a reader and/or writer as a single attribute entry. |
| [`#signature(meth)`](#method-i-signature) | Returns the method as it would be defined, such as `def self.build(name)` |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(context, from)
```

**Parameters:**

- `context` ([`Context`](../Context.md))
- `from` (`String`) — the output file being written

### <a id="method-i-render"></a>`#render`

```ruby
def render(meth)
```

**Parameters:**

- `meth` ([`Model::MethodObject`](../Model/MethodObject.md))

**Returns:**

- (`Array<String>`) — markdown blocks

### <a id="method-i-render_attribute"></a>`#render_attribute`

```ruby
def render_attribute(accessors)
```

Renders a reader and/or writer as a single attribute entry.

**Parameters:**

- `accessors` (`Array<`[`Model::MethodObject`](../Model/MethodObject.md)`>`) — the reader, the writer, or both

**Returns:**

- (`Array<String>`) — markdown blocks

### <a id="method-i-signature"></a>`#signature`

```ruby
def signature(meth)
```

**Parameters:**

- `meth` ([`Model::MethodObject`](../Model/MethodObject.md))

**Returns:**

- (`String`) — the method as it would be defined, such as `def self.build(name)`
