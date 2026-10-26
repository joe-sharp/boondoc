# Module: Boondoc::Containment

- **Defined in:** [`lib/boondoc/containment.rb`](../../lib/boondoc/containment.rb)

Checks that a path stays inside a directory once symlinks are followed.

The project being documented is not trusted to point Boondoc at files
elsewhere on the machine, through `../`, absolute paths, or symlinks.

## Class methods

| Method | Summary |
| --- | --- |
| [`.inside?(path, directory)`](#method-c-inside-3F) | Returns true when the real path of `path` is `directory` or inside it |
| [`.symlink_between(path, directory)`](#method-c-symlink_between) | Finds a symlink on the way from `directory` down to `path`. |

### <a id="method-c-inside-3F"></a>`.inside?`

```ruby
def self.inside?(path, directory)
```

**Parameters:**

- `path` (`String`) — an existing file or directory
- `directory` (`String`)

**Returns:**

- (`Boolean`) — true when the real path of `path` is `directory` or inside it

### <a id="method-c-symlink_between"></a>`.symlink_between`

```ruby
def self.symlink_between(path, directory)
```

Finds a symlink on the way from `directory` down to `path`.

Only the names are looked at (`..` is resolved first), so this also works
for a path that does not exist yet. `directory` itself is not checked.

**Parameters:**

- `path` (`String`) — a path below `directory`, which need not exist
- `directory` (`String`)

**Returns:**

- (`String`, `nil`) — the first component that is a symlink, or nil when
  there is none or `path` is not below `directory`
