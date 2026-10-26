# Class: Boondoc::References

- **Defined in:** [`lib/boondoc/references.rb`](../../lib/boondoc/references.rb)

Expands YARD reference docstrings: `(see Foo#bar)` as a whole docstring, or
as the text of a tag such as `@param (see Foo#bar)`.

## Constants

### <a id="constant-SEE"></a>`SEE`

```ruby
SEE = /\A\(see (\S+)\)\z/
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(registry)`](#method-i-initialize) |  |
| [`#expand`](#method-i-expand) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(registry)
```

**Parameters:**

- `registry` ([`Model::Registry`](Model/Registry.md))

### <a id="method-i-expand"></a>`#expand`

```ruby
def expand
```

**Returns:**

- (`void`)
