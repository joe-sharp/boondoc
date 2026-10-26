## [Unreleased]

## [0.1.0] - 2026-10-25

### ✨ Features
- **Markdown docs from YARD comments:** Prism-based parsing of YARD-style comments, with one markdown page per class or module.
- **Stitched README and extra files**, with reference links between pages.
- **YARD bridge (optional):** `--yard-macros` hands YARD only the files that contain macros or directives, and warns when a project has none.
- **Assets:** the `assets` option (`--assets`, or `--asset` in `.yardopts`) copies files such as images into the output, and `copy_linked_assets` also copies the files that pages embed. Links to a copied file, in the README, stitched files, and doc comments, point at the copy. A file that is no longer copied is removed like a stale page.
- **`.yardopts` support:** reads the source globs, the extra files after `-` and `--files`, `--readme`, `--title`, `--private`, `--protected`, and `--exclude`. `.boondoc.yml` and the command line win over it, key by key, and `--no-yardopts` (or `yardopts: false`) skips it. `--output-dir` is never used, and other options are listed as ignored.
- **`boondoc serve`** warns when `--host` is not a loopback address. Links to source files 404 under `serve`, because they point outside the output directory.
- **Case-safe file names:** classes and modules such as `Guard::CLI` and `Guard::Cli` now get their kind in the file name (`CLI.class.md`, `Cli.module.md`) instead of overwriting each other on case-insensitive filesystems.

### 🔒 Security
- `{include:file:...}`, `readme`, and `files` only read files inside the project, and Boondoc never writes or deletes through a symlink inside the output directory, or outside it.
- The output directory must be inside the project and may not be, or sit below, a symlink. `--allow-outside-output` (command line and Rake options only, never `.boondoc.yml`) allows an output directory outside the project; that directory is not checked for symlinks.
- Ruby files that resolve outside the project (an absolute glob, `../`, or a symlink) are skipped with a warning, so `--strict` fails.
