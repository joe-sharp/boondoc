# Class: Boondoc::Renderer::NamespacePage

- **Inherits:** [`Boondoc::Renderer::Base`](Base.md)
- **Defined in:** [`lib/boondoc/renderer/namespace_page.rb`](../../../lib/boondoc/renderer/namespace_page.rb)

Renders the page for one class or module, or for the top-level namespace.

## Constants

### <a id="constant-MAX_CONSTANT_LINES"></a>`MAX_CONSTANT_LINES`

```ruby
MAX_CONSTANT_LINES = 12
```

### <a id="constant-MAX_SUPERCLASS_CHAIN"></a>`MAX_SUPERCLASS_CHAIN`

```ruby
MAX_SUPERCLASS_CHAIN = 20
```

A guard against a superclass chain that never ends; real chains are far shorter.

### <a id="constant-MIXINS"></a>`MIXINS`

```ruby
MIXINS = { include: "Includes", extend: "Extended by", prepend: "Prepended by" }.freeze
```

### <a id="constant-SCOPES"></a>`SCOPES`

```ruby
SCOPES = { class: "Class methods", instance: "Instance methods" }.freeze
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(context, namespace)`](#method-i-initialize) |  |
| [`#content?`](#method-i-content-3F) | Returns false when there is nothing worth writing a page for |
| [`#render`](#method-i-render) | Returns the whole page |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(context, namespace)
```

**Parameters:**

- `context` ([`Context`](../Context.md))
- `namespace` ([`Model::NamespaceObject`](../Model/NamespaceObject.md))

### <a id="method-i-content-3F"></a>`#content?`

```ruby
def content?
```

**Returns:**

- (`Boolean`) — false when there is nothing worth writing a page for

### <a id="method-i-render"></a>`#render`

```ruby
def render
```

**Returns:**

- (`String`) — the whole page
