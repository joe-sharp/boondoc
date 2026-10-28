# Class: Boondoc::Config

- **Defined in:** [`lib/boondoc/config.rb`](../../lib/boondoc/config.rb)

Options for one run, merged from defaults, `.yardopts`, `.boondoc.yml`, and the command line.

## Constants

### <a id="constant-CHECKS"></a>`CHECKS`

```ruby
CHECKS = {
      list: [->(value) { value.is_a?(String) || (value.is_a?(Array) && value.all?(String)) },
             "a string or a list of strings"],
      string: [->(value) { value.is_a?(String) }, "a string"],
      optional_string: [->(value) { value.nil? || value.is_a?(String) }, "a string"],
      file_or_false: [->(value) { value.nil? || value == false || value.is_a?(String) }, "a file name or false"],
      boolean: [->(value) { [true, false].include?(value) }, "true or false"]
    }.freeze
```

A test and a description for each type name in [`TYPES`](#constant-TYPES).

### <a id="constant-DEFAULTS"></a>`DEFAULTS`

```ruby
DEFAULTS = {
      sources: ["lib/**/*.rb"], exclude: [], output: "docs", index: "README.md",
      readme: nil, files: [], assets: [], copy_linked_assets: false, title: nil,
      private: false, protected: false, yard_macros: false,
      strict: false, force: false, quiet: false, allow_outside_output: false, yardopts: true
    }.freeze
```

### <a id="constant-FILE"></a>`FILE`

```ruby
FILE = ".boondoc.yml"
```

### <a id="constant-TYPES"></a>`TYPES`

```ruby
TYPES = {
      sources: :list, exclude: :list, files: :list, assets: :list, copy_linked_assets: :boolean,
      output: :string, index: :string, readme: :file_or_false, title: :optional_string,
      private: :boolean, protected: :boolean, yard_macros: :boolean, strict: :boolean,
      force: :boolean, quiet: :boolean, allow_outside_output: :boolean, yardopts: :boolean
    }.freeze
```

What each option accepts: a type name from [`CHECKS`](#constant-CHECKS) per key.

## Attributes

### <a id="method-i-root"></a>`#root`

```ruby
attr_reader :root
```

**Returns:**

- (`String`) — absolute path of the project being documented

## Class methods

| Method | Summary |
| --- | --- |
| [`.load(overrides = {}, root: Dir.pwd)`](#method-c-load) | Builds a config from `.yardopts` and `.boondoc.yml` (if present) with `overrides` on top. |

### <a id="method-c-load"></a>`.load`

```ruby
def self.load(overrides = {}, root: Dir.pwd)
```

Builds a config from `.yardopts` and `.boondoc.yml` (if present) with `overrides` on top.
Each option comes from the highest of those that sets it; lists are replaced, not merged.
`.yardopts` is skipped when `yardopts` is false in the file or the overrides.

**Parameters:**

- `overrides` (`Hash{Symbol => Object}`) — options that win over the file;
  `:config` names an alternative config file
- `root` (`String`) — project directory

**Returns:**

- ([`Config`](Config.md))

**Raises:**

- ([`Error`](Error.md)) — when the config file is missing, has unknown keys, or tries
  to set `allow_outside_output`, which only the caller may do

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(root: Dir.pwd, from_yardopts: nil, **options)`](#method-i-initialize) |  |
| [`#extra_files`](#method-i-extra_files) | Returns extra files to stitch in, relative to [`#root`](#method-i-root) |
| [`#output_dir`](#method-i-output_dir) | Returns absolute path of the output directory |
| [`#outside_sources`](#method-i-outside_sources) | Returns sources that resolve outside the project, through an |
| [`#readme_file`](#method-i-readme_file) | Returns the README to use as the index page, relative to [`#root`](#method-i-root) |
| [`#source_files`](#method-i-source_files) | Returns Ruby files to parse, relative to [`#root`](#method-i-root); files |
| [`#title`](#method-i-title) | Returns the documentation title; defaults to the project directory name |
| [`#yardopts_notes`](#method-i-yardopts_notes) | Returns what the run ignores from `.yardopts`, such as its `--output-dir` |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(root: Dir.pwd, from_yardopts: nil, **options)
```

**Parameters:**

- `root` (`String`) — project directory
- `from_yardopts` ([`Yardopts`](Yardopts.md), `nil`) — the project's `.yardopts`, whose `--exclude`
  patterns apply unless `exclude` is given and whose skipped options are reported
  by [`#yardopts_notes`](#method-i-yardopts_notes); its other settings are expected in `options` already
- `options` (`Hash{Symbol => Object}`) — any of the keys in [`DEFAULTS`](#constant-DEFAULTS)

**Raises:**

- ([`Error`](Error.md)) — on unknown options, or an option of the wrong type

### <a id="method-i-extra_files"></a>`#extra_files`

```ruby
def extra_files
```

**Returns:**

- (`Array<String>`) — extra files to stitch in, relative to [`#root`](#method-i-root)

**Raises:**

- ([`Error`](Error.md)) — when a file is outside the project

### <a id="method-i-output_dir"></a>`#output_dir`

```ruby
def output_dir
```

**Returns:**

- (`String`) — absolute path of the output directory

**Raises:**

- ([`Error`](Error.md)) — when it is outside the project and `allow_outside_output`
  is not set, or when it is reached through a symlink inside the project

### <a id="method-i-outside_sources"></a>`#outside_sources`

```ruby
def outside_sources
```

**Returns:**

- (`Array<String>`) — sources that resolve outside the project, through an
  absolute path, `../`, or a symlink, and are therefore not parsed

### <a id="method-i-readme_file"></a>`#readme_file`

```ruby
def readme_file
```

**Returns:**

- (`String`, `nil`) — the README to use as the index page, relative to [`#root`](#method-i-root)

**Raises:**

- ([`Error`](Error.md)) — when an explicitly named README does not exist or is outside the project

### <a id="method-i-source_files"></a>`#source_files`

```ruby
def source_files
```

**Returns:**

- (`Array<String>`) — Ruby files to parse, relative to [`#root`](#method-i-root); files
  that resolve outside the project are left out, see [`#outside_sources`](#method-i-outside_sources)

### <a id="method-i-title"></a>`#title`

```ruby
def title
```

**Returns:**

- (`String`) — the documentation title; defaults to the project directory name

### <a id="method-i-yardopts_notes"></a>`#yardopts_notes`

```ruby
def yardopts_notes
```

**Returns:**

- (`Array<String>`) — what the run ignores from `.yardopts`, such as its `--output-dir`
