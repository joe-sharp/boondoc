# Contributor familiarity guide

A map of the Boondoc codebase for new contributors: what each part does, how
the parts connect, and where to start for common changes.

## What Boondoc is

Boondoc is a Ruby gem that generates API documentation as plain
GitHub-flavored Markdown instead of HTML. It reads the YARD-style comments a
codebase already has, such as `@param`, `@return`, and `{Foo#bar}`. It writes
one `.md` file per class or module plus an index page, with relative links
between them, so the output renders as-is on GitHub or in an editor preview.

- **Runtime dependencies:** `prism` for parsing and `thor` for the CLI. `yard`
  is optional and loaded only for `--yard-macros`.
- **Ruby:** 3.3 or newer.
- **Size:** about 2,800 lines in `lib/`. The largest file is
  `lib/boondoc/frontend/visitor.rb`, at about 360 lines.
- **Design principle:** Markdown from start to finish. Docstrings are passed
  through unchanged, and the only HTML in the output is the explicit method
  anchors.

## The pipeline

Every run goes through `Generator#run` (`lib/boondoc/generator.rb`), which has
four stages:

```
 Ruby files
     │
     ▼
 1. Parse     PrismParser → Visitor → Model::Registry
     │
     ▼
 2. Resolve   YardBridge (only with --yard-macros) → References
     │
     ▼
 3. Render    Context { Filter, PathMap, Stitcher, Linker }
     │        → Renderer::Index, Renderer::NamespacePage
     ▼        → { "Foo/Bar.md" => "markdown…" }
 4. Write     Writer + .boondoc-manifest
     │
     ▼
 docs/
```

`Generator#parse` covers stages 1 and 2, and `Generator#render` covers stage 3.
Both are public, so tests can run them without writing to disk (see
`render_fixture` in `spec/support/fixture_helper.rb`).

## Stage 1: Parse

The parse stage turns Ruby source into a registry of documented objects,
without ever running the code. The work lives in `lib/boondoc/frontend/` and
`lib/boondoc/model/`.

| Component | File | Role |
| --- | --- | --- |
| `Frontend::PrismParser` | `frontend/prism_parser.rb` | Parses each file with Prism and runs the visitor over the tree. |
| `Frontend::Comments` | `frontend/comments.rb` | Attaches each comment block to the line below it and honors `:nodoc:`. |
| `Frontend::Visitor` | `frontend/visitor.rb` | Walks the tree and registers namespaces, methods, attributes, constants, aliases and mixins. |
| `Model::Registry` | `model/registry.rb` | Stores every object by path, such as `Foo::Bar#baz`, and resolves references. |
| `Model::CodeObject` and subclasses | `model/code_object.rb` | `NamespaceObject`, `MethodObject`, and `ConstantObject`, each carrying a docstring, a visibility and its definition sites. |
| `Model::Docstring` | `model/docstring.rb` | Holds the prose and the tags of one comment. |
| `DocstringParser` | `docstring_parser.rb` | Splits comment text into prose and `@tags`. |
| `TypeParser` | `type_parser.rb` | Parses type lists such as `[Array<String>, nil]`. |

Things to know about `Visitor`:

- It **never enters method bodies**, so only definitions at class, module or
  top level are documented.
- It keeps a stack of `Frame`s (namespace, visibility, singleton,
  `module_function`), which is how it tracks `private`, `private def`,
  `class << self`, `private_class_method`, and `module_function`.
- Supported calls are listed in its `CALLS` table. To support a new DSL call,
  add a row there and a handler method.
- It recognizes anonymous namespaces assigned to constants: `Struct.new`,
  `Data.define`, `Class.new`, and `Module.new`.
- Comments that use YARD directives (`@!macro`, `@!method`) are recorded in
  `Registry#directive_sites` for stage 2.

## Stage 2: Resolve

After parsing, two passes fill in what Prism alone can't see. They run in
`Generator#parse`, in this order:

1. **Directives, through `YardBridge`** (`yard_bridge.rb`). With
   `--yard-macros`, Boondoc loads the `yard` gem on demand and runs YARD over
   the same files. It takes only the objects created by `@!method`,
   `@!attribute` or an attached macro, plus the expanded docstrings of objects
   that use a directive. Prism stays the source of truth. Without the flag, the
   generator warns and lists the first three directive sites.
2. **`(see ...)` references, through `References`** (`references.rb`). This
   pass copies a target's docstring into any object or tag whose text is
   `(see Foo#bar)`. Targets are expanded before they are copied, so chains
   work in any order, and a cycle stops at the object already being expanded.

