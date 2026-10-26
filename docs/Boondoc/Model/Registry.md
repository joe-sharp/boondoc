# Class: Boondoc::Model::Registry

- **Includes:** `Enumerable`
- **Defined in:** [`lib/boondoc/model/registry.rb`](../../../lib/boondoc/model/registry.rb)

Every documented object, keyed by path, with YARD-style reference lookup.

## Constants

### <a id="constant-REFERENCE"></a>`REFERENCE`

```ruby
REFERENCE = /\A(?<const>(?:::)?[A-Z]\w*(?:::[A-Z]\w*)*)?(?:(?<sep>#|\.|::)(?<meth>[^A-Z:].*))?\z/
```

## Attributes

### <a id="method-i-directive_sites"></a>`#directive_sites`

```ruby
attr_reader :directive_sites
```

**Returns:**

- (`Array<String>`) — `file:line` locations of comments that use YARD directives

### <a id="method-i-root"></a>`#root`

```ruby
attr_reader :root
```

**Returns:**

- ([`NamespaceObject`](NamespaceObject.md)) — the top-level namespace

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize`](#method-i-initialize) |  |
| [`#[](path)`](#method-i--5B-5D) |  |
| [`#ancestors(namespace)`](#method-i-ancestors) | Returns the namespace followed by its documented |
| [`#delete(object)`](#method-i-delete) |  |
| [`#directive_files`](#method-i-directive_files) | Returns the files that contain YARD directives, in the order they were parsed |
| [`#each(&)`](#method-i-each) |  |
| [`#register(object)`](#method-i-register) | Adds an object, replacing any existing object at the same path. |
| [`#resolve(context, reference)`](#method-i-resolve) | Resolves a reference such as `Foo::Bar`, `Foo#bar`, `#bar`, or `bar` as seen from `context`, searching enclosing namespaces and ancestors. |
| [`#superclass(namespace)`](#method-i-superclass) | Like Ruby, looks the superclass up from the scope around the class, and never finds the class itself, so `class Error < Error` inside a module refers to an outer `Error`. |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize
```

### <a id="method-i--5B-5D"></a>`#[]`

```ruby
def [](path)
```

**Parameters:**

- `path` (`String`)

**Returns:**

- ([`CodeObject`](CodeObject.md), `nil`)

### <a id="method-i-ancestors"></a>`#ancestors`

```ruby
def ancestors(namespace)
```

**Parameters:**

- `namespace` ([`NamespaceObject`](NamespaceObject.md))

**Returns:**

- (`Array<`[`NamespaceObject`](NamespaceObject.md)`>`) — the namespace followed by its documented
  mixins and superclasses, nearest first

### <a id="method-i-delete"></a>`#delete`

```ruby
def delete(object)
```

**Parameters:**

- `object` ([`CodeObject`](CodeObject.md), `nil`)

**Returns:**

- (`void`)

### <a id="method-i-directive_files"></a>`#directive_files`

```ruby
def directive_files
```

**Returns:**

- (`Array<String>`) — the files that contain YARD directives, in the order they were parsed

### <a id="method-i-each"></a>`#each`

```ruby
def each(&)
```

**Yield parameters:**

- `object` ([`CodeObject`](CodeObject.md))

### <a id="method-i-register"></a>`#register`

```ruby
def register(object)
```

Adds an object, replacing any existing object at the same path.

**Parameters:**

- `object` ([`CodeObject`](CodeObject.md))

**Returns:**

- ([`CodeObject`](CodeObject.md)) — the object

### <a id="method-i-resolve"></a>`#resolve`

```ruby
def resolve(context, reference)
```

Resolves a reference such as `Foo::Bar`, `Foo#bar`, `#bar`, or `bar` as
seen from `context`, searching enclosing namespaces and ancestors.

**Parameters:**

- `context` ([`CodeObject`](CodeObject.md)) — where the reference was written
- `reference` (`String`)

**Returns:**

- ([`CodeObject`](CodeObject.md), `nil`)

### <a id="method-i-superclass"></a>`#superclass`

```ruby
def superclass(namespace)
```

Like Ruby, looks the superclass up from the scope around the class, and
never finds the class itself, so `class Error < Error` inside a module
refers to an outer `Error`.

**Parameters:**

- `namespace` ([`NamespaceObject`](NamespaceObject.md))

**Returns:**

- ([`NamespaceObject`](NamespaceObject.md), `nil`) — the documented superclass
