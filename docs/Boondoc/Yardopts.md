# Class: Boondoc::Yardopts

- **Defined in:** [`lib/boondoc/yardopts.rb`](../../lib/boondoc/yardopts.rb)

The part of a project's `.yardopts` that Boondoc understands.

Only the source globs, the extra files after `-`, `--files`, `--asset`, `--readme`,
`--title`, `--private`, `--protected`, and `--exclude` are used. `--output-dir`
is left out on purpose: in a `.yardopts` it names YARD's HTML directory, which is
usually ignored by git, while Boondoc's output is meant to be committed.
Everything else is collected in [`#ignored`](#method-i-ignored) so the run can say what was skipped.

**Examples:**

```ruby
Boondoc::Yardopts.parse('--title Foo -o doc lib - CHANGELOG.md').settings
# => { title: "Foo", sources: ["lib"], files: ["CHANGELOG.md"] }
```

## Constants

### <a id="constant-ARGUMENT_OPTIONS"></a>`ARGUMENT_OPTIONS`

```ruby
ARGUMENT_OPTIONS = %w[
      --load --plugin --db --exclude --api --no-api --hide-api --default-return --query --title
      --readme --main --files --asset --output-dir --markup --markup-provider --charset --template
      --template-path --format --locale --po-dir --tag --type-tag --type-name-tag --name-tag
      --title-tag --hide-tag --transitive-tag --non-transitive-tag
    ].freeze
```

Long options of the yard gem that take an argument.

### <a id="constant-FILE"></a>`FILE`

```ruby
FILE = '.yardopts'
```

### <a id="constant-NON_RUBY_SOURCE"></a>`NON_RUBY_SOURCE`

```ruby
NON_RUBY_SOURCE = /\.(?:c|cc|cpp|cxx|h|hpp|y)\z/
```

### <a id="constant-OPTIONAL_ARGUMENT_OPTIONS"></a>`OPTIONAL_ARGUMENT_OPTIONS`

```ruby
OPTIONAL_ARGUMENT_OPTIONS = %w[--use-cache --yardopts --no-yardopts --embed-mixin].freeze
```

Long options whose argument is optional; it is the next token unless that starts with `-`.

### <a id="constant-REGEXP_TIMEOUT"></a>`REGEXP_TIMEOUT`

```ruby
REGEXP_TIMEOUT = 1.0
```

How long a pattern from `--exclude` may take to match one path.

### <a id="constant-SHORT_ARGUMENT_OPTIONS"></a>`SHORT_ARGUMENT_OPTIONS`

```ruby
SHORT_ARGUMENT_OPTIONS = {
      'b' => '--db', 'e' => '--load', 'o' => '--output-dir', 'm' => '--markup', 'M' => '--markup-provider',
      't' => '--template', 'p' => '--template-path', 'f' => '--format', 'r' => '--readme'
    }.freeze
```

### <a id="constant-SHORT_OPTIONAL_ARGUMENT_OPTIONS"></a>`SHORT_OPTIONAL_ARGUMENT_OPTIONS`

```ruby
SHORT_OPTIONAL_ARGUMENT_OPTIONS = { 'c' => '--use-cache' }.freeze
```

## Attributes

### <a id="method-i-exclude"></a>`#exclude`

```ruby
attr_reader :exclude
```

**Returns:**

- (`Array<Regexp>`) — patterns from `--exclude`, matched against source paths

### <a id="method-i-ignored"></a>`#ignored`

```ruby
attr_reader :ignored
```

**Returns:**

- (`Array<String>`) — options and sources that were read but are not used

### <a id="method-i-output_dir"></a>`#output_dir`

```ruby
attr_reader :output_dir
```

**Returns:**

- (`String`, `nil`) — the value of `--output-dir`, which Boondoc does not use

## Class methods

| Method | Summary |
| --- | --- |
| [`.parse(text)`](#method-c-parse) |  |
| [`.read(root)`](#method-c-read) | Returns nil when the project has no `.yardopts` |

### <a id="method-c-parse"></a>`.parse`

```ruby
def self.parse(text)
```

**Parameters:**

- `text` (`String`) — the contents of a `.yardopts`

**Returns:**

- ([`Yardopts`](Yardopts.md))

**Raises:**

- ([`Error`](Error.md)) — when the quoting is unbalanced or an `--exclude` pattern is not a regexp

### <a id="method-c-read"></a>`.read`

```ruby
def self.read(root)
```

**Parameters:**

- `root` (`String`) — project directory

**Returns:**

- ([`Yardopts`](Yardopts.md), `nil`) — nil when the project has no `.yardopts`

**Raises:**

- ([`Error`](Error.md)) — when the file cannot be read or parsed

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(tokens)`](#method-i-initialize) |  |
| [`#notes(output:, root:)`](#method-i-notes) | Returns messages telling the user what was left out |
| [`#settings`](#method-i-settings) | Returns Boondoc options: `sources`, `files`, `assets`, `readme`, `title`, |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(tokens)
```

**Parameters:**

- `tokens` (`Array<String>`) — the file split into words, the way a shell would

### <a id="method-i-notes"></a>`#notes`

```ruby
def notes(output:, root:)
```

**Parameters:**

- `output` (`String`) — the output directory Boondoc will use
- `root` (`String`) — project directory, for comparing paths

**Returns:**

- (`Array<String>`) — messages telling the user what was left out

### <a id="method-i-settings"></a>`#settings`

```ruby
def settings
```

**Returns:**

- (`Hash{Symbol => Object}`) — Boondoc options: `sources`, `files`, `assets`, `readme`, `title`,
  `private`, and `protected`, for those that were given