**Lookup rules.** `Registry#resolve(context, reference)` accepts `Foo::Bar`,
`Foo#bar`, `Foo.bar`, `#bar`, and `bar`. It searches the way Ruby resolves
constants: from the namespace where the reference was written, outward to the
top level. Methods are also found on superclasses and on included or extended
modules. `Linker`, `References`, the renderers, and `Visitor` all call this
method, so a change to it affects every link in the output.

## Stage 3: Render

Rendering turns the registry into a hash of `{ relative path => markdown }`
without touching the disk. `Generator#render` builds one `Context`
(`context.rb`), which wires up every helper below and is passed to every
renderer.

**What is cached.** Nothing changes the registry while pages are rendered, so
the `Context` keeps what the renderers ask for again and again: `Context#meths`
holds the sorted methods of a namespace per scope, and `Context#aliases`
groups a namespace's aliases by the name they alias. `PathMap#relative` works
each distinct link out once. These are kept in the renderers' objects and not
in the model on purpose: the parser changes a namespace's `children` directly
while it runs, and a cache there would go stale. A change that mutates the
registry during rendering has to bypass them.

| Component | File | Role |
| --- | --- | --- |
| `Filter` | `filter.rb` | Decides visibility. Private and protected methods and `@private` / `@api private` objects are hidden unless `--private` or `--protected` is set. |
| `PathMap` | `path_map.rb` | Maps objects to files (`Foo::Bar` → `Foo/Bar.md`, root → `top-level.md`), builds anchors and computes relative links. |
| `Linker` | `linker.rb` | Expands `{include:...}` and turns `{Foo#bar}`, `{file:X.md}`, and URLs into Markdown links. It also links constants inside type lists. `{include:file:...}` reads only files inside the project. |
| `Markdown` | `markdown.rb` | `map_prose` yields only prose, so fenced, indented and inline code are never rewritten. |
| `Yardopts` | `yardopts.rb` | Reads the part of a project's `.yardopts` that Boondoc understands: source globs, files after `-`, `--files`, `--readme`, `--title`, `--private`, `--protected`, and `--exclude`. Everything else, including `--output-dir`, is recorded and reported, not used. `Config.load` puts it under `.boondoc.yml` and the command line. |
| `Stitcher` | `stitcher.rb` | Loads the README and `--files`, and rewrites their relative links and images for their new location. Its sources are always inside the project, because `Config` rejects any that aren't. |
| `CORE_CONSTANTS` | `core_constants.rb` | A fixed list of Ruby core and standard-library names. A reference such as `{String}` that can't be linked renders as code instead of producing a warning. |
| `Renderer::NamespacePage` | `renderer/namespace_page.rb` | One page per class or module. |
| `Renderer::MethodSection` | `renderer/method_section.rb` | Signature, facts and aliases for each method or attribute. |
| `Renderer::Docstring` | `renderer/docstring.rb` | Prose, tag sections and callouts such as `@deprecated` and `@note`. |
| `Renderer::Index` | `renderer/index.rb` | The index page (README, then the API tree and the stitched files) and each stitched file's page. |

**Anchors.** Methods get explicit anchors in the form `method-i-<name>` or
`method-c-<name>`, and constants get `constant-<name>`. Any character outside
`[A-Za-z0-9_]` is hex-escaped, so `save?` becomes `method-i-save-3F`. This is
needed because GitHub's heading anchors can't tell `save`, `save?`, and `save!`
apart. These `<a id>` tags are the only HTML Boondoc emits.

**Broken references.** Braces that don't look like a reference, such as
`{key: value}`, pass through silently. Ones that do look like a reference but
don't resolve stay as written and produce a warning, which fails the run under
`--strict`.

**Pages that are skipped.** A namespace page is written only when
`Filter#visible?` allows the namespace and `NamespacePage#content?` is true.

## Stage 4: Write

`Writer` (`writer.rb`) is the only component that touches the output
directory. It relies on a manifest, `.boondoc-manifest`, which lists every file
Boondoc wrote on the previous run.

On each run, `Writer#write`:

1. Reads the previous manifest.
2. Refuses to write any page that would land outside the output directory or
   pass through a symlink on the way (the page itself or any directory between
   it and the output directory). This check runs for every page before
   anything is written or deleted, and `--force` does not skip it.
3. Refuses to overwrite a file that isn't in the manifest, unless `--force` is
   set. It raises `Boondoc::Error` naming up to five of the conflicting files.
4. Warns when two pages differ only by case.
5. Removes stale pages (in the manifest but not produced this run) and any
   directories left empty, never climbing above the output directory. Stale
   entries get the same outside-or-symlink check as pages; one that fails is
   skipped with a warning instead of deleted.
