# Class: Boondoc::Generator

- **Defined in:** [`lib/boondoc/generator.rb`](../../lib/boondoc/generator.rb)

Runs the whole pipeline: parse, resolve, render, write.

**Examples:**

```ruby
Boondoc::Generator.new(Boondoc::Config.new(output: 'docs')).run
```

## Namespaces

- [`Boondoc::Generator::Result`](Generator/Result.md) — What a run produced.

## Attributes

### <a id="method-i-registry"></a>`#registry`

```ruby
attr_reader :registry
```

**Returns:**

- ([`Model::Registry`](Model/Registry.md)) — the registry built by the last [`#run`](#method-i-run)

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(config, reporter: Reporter.new(quiet: config.quiet))`](#method-i-initialize) |  |
| [`#parse(files)`](#method-i-parse) | Parses the given files into a fresh registry. |
| [`#render`](#method-i-render) | Builds every page without writing anything. |
| [`#run`](#method-i-run) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(config, reporter: Reporter.new(quiet: config.quiet))
```

**Parameters:**

- `config` ([`Config`](Config.md))
- `reporter` ([`Reporter`](Reporter.md))

### <a id="method-i-parse"></a>`#parse`

```ruby
def parse(files)
```

Parses the given files into a fresh registry.

**Parameters:**

- `files` (`Array<String>`) — paths relative to the project root

**Returns:**

- ([`Model::Registry`](Model/Registry.md))

### <a id="method-i-render"></a>`#render`

```ruby
def render
```

Builds every page without writing anything.

**Returns:**

- (`Hash{String => String}`) — page content keyed by path relative to the output directory

### <a id="method-i-run"></a>`#run`

```ruby
def run
```

**Returns:**

- ([`Result`](Generator/Result.md))

**Raises:**

- ([`Error`](Error.md)) — when no source files match, the output directory is unsafe,
  a file would be overwritten, or `strict` is set and there were warnings
