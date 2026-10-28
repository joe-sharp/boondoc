# Class: Boondoc::Frontend::Visitor

- **Inherits:** `::Prism::Visitor`
- **Defined in:** [`lib/boondoc/frontend/visitor.rb`](../../../lib/boondoc/frontend/visitor.rb)

Walks a Prism tree and registers namespaces, methods, and constants.

Method bodies are never entered, so only definitions made at class, module
or top level are documented.

## Namespaces

- [`Boondoc::Frontend::Visitor::Frame`](Visitor/Frame.md) — The state that applies while visiting one namespace body.

## Constants

### <a id="constant-ALWAYS_PRIVATE"></a>`ALWAYS_PRIVATE`

```ruby
ALWAYS_PRIVATE = %w[initialize_copy initialize_clone initialize_dup respond_to_missing?].freeze
```

### <a id="constant-ANONYMOUS"></a>`ANONYMOUS`

```ruby
ANONYMOUS = { "Struct" => :new, "Data" => :define, "Class" => :new, "Module" => :new }.freeze
```

### <a id="constant-ATTR_READERS_ONLY"></a>`ATTR_READERS_ONLY`

```ruby
ATTR_READERS_ONLY = %i[attr attr_reader].freeze
```

### <a id="constant-CALLS"></a>`CALLS`

```ruby
CALLS = {
        attr: :on_attr, attr_reader: :on_attr, attr_writer: :on_attr, attr_accessor: :on_attr,
        public: :on_visibility, protected: :on_visibility, private: :on_visibility,
        private_class_method: :on_class_visibility, public_class_method: :on_class_visibility,
        module_function: :on_module_function, private_constant: :on_private_constant,
        alias_method: :on_alias_method, define_method: :on_define_method,
        include: :on_mixin, extend: :on_mixin, prepend: :on_mixin
      }.freeze
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(registry, file, comments)`](#method-i-initialize) |  |
| [`#visit_alias_method_node(node)`](#method-i-visit_alias_method_node) |  |
| [`#visit_call_node(node)`](#method-i-visit_call_node) |  |
| [`#visit_class_node(node)`](#method-i-visit_class_node) |  |
| [`#visit_constant_write_node(node)`](#method-i-visit_constant_write_node) |  |
| [`#visit_def_node(node)`](#method-i-visit_def_node) |  |
| [`#visit_module_node(node)`](#method-i-visit_module_node) |  |
| [`#visit_singleton_class_node(node)`](#method-i-visit_singleton_class_node) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(registry, file, comments)
```

**Parameters:**

- `registry` ([`Model::Registry`](../Model/Registry.md))
- `file` (`String`) — file name recorded on each object
- `comments` ([`Comments`](Comments.md))

### <a id="method-i-visit_alias_method_node"></a>`#visit_alias_method_node`

```ruby
def visit_alias_method_node(node)
```

### <a id="method-i-visit_call_node"></a>`#visit_call_node`

```ruby
def visit_call_node(node)
```

### <a id="method-i-visit_class_node"></a>`#visit_class_node`

```ruby
def visit_class_node(node)
```

### <a id="method-i-visit_constant_write_node"></a>`#visit_constant_write_node`

```ruby
def visit_constant_write_node(node)
```

### <a id="method-i-visit_def_node"></a>`#visit_def_node`

```ruby
def visit_def_node(node)
```

### <a id="method-i-visit_module_node"></a>`#visit_module_node`

```ruby
def visit_module_node(node)
```

### <a id="method-i-visit_singleton_class_node"></a>`#visit_singleton_class_node`

```ruby
def visit_singleton_class_node(node)
```
