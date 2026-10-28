# Module: Boondoc

- **Defined in:** [`lib/boondoc.rb`](../lib/boondoc.rb), [`lib/boondoc/assets.rb`](../lib/boondoc/assets.rb), [`lib/boondoc/cli.rb`](../lib/boondoc/cli.rb), [`lib/boondoc/config.rb`](../lib/boondoc/config.rb), [`lib/boondoc/containment.rb`](../lib/boondoc/containment.rb), [`lib/boondoc/context.rb`](../lib/boondoc/context.rb), [`lib/boondoc/core_constants.rb`](../lib/boondoc/core_constants.rb), [`lib/boondoc/docstring_parser.rb`](../lib/boondoc/docstring_parser.rb), [`lib/boondoc/filter.rb`](../lib/boondoc/filter.rb), [`lib/boondoc/frontend/comments.rb`](../lib/boondoc/frontend/comments.rb), [`lib/boondoc/frontend/prism_parser.rb`](../lib/boondoc/frontend/prism_parser.rb), [`lib/boondoc/frontend/visitor.rb`](../lib/boondoc/frontend/visitor.rb), [`lib/boondoc/generator.rb`](../lib/boondoc/generator.rb), [`lib/boondoc/linker.rb`](../lib/boondoc/linker.rb), [`lib/boondoc/links.rb`](../lib/boondoc/links.rb), [`lib/boondoc/markdown.rb`](../lib/boondoc/markdown.rb), [`lib/boondoc/model/code_object.rb`](../lib/boondoc/model/code_object.rb), [`lib/boondoc/model/docstring.rb`](../lib/boondoc/model/docstring.rb), [`lib/boondoc/model/registry.rb`](../lib/boondoc/model/registry.rb), [`lib/boondoc/path_map.rb`](../lib/boondoc/path_map.rb), [`lib/boondoc/preview.rb`](../lib/boondoc/preview.rb), [`lib/boondoc/rake_task.rb`](../lib/boondoc/rake_task.rb), [`lib/boondoc/references.rb`](../lib/boondoc/references.rb), [`lib/boondoc/renderer/base.rb`](../lib/boondoc/renderer/base.rb), [`lib/boondoc/renderer/docstring.rb`](../lib/boondoc/renderer/docstring.rb), [`lib/boondoc/renderer/index.rb`](../lib/boondoc/renderer/index.rb), [`lib/boondoc/renderer/method_section.rb`](../lib/boondoc/renderer/method_section.rb), [`lib/boondoc/renderer/namespace_page.rb`](../lib/boondoc/renderer/namespace_page.rb), [`lib/boondoc/reporter.rb`](../lib/boondoc/reporter.rb), [`lib/boondoc/stitcher.rb`](../lib/boondoc/stitcher.rb), [`lib/boondoc/type_parser.rb`](../lib/boondoc/type_parser.rb), [`lib/boondoc/version.rb`](../lib/boondoc/version.rb), [`lib/boondoc/writer.rb`](../lib/boondoc/writer.rb), [`lib/boondoc/yard_bridge.rb`](../lib/boondoc/yard_bridge.rb), [`lib/boondoc/yardopts.rb`](../lib/boondoc/yardopts.rb)

Markdown-only API documentation for Ruby.

Source is parsed with Prism into a [`Boondoc::Model::Registry`](Boondoc/Model/Registry.md), and every class
and module is rendered to its own markdown file. See [`Boondoc::Generator`](Boondoc/Generator.md) for
the pipeline and [`Boondoc::CLI`](Boondoc/CLI.md) for the command line.

## Namespaces

