# Performance

Time to document each codebase from scratch, in seconds. The four smaller rows are the median of 11 runs;
the Metasploit row is the median of 3 runs at commit `b22ce1f`:

| Codebase | Ruby files | Lines | Boondoc | Boondoc `--yard-macros` | YARD | YARD + yard-markdown | YARD (parse only) | RDoc |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| boondoc | 68 | 6,301 | 0.31 | 0.41 | 2.29 | 1.02 | 0.74 | 0.91 |
| yard 0.9.45 | 238 | 31,466 | 0.89 | 1.31 | 16.08 | 3.95 | 3.02 | 4.24 |
| rdoc 8.1.0 | 110 | 48,490 | 0.55 | 0.56 | 16.41 | 6.76 | 5.97 | 2.86 |
| rubocop 1.92.0 | 957 | 115,474 | 2.69 | 5.46 | 48.93 | 12.23 | 8.81 | 19.65 |
| metasploit-framework b22ce1f | 8,571 | 1,455,214 | 20.33 | 21.04 | 442.38 | 172.55 | 148.80 | can't parse |

Within each of the four smaller rows, every run was within ±11% of its tool's median; the widest was Boondoc
on Boondoc. Medians from separate full runs of the table differ by up to about 10%, so treat differences under
about 10% as noise. The Metasploit row was measured before the interleaved runs and check runs were added, and
with earlier tool versions, so its spread is not known.

Measured on Ruby 4.0.9, on a 3.0 GHz Intel Core i5-8500B running macOS 15,
with Boondoc 0.1.0, YARD 0.9.45, yard-markdown 0.10.0, RDoc 8.1.0, RuboCop 1.92.0, and Prism 1.9.0.
Each run documented every Ruby file of the codebase with no README and no cache, and includes the time Ruby
takes to start. Every tool was given the same files: the tracked and new Ruby files of a git repository, or
the whole directory of an installed gem, except files in hidden directories. `.yardopts` is not used. Each tool
first runs once untimed, to check that it succeeds and writes its output. The timed runs then go round by round,
each tool once per round in a different order from the round before, so a slowdown on the machine affects every
tool alike. Reproduce the table with
`bin/benchmark --for-docs`, which documents this project and the installed yard, rdoc, and rubocop gems,
or takes any directories as arguments: `bin/benchmark --for-docs ~/dev/metasploit-framework`. It needs the
yard, yard-markdown, and rdoc gems installed. `RUNS=n` changes the number of runs. `bin/benchmark-chart` redraws
the chart from the table. The Boondoc time in the "boondoc" row is also the baseline for Guard's
benchmark check (`bin/benchmark_status`), so updating the table resets it.

RDoc can't parse Metasploit, so its cell is left blank rather than estimated. The YARD columns were run on
the same files without RDoc.

"YARD" and "RDoc" both render HTML through templates, with stylesheets, scripts, and (for YARD) a search index,
which Boondoc never has to do, so those columns are not like for like. "YARD + yard-markdown" is the closest
comparison: both tools write markdown. Even so, it is much faster than HTML, and parsing is most of what
is left: YARD's parse alone is 72% to 88% of the yard-markdown time on the four smaller codebases and
86% on Metasploit. Note that yard-markdown writes less than Boondoc does: it leaves `{Foo#bar}` references
and types unlinked and writes a CSV index in place of an index page. `--yard-macros` runs YARD only on the
files that contain directives, so it costs little when there are few and is never slower than a full YARD
parse.
