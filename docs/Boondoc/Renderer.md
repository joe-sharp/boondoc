# Module: Boondoc::Renderer

- **Defined in:** [`lib/boondoc/renderer/base.rb`](../../lib/boondoc/renderer/base.rb), [`lib/boondoc/renderer/docstring.rb`](../../lib/boondoc/renderer/docstring.rb), [`lib/boondoc/renderer/index.rb`](../../lib/boondoc/renderer/index.rb), [`lib/boondoc/renderer/method_section.rb`](../../lib/boondoc/renderer/method_section.rb), [`lib/boondoc/renderer/namespace_page.rb`](../../lib/boondoc/renderer/namespace_page.rb)

Classes that turn the model into markdown.

## Namespaces

- [`Boondoc::Renderer::Base`](Renderer/Base.md) — Shared helpers for all renderers.
- [`Boondoc::Renderer::Docstring`](Renderer/Docstring.md) — Renders a docstring: callouts, body, then one section per kind of tag.
- [`Boondoc::Renderer::Index`](Renderer/Index.md) — Renders the index page (README plus tables of contents) and stitched files.
- [`Boondoc::Renderer::MethodSection`](Renderer/MethodSection.md) — Renders the detail section for one method or one attribute.
- [`Boondoc::Renderer::NamespacePage`](Renderer/NamespacePage.md) — Renders the page for one class or module, or for the top-level namespace.
