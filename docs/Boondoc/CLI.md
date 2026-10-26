# Class: Boondoc::CLI

- **Inherits:** `Thor`
- **Defined in:** [`lib/boondoc/cli.rb`](../../lib/boondoc/cli.rb)

The `boondoc` command.

## Constants

### <a id="constant-COMMANDS"></a>`COMMANDS`

```ruby
COMMANDS = %w[generate serve version help].freeze
```

### <a id="constant-COMMAND_FLAGS"></a>`COMMAND_FLAGS`

```ruby
COMMAND_FLAGS = %w[-h --help -v --version].freeze
```

## Class methods

| Method | Summary |
| --- | --- |
| [`.exit_on_failure?`](#method-c-exit_on_failure-3F) | Returns exit non-zero when a command fails |
| [`.start_with_default(argv)`](#method-c-start_with_default) | Runs the CLI, treating a bare `boondoc [GLOBS]` as `boondoc generate [GLOBS]`. |

### <a id="method-c-exit_on_failure-3F"></a>`.exit_on_failure?`

```ruby
def self.exit_on_failure?
```

**Returns:**

- (`Boolean`) — exit non-zero when a command fails

### <a id="method-c-start_with_default"></a>`.start_with_default`

```ruby
def self.start_with_default(argv)
```

Runs the CLI, treating a bare `boondoc [GLOBS]` as `boondoc generate [GLOBS]`.

**Parameters:**

- `argv` (`Array<String>`)

**Returns:**

- (`void`)

## Instance methods

| Method | Summary |
| --- | --- |
| [`#generate(*globs)`](#method-i-generate) |  |
| [`#serve`](#method-i-serve) |  |
| [`#version`](#method-i-version) |  |

### <a id="method-i-generate"></a>`#generate`

```ruby
def generate(*globs)
```

### <a id="method-i-serve"></a>`#serve`

```ruby
def serve
```

### <a id="method-i-version"></a>`#version`

```ruby
def version
```
