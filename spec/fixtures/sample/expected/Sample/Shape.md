# Class: Sample::Shape

- **Includes:** `Comparable`
- **Defined in:** [`lib/sample/shape.rb`](../../lib/sample/shape.rb)

> **Abstract:** Subclass and implement [`#area`](#method-i-area).

Base class for all shapes.

## Attributes

### <a id="method-i-count"></a>`#count`

```ruby
attr_reader :count
```

**Returns:**

- (`Integer`) — how many shapes have been built

### <a id="method-i-name"></a><a id="method-i-name-3D"></a>`#name`

```ruby
attr_accessor :name
```

**Returns:**

- (`String`) — a label used in [`#to_s`](#method-i-to_s)

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(name)`](#method-i-initialize) |  |
| [`#<=>(other)`](#method-i--3C-3D-3E) | Compares shapes by [`#area`](#method-i-area). |
| [`#area`](#method-i-area) | Computes the area. |
| [`#empty?`](#method-i-empty-3F) | Returns whether the shape has no area |
| [`#inspect`](#method-i-inspect) | Human readable description. |
| [`#to_s`](#method-i-to_s) | Human readable description. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(name)
```

**Parameters:**

- `name` (`String`) — a label for the shape

### <a id="method-i--3C-3D-3E"></a>`#<=>`

```ruby
def <=>(other)
```

Compares shapes by [`#area`](#method-i-area).

**Parameters:**

- `other` ([`Shape`](Shape.md))

**Returns:**

- (`Integer`, `nil`)

### <a id="method-i-area"></a>`#area`

```ruby
def area
```

Computes the area.

**Returns:**

- (`Float`) — the area in square units

**Raises:**

- (`NotImplementedError`) — unless overridden

### <a id="method-i-empty-3F"></a>`#empty?`

```ruby
def empty?
```

**Returns:**

- (`Boolean`) — whether the shape has no area

### <a id="method-i-inspect"></a>`#inspect`

```ruby
def inspect
```

- **Alias for:** [`#to_s`](#method-i-to_s)

Human readable description.

**Returns:**

- (`String`)

### <a id="method-i-to_s"></a>`#to_s`

```ruby
def to_s
```

- **Also known as:** [`#inspect`](#method-i-inspect)

Human readable description.

**Returns:**

- (`String`)
