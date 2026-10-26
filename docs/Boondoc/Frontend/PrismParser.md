# Class: Boondoc::Frontend::PrismParser

- **Defined in:** [`lib/boondoc/frontend/prism_parser.rb`](../../../lib/boondoc/frontend/prism_parser.rb)

Parses Ruby files with Prism and fills a [`Model::Registry`](../Model/Registry.md).

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(registry, reporter)`](#method-i-initialize) |  |
| [`#parse(source, label = '(source)')`](#method-i-parse) |  |
| [`#parse_file(path, label: path)`](#method-i-parse_file) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(registry, reporter)
```

**Parameters:**

- `registry` ([`Model::Registry`](../Model/Registry.md))
- `reporter` ([`Reporter`](../Reporter.md))

### <a id="method-i-parse"></a>`#parse`

```ruby
def parse(source, label = '(source)')
```

**Parameters:**

- `source` (`String`) — Ruby source
- `label` (`String`) — file name to record on objects

**Returns:**

- (`void`)

### <a id="method-i-parse_file"></a>`#parse_file`

```ruby
def parse_file(path, label: path)
```

**Parameters:**

- `path` (`String`) — file to parse
- `label` (`String`) — the path to record on objects (usually relative to the project)

**Returns:**

- (`void`)
