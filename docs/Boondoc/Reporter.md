# Class: Boondoc::Reporter

- **Defined in:** [`lib/boondoc/reporter.rb`](../../lib/boondoc/reporter.rb)

Collects warnings and prints progress messages.

## Attributes

### <a id="method-i-warnings"></a>`#warnings`

```ruby
attr_reader :warnings
```

**Returns:**

- (`Array<String>`) — every warning raised so far

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(io: $stderr, quiet: false)`](#method-i-initialize) |  |
| [`#info(message)`](#method-i-info) | Prints an informational message unless quiet. |
| [`#warn(message)`](#method-i-warn) | Records and prints a warning. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(io: $stderr, quiet: false)
```

**Parameters:**

- `io` (`IO`) — where messages are written
- `quiet` (`Boolean`) — suppress informational messages (warnings still print)

### <a id="method-i-info"></a>`#info`

```ruby
def info(message)
```

Prints an informational message unless quiet.

**Parameters:**

- `message` (`String`)

**Returns:**

- (`void`)

### <a id="method-i-warn"></a>`#warn`

```ruby
def warn(message)
```

Records and prints a warning. Repeats of the same message are ignored.

**Parameters:**

- `message` (`String`)

**Returns:**

- (`void`)
