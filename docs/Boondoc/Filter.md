# Class: Boondoc::Filter

- **Defined in:** [`lib/boondoc/filter.rb`](../../lib/boondoc/filter.rb)

Decides which objects appear in the output.

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(config)`](#method-i-initialize) |  |
| [`#visible?(object)`](#method-i-visible-3F) | An object is visible when it and every enclosing namespace pass the visibility options (`--private`, `--protected`). |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(config)
```

**Parameters:**

- `config` ([`Config`](Config.md))

### <a id="method-i-visible-3F"></a>`#visible?`

```ruby
def visible?(object)
```

An object is visible when it and every enclosing namespace pass the
visibility options (`--private`, `--protected`).

**Parameters:**

- `object` ([`Model::CodeObject`](Model/CodeObject.md))

**Returns:**

- (`Boolean`)
