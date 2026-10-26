# Module: Sample

- **Defined in:** [`lib/sample.rb`](../lib/sample.rb), [`lib/sample/circle.rb`](../lib/sample/circle.rb), [`lib/sample/shape.rb`](../lib/sample/shape.rb), [`lib/sample/util.rb`](../lib/sample/util.rb)

A tiny geometry library used to exercise boondoc.

Start with [`Sample::Circle`](Sample/Circle.md), or read the [guide](files/guides/intro.md).
A hash literal like {radius: 2} is left alone.

    # indented code keeps its braces: {Sample::Circle}
    Sample::Circle.new(2)

- **Since:** 0.1.0

## Namespaces

- [`Sample::Circle`](Sample/Circle.md) — A circle.
- [`Sample::Error`](Sample/Error.md) — Raised when a shape cannot be built.
- [`Sample::Point`](Sample/Point.md) — A 2D point.
- [`Sample::Shape`](Sample/Shape.md) — Base class for all shapes.
- [`Sample::Util`](Sample/Util.md) — Stateless helpers.

## Constants

### <a id="constant-VERSION"></a>`VERSION`

```ruby
VERSION = '1.2.3'
```

The current version.