6. Writes the new pages, then the new manifest. A file that already holds the
   same content is left alone, so a second run does not update modification
   times. This comparison runs after the checks in step 2, so it never reads
   through a symlink.

Stale pages are removed **before** the new ones are written. On a
case-insensitive filesystem such as macOS, a page renamed only by case is the
same file, so removing it afterwards would delete the page that was just
written. `same_file_as_earlier_page?` handles the same situation in the
conflict check. Keep both in mind when changing this class.

Files a user adds to the output directory by hand, such as this guide, are
never touched.

The manifest is checked into the output directory with everything else, so
`Writer` treats it as editable by anyone who can change the repo. That is why
stale entries are checked before deletion rather than trusted. The checks live
in `Writer#unsafe`.

## What Boondoc trusts

Boondoc never runs the code it documents, but it does read the project's
comments, `.boondoc.yml`, and output directory. Those can come from someone
else, for example a pull request from a fork that CI builds docs for. The rule
is: **anything Boondoc copies into the output must come from inside the
project, and anything it writes or deletes must stay inside the output
directory.**

`Containment.inside?(path, directory)` (`containment.rb`) is the shared check
for reading. It compares real paths with `File.realpath`, so `../`, absolute
paths and symlinks that lead elsewhere all fail. It returns `false` for paths
that don't exist.

`Containment.symlink_between(path, directory)` is the shared check for
writing. It looks only at the names from `directory` down to `path`, so it
works for output that does not exist yet, and returns the first component that
is a symlink.

| Where | What is checked |
| --- | --- |
| `Linker#read_file` | `{include:file:...}` reads a file only if it is inside the project. Otherwise the include stays as written, with a "cannot include" warning. |
| `Config#readme_file`, `Config#extra_files` | The README and `--files` must be inside the project, or Boondoc raises "... is outside the project". Their paths come back relative to the project root with `..` resolved. |
| `Config#output_dir` | The output directory must be inside the project unless `allow_outside_output` is set, and must never be, or sit below, a symlink inside the project, flag or not. |
| `Config.load` | `allow_outside_output` in `.boondoc.yml` raises. Only the caller (command line, Rake options) may set it. |
| `Yardopts` | `.yardopts` is treated like `.boondoc.yml`: its sources, README and files go through the same checks, and it never sets `output`, `index`, `force`, or `allow_outside_output`. Its `--exclude` patterns have a match timeout, because they come from the project. |
| `Config#source_files` | Ruby files that resolve outside the project, through an absolute path, `../`, or a symlink, are split off into `#outside_sources`. `Generator#run` warns about each, so `--strict` fails. The YARD bridge only sees the files that remain. |
| `Writer#unsafe` | Pages and stale manifest entries must stay inside the output directory without passing through a symlink, using `Containment.symlink_between`. |
| `Generator#run` | Asks for `output_dir` first, so an unsafe directory is refused before any parsing. |

`--allow-outside-output` exists so docs can be kept outside the repository. It
is the one place where the project's `.boondoc.yml` could pick where files go,
which is why the config file cannot set it and why the help text calls it a
security risk. `force` is accepted from the config file, so with the flag a
`.boondoc.yml` can overwrite files in the directory the caller named.

### Residual risks

These are known and not fixed by Boondoc:

- **Check, then write.** `Writer` checks a path and writes it a moment later. A
  process that can change the output directory during the run could swap a
  directory for a symlink in between. Exploiting it needs local write access
  to the output directory, which already allows more than that.
- **The manifest is project content.** The output directory is normally
  committed, so `.boondoc-manifest` can be edited by the project. Entries get
  the same checks as pages, so the worst a forged entry does is delete a
  non-symlink file inside the output directory.
- **Raw HTML passes through.** Docstrings and stitched files are markdown, and
  HTML, `javascript:`, and `data:` links in them are written out as they are.
  GitHub and `gh markdown-preview` (which renders through GitHub's markdown
  API) sanitise it. A viewer that does not could run script from a docstring.
- **`serve` trusts the extension.** `gh-markdown-preview` returns any file the
  user can read through `/__/md?path=`, sends rendered markdown to GitHub, and
  does not check the `Host` header. `Preview` binds to 127.0.0.1 by default and
  warns about other hosts. Whether the docs are trusted is the caller's call.
- **`--yard-macros`.** The YARD bridge parses the same filtered file list.
  YARD evaluates only `defined? Name` for a bare constant in a condition,
  `@!parse` only parses, and plugins load from the user's own `~/.yard`.

