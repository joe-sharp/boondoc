# Class: Boondoc::RakeTask

- **Inherits:** `::Rake::TaskLib`
- **Defined in:** [`lib/boondoc/rake_task.rb`](../../lib/boondoc/rake_task.rb)

Defines a Rake task that generates the documentation.

**Examples:**

```ruby
require 'boondoc/rake_task'

Boondoc::RakeTask.new(:docs) do |t|
  t.options = { output: 'docs', files: ['CHANGELOG.md'], strict: true }
end
```

## Attributes

### <a id="method-i-name"></a><a id="method-i-name-3D"></a>`#name`

```ruby
attr_accessor :name
```

**Returns:**

- (`Symbol`) — the task name

### <a id="method-i-options"></a><a id="method-i-options-3D"></a>`#options`

```ruby
attr_accessor :options
```

**Returns:**

- (`Hash{Symbol => Object}`) — options passed to [`Config.load`](Config.md#method-c-load)

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(name = :docs)`](#method-i-initialize) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(name = :docs)
```

**Parameters:**

- `name` (`Symbol`)

**Yield parameters:**

- `task` ([`RakeTask`](RakeTask.md)) — the task, for setting [`#options`](#method-i-options)
