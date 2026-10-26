# Module: Sample::Util

- **Defined in:** [`lib/sample/util.rb`](../../lib/sample/util.rb)

Stateless helpers.

## Class methods

| Method | Summary |
| --- | --- |
| [`.clamp(value, min: 0, max: 1)`](#method-c-clamp) |  |
| [`.scale(shape, factor)`](#method-c-scale) | Scales a shape. |

### <a id="method-c-clamp"></a>`.clamp`

```ruby
def self.clamp(value, min: 0, max: 1)
```

**Parameters:**

- `value` (`Numeric`, `#to_f`)

**Returns:**

- (`Float`)

- **API:** public
- **Custom tag:** some text

### <a id="method-c-scale"></a>`.scale`

```ruby
def self.scale(shape, factor)
```

Scales a shape.

**Parameters:**

- `shape` ([`Circle`](Circle.md)) — the shape to scale
- `factor` (`Numeric`)

**Returns:**

- ([`Circle`](Circle.md))