When adding a feature that reads a file named in the project, such as a new
include form or config key, check it with `Containment.inside?`. When adding
a feature that writes or deletes in the output directory, go through `Writer`.
The specs for these rules use `with_sandbox` from
`spec/support/fixture_helper.rb`, which yields a project directory and a
sibling `outside` directory to aim at, or the `'with a sandbox'` shared
context in the same file, which provides them as `project` and `outside`.

## Entry points and configuration

Every way of running Boondoc builds a `Config` and hands it to
`Generator.new(config).run`.

| Component | File | Role |
| --- | --- | --- |
| `exe/boondoc` | `exe/boondoc` | The gem executable. It calls `CLI.start_with_default`, which treats a bare `boondoc [GLOBS]` as `boondoc generate [GLOBS]`. |
| `CLI` | `cli.rb` | A Thor CLI with three commands: `generate` (the default), `serve`, and `version`. |
| `Config` | `config.rb` | Merges `DEFAULTS`, `.boondoc.yml`, and CLI overrides; later sources win. Unknown keys raise an error. |
| `RakeTask` | `rake_task.rb` | `Boondoc::RakeTask.new(:docs) { \|t\| t.options = {...} }`. The repo's own `Rakefile` uses it. |
| `Preview` | `preview.rb` | Behind `boondoc serve`. It runs the `gh markdown-preview` extension and asks before installing it if it's missing. It generates nothing. |
| `Reporter` | `reporter.rb` | Prints progress to stderr and collects warnings, ignoring repeats. With `--strict`, any warning makes `Generator#run` raise. |
| `Boondoc::Error` | `boondoc.rb` | The single error type for anything reported to the user. |
| `Containment` | `containment.rb` | `inside?(path, directory)`, the shared check that a file is really inside a directory. See [What Boondoc trusts](#what-boondoc-trusts). |

`lib/boondoc.rb` requires every file in dependency order. A new file must be
added to that list.

## Tests, tooling and repo layout

```
lib/boondoc/          the gem (see the stages above)
exe/boondoc           the executable
spec/boondoc/         one spec per lib file, same layout
spec/fixtures/sample  a small project, with golden output in expected/
spec/fixtures/macros  a project that uses YARD macros, for YardBridge
spec/support/         FixtureHelper: parse_source, render_fixture, with_sandbox
sig/                  RBS signatures
bin/benchmark         times boondoc, YARD and RDoc on the same Ruby files of a repository or gem
bin/benchmark_status  times boondoc alone and compares it with docs/Performance.md (used by Guard)
Guardfile             RuboCop, RSpec and benchmark guards, with a status line
docs/                 boondoc's own generated docs, plus this guide
```

Common commands:

```sh
bin/setup                       # bundle install
bundle exec rake                # specs, then RuboCop (the default task)
bundle exec rspec               # specs only
COVERAGE=true bundle exec rspec # with SimpleCov
bundle exec rake docs           # regenerate docs/ in strict mode
bundle exec guard               # RuboCop, specs and a benchmark check on every change
```

Guard prints one line, `Status: RuboCop: ✅ | Tests: ✅ | Bench: ✅`. A count in
parentheses is the number of offenses or failures. `🐢` means boondoc's median
is more than 0.1 seconds above the "boondoc" row of
`docs/Performance.md`; the benchmark check uses 5 runs, so rerun
`bin/benchmark_status` before trusting a small miss.

**Golden tests.** `spec/boondoc/generator_spec.rb` renders
`spec/fixtures/sample` and compares every page with
`spec/fixtures/sample/expected/`. It also checks that every relative link
resolves. After an intended output change, regenerate the golden files and
review the diff:

```sh
UPDATE_GOLDEN=1 bundle exec rspec spec/boondoc/generator_spec.rb
git diff spec/fixtures/sample/expected
```

**Unit tests.** For a parser or renderer change, `parse_source` turns a Ruby
snippet into a registry, which is the quickest way to test a single construct.

## Where to start for common changes

| Change | Start in |
| --- | --- |
| Support a new Ruby construct or DSL call | `Frontend::Visitor` (`CALLS` table and a handler) |
| Support a new tag or change how one is shown | `DocstringParser`, then `Renderer::Docstring` |
| Change how references are found | `Model::Registry#resolve` |
| Change link syntax or include behavior | `Linker` |
| Change page layout | `Renderer::NamespacePage`, `Renderer::MethodSection` |
| Change file names or anchors | `PathMap` (and regenerate golden files) |
| Add a CLI option | `CLI`, `Config::DEFAULTS`, and the README options table |
| Change what is overwritten or deleted | `Writer` (read the case-insensitivity notes and [What Boondoc trusts](#what-boondoc-trusts) first) |
| Read a new kind of file named in the project | `Containment.inside?`, as `Linker#read_file` does |
