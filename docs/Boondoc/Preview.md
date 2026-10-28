# Class: Boondoc::Preview

- **Defined in:** [`lib/boondoc/preview.rb`](../../lib/boondoc/preview.rb)

Serves generated docs locally using the `gh markdown-preview` extension of
the GitHub CLI.

The previewer resolves links relative to the directory it was started in,
so it is always started from inside the output directory.

## Constants

### <a id="constant-DEFAULT_HOST"></a>`DEFAULT_HOST`

```ruby
DEFAULT_HOST = "127.0.0.1"
```

### <a id="constant-EXTENSION"></a>`EXTENSION`

```ruby
EXTENSION = "yusukebe/gh-markdown-preview"
```

### <a id="constant-LOOPBACK_HOSTS"></a>`LOOPBACK_HOSTS`

```ruby
LOOPBACK_HOSTS = %w[::1 localhost].freeze
```

### <a id="constant-SILENT"></a>`SILENT`

```ruby
SILENT = { out: File::NULL, err: File::NULL }.freeze
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(directory, host: DEFAULT_HOST, port: nil, &confirm_install)`](#method-i-initialize) |  |
| [`#start`](#method-i-start) | Starts the previewer and blocks until it exits. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(directory, host: DEFAULT_HOST, port: nil, &confirm_install)
```

**Parameters:**

- `directory` (`String`) — the directory holding the generated docs
- `host` (`String`) — address the previewer binds to
- `port` (`Integer`, `nil`) — port to listen on; the previewer's default when nil

**Yield returns:**

- (`Boolean`) — whether the extension may be installed; asked only
  when it is missing

### <a id="method-i-start"></a>`#start`

```ruby
def start
```

Starts the previewer and blocks until it exits.

**Returns:**

- (`void`)

**Raises:**

- ([`Error`](Error.md)) — when the docs, the GitHub CLI, or the extension are missing
