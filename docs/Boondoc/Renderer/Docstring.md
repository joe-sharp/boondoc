# Class: Boondoc::Renderer::Docstring

- **Inherits:** [`Boondoc::Renderer::Base`](Base.md)
- **Defined in:** [`lib/boondoc/renderer/docstring.rb`](../../../lib/boondoc/renderer/docstring.rb)

Renders a docstring: callouts, body, then one section per kind of tag.

## Constants

### <a id="constant-CALLOUTS"></a>`CALLOUTS`

```ruby
CALLOUTS = { 'deprecated' => 'Deprecated', 'abstract' => 'Abstract', 'note' => 'Note',
                   'todo' => 'Todo' }.freeze
```

### <a id="constant-HANDLED"></a>`HANDLED`

```ruby
HANDLED = (CALLOUTS.keys + TYPED.keys + META.keys +
                 %w[param option yield example see overload private attr attr_reader attr_writer]).freeze
```

### <a id="constant-META"></a>`META`

```ruby
META = { 'since' => 'Since', 'version' => 'Version', 'author' => 'Author', 'api' => 'API' }.freeze
```

### <a id="constant-TYPED"></a>`TYPED`

```ruby
TYPED = { 'yieldparam' => 'Yield parameters', 'yieldreturn' => 'Yield returns',
                'return' => 'Returns', 'raise' => 'Raises' }.freeze
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(context, object, from)`](#method-i-initialize) |  |
| [`#render(docstring)`](#method-i-render) | Returns markdown blocks, in order |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(context, object, from)
```

**Parameters:**

- `context` ([`Context`](../Context.md))
- `object` ([`Model::CodeObject`](../Model/CodeObject.md)) — the object being documented
- `from` (`String`) — the output file being written

### <a id="method-i-render"></a>`#render`

```ruby
def render(docstring)
```

**Parameters:**

- `docstring` ([`Model::Docstring`](../Model/Docstring.md))

**Returns:**

- (`Array<String>`) — markdown blocks, in order