- [`Boondoc::Assets`](Boondoc/Assets.md) — The files that are copied into the output directory next to the pages: images, video, PDFs, and anything else a page links to or embeds.
- [`Boondoc::CLI`](Boondoc/CLI.md) — The `boondoc` command.
- [`Boondoc::Config`](Boondoc/Config.md) — Options for one run, merged from defaults, `.yardopts`, `.boondoc.yml`, and the command line.
- [`Boondoc::Containment`](Boondoc/Containment.md) — Checks that a path stays inside a directory once symlinks are followed.
- [`Boondoc::Context`](Boondoc/Context.md) — Everything the renderers need to produce a page.
- [`Boondoc::DocstringParser`](Boondoc/DocstringParser.md) — Turns the text of a documentation comment into a [`Model::Docstring`](Boondoc/Model/Docstring.md).
- [`Boondoc::Error`](Boondoc/Error.md) — Raised for any failure Boondoc reports to the user.
- [`Boondoc::ExtraFile`](Boondoc/ExtraFile.md) — A non-API file (README, changelog, guide) that is copied into the output.
- [`Boondoc::Filter`](Boondoc/Filter.md) — Decides which objects appear in the output.
- [`Boondoc::Frontend`](Boondoc/Frontend.md)
- [`Boondoc::Generator`](Boondoc/Generator.md) — Runs the whole pipeline: parse, resolve, render, write.
- [`Boondoc::Linker`](Boondoc/Linker.md) — Turns YARD-style references in markdown into relative links.
- [`Boondoc::Links`](Boondoc/Links.md) — Finds the paths in markdown links, images and HTML attributes so they can be rewritten.
- [`Boondoc::Markdown`](Boondoc/Markdown.md) — Just enough markdown awareness to leave code alone while rewriting prose.
- [`Boondoc::Model`](Boondoc/Model.md)
- [`Boondoc::PathMap`](Boondoc/PathMap.md) — Maps objects to output files and anchors, and computes relative links.
- [`Boondoc::Preview`](Boondoc/Preview.md) — Serves generated docs locally using the `gh markdown-preview` extension of the GitHub CLI.
- [`Boondoc::RakeTask`](Boondoc/RakeTask.md) — Defines a Rake task that generates the documentation.
- [`Boondoc::References`](Boondoc/References.md) — Expands YARD reference docstrings: `(see Foo#bar)` as a whole docstring, or as the text of a tag such as `@param (see Foo#bar)`.
- [`Boondoc::Renderer`](Boondoc/Renderer.md) — Classes that turn the model into markdown.
- [`Boondoc::Reporter`](Boondoc/Reporter.md) — Collects warnings and prints progress messages.
- [`Boondoc::Stitcher`](Boondoc/Stitcher.md) — Loads the extra files and keeps their relative links working after the move.
- [`Boondoc::TypeParser`](Boondoc/TypeParser.md) — Splits a YARD type list such as `[String, Hash{Symbol => Array<Integer>}]`.
- [`Boondoc::Writer`](Boondoc/Writer.md) — Writes generated pages and removes pages left over from earlier runs.
- [`Boondoc::YardBridge`](Boondoc/YardBridge.md) — Optional second pass that uses YARD to expand macros and directives.
- [`Boondoc::Yardopts`](Boondoc/Yardopts.md) — The part of a project's `.yardopts` that Boondoc understands.

## Constants

### <a id="constant-CORE_CONSTANTS"></a>`CORE_CONSTANTS`

```ruby
CORE_CONSTANTS = %w[
    ArgumentError Array BasicObject Binding Class ClosedQueueError Comparable Complex ConditionVariable Data
    Dir EOFError Encoding EncodingError Enumerable Enumerator Errno Exception FalseClass Fiber FiberError File
    FileTest Float FloatDomainError FrozenError GC Hash IO IOError IndexError Integer Interrupt Kernel KeyError
    LoadError LocalJumpError Marshal MatchData Math Method Module Mutex NameError NilClass NoMatchingPatternError
    NoMatchingPatternKeyError NoMemoryError NoMethodError NotImplementedError Numeric Object ObjectSpace Pathname
    Proc Process Queue Ractor Random Range RangeError Rational Refinement Regexp RegexpError Ruby RubyVM
    RuntimeError ScriptError SecurityError Set Signal SignalException SizedQueue StandardError StopIteration String
    Struct Symbol SyntaxError SystemCallError SystemExit SystemStackError Thread ThreadError ThreadGroup Time
    TracePoint TrueClass TypeError UnboundMethod UncaughtThrowError Warning ZeroDivisionError
    Base64 Benchmark BigDecimal CGI CSV Coverage DRb Date DateTime Delegator Digest ERB Etc Fcntl Fiddle FileUtils
    Find Forwardable GetoptLong IPAddr IPSocket JSON Logger Monitor MonitorMixin Net Observable Open3 OpenSSL
# ... (4 more lines)
```

Top-level classes and modules of Ruby core and the standard library. A
fixed list, because what happens to be loaded in boondoc's own process
(Thor, Rake, Boondoc itself) says nothing about the project being documented.

### <a id="constant-VERSION"></a>`VERSION`

```ruby
VERSION = "0.1.0"
```
