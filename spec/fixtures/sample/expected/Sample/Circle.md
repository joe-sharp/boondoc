# Class: Sample::Circle

- **Inherits:** [`Sample::Shape`](Shape.md)
- **Defined in:** [`lib/sample/circle.rb`](../../lib/sample/circle.rb)

A circle.

**Examples:**

*Build one and measure it*

```ruby
circle = Sample::Circle.new(2)
circle.area #=> 12.566370614359172
```

**See also:**

- [`Shape`](Shape.md)
- <https://en.wikipedia.org/wiki/Circle> — Circle on Wikipedia

## Constants

### <a id="constant-TAU"></a>`TAU`

```ruby
TAU = Math::PI * 2
```

Circles per turn.

## Attributes

### <a id="method-i-radius"></a>`#radius`

```ruby
attr_reader :radius
```

**Returns:**

- (`Numeric`)

## Class methods

| Method | Summary |
| --- | --- |
| [`.from_diameter(diameter, options = {})`](#method-c-from_diameter) | Builds a circle from its diameter. |
| [`.unit`](#method-c-unit) | A broken link to {Missing::Thing} for the warning test. |

### <a id="method-c-from_diameter"></a>`.from_diameter`

```ruby
def self.from_diameter(diameter, options = {})
```

Builds a circle from its diameter.

**Parameters:**

- `diameter` (`Numeric`)
- `options` (`Hash`) — extra settings
  - `:name` (`String`) — label for the shape (default: `"circle"`)
  - `:strict` (`Boolean`) — reject non-positive sizes

**Returns:**

- ([`Circle`](Circle.md))

**Raises:**

- ([`Sample::Error`](Error.md)) — when the diameter is not positive and strict is set

### <a id="method-c-unit"></a>`.unit`

```ruby
def self.unit
```

A broken link to {Missing::Thing} for the warning test.

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(radius, name: 'circle')`](#method-i-initialize) |  |
| [`#area`](#method-i-area) | Computes the area. |
| [`#points`](#method-i-points) | Returns points on the edge, or nil when [`#empty?`](Shape.md#method-i-empty-3F) |
| [`#scale(factor)`](#method-i-scale) | **Deprecated.** Scales the circle. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(radius, name: 'circle')
```

**Parameters:**

- `radius` (`Numeric`) — must be positive
- `name` (`String`)

### <a id="method-i-area"></a>`#area`

```ruby
def area
```

Computes the area.

**Returns:**

- (`Float`) — the area in square units

**Raises:**

- (`NotImplementedError`) — unless overridden

### <a id="method-i-points"></a>`#points`

```ruby
def points
```

> **Note:** This is approximate for very large radii.

> **Todo:** Support a custom step.

**Returns:**

- (`Array<`[`Point`](Point.md)`>`, `nil`) — points on the edge, or nil when [`#empty?`](Shape.md#method-i-empty-3F)

### <a id="method-i-scale"></a>`#scale`

```ruby
def scale(factor)
```

> **Deprecated:** Use [`Util.scale`](Util.md#method-c-scale) instead.

Scales the circle.

**Overload:**

```ruby
def scale(factor)
```

**Parameters:**

- `factor` (`Numeric`) — multiplier for the radius

**Returns:**

- ([`Circle`](Circle.md)) — a new, scaled circle

**Overload:**

```ruby
def scale(factor, &block)
```

**Yields:**

- (`radius`) — lets the caller adjust the scaled radius

**Yield parameters:**

- `radius` (`Numeric`) — the scaled radius

**Yield returns:**

- (`Numeric`) — the radius to use

**Returns:**

- ([`Circle`](Circle.md))

## Inherited methods

- From [`Sample::Shape`](Shape.md): [`#<=>`](Shape.md#method-i--3C-3D-3E), [`#count`](Shape.md#method-i-count), [`#empty?`](Shape.md#method-i-empty-3F), [`#inspect`](Shape.md#method-i-inspect), [`#name`](Shape.md#method-i-name), [`#name=`](Shape.md#method-i-name-3D), [`#to_s`](Shape.md#method-i-to_s)
