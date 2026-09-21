# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A LaTeX thesis template (KOMA-Script `scrbook`, biblatex/biber) for Bachelor's and
Master's theses at the Department of Applied Computer Science, Fulda University of
Applied Sciences (Prof. Dr. Jonas Posner / Fulda HPC). The thesis itself can be written
in English or German; the template's own guidance comments are English.

Chapter structure, section titles, and all example content are explicitly *suggestions*
— see `README.md`. Do not treat the existing chapter list as fixed when a user adapts
the template to a topic.

## Build

All commands run from the repository root:

| Command | Effect |
| --- | --- |
| `make` | Regenerates Gnuplot figures if stale, then builds `out/Thesis.pdf` via `latexmk`. |
| `make view` | Builds if needed and opens the PDF (`open` on macOS, `xdg-open` otherwise). |
| `make draft` | Builds `out/Thesis-draft.pdf` with line numbers, visible `\todo`s, and a DRAFT label in both margins. |
| `make view-draft` | Builds the draft and opens it. |
| `make watch` | `latexmk -pvc`; rebuilds on every save until interrupted. |
| `make figures` | Only regenerates the Gnuplot figures (`.gp` + `.dat` → `.tex`/`.eps`/`.pdf`). |
| `make clean` | Deletes `tmp/` and everything in `out/` except `.gitkeep` and the tracked `Thesis.pdf`. |
| `make help` | Lists the available targets. |
| `make lint` | Runs `tools/lint.sh` — thirteen source checks, exits non-zero on a hit. Not part of the default build. |
| `make submit-check` | `tools/lint.sh --submit` — everything lint does, plus leftover `TODO`s, config placeholders, and bad boxes. Fails on the template as shipped, by design. |

Requires TeX Live/MacTeX with `latexmk` and `biber`; `gnuplot` and `epstopdf` only for
figure regeneration.

"Correct" means: `make` completes, `make lint` passes, and the log in `tmp/Thesis.log`
has no unresolved references, missing citations, or new warnings. `latexmk` runs with
`-halt-on-error -file-line-error`, so failures surface as the first error with a
`file:line:` prefix. The one known-benign exception is a `\@parboxrestore has changed`
warning in `make draft` output only — lineno versus the caption package, unavoidable by
load order, no effect on the PDF.

Always run `make` *before* `make lint`, in that order. Lint's undefined-reference check
reads `tmp/Thesis.log`; with no log (fresh clone, or right after `make clean`) it prints a
one-line `note:` and still exits 0, so a green lint on its own proves nothing about
references or citations. The unmodified template builds with zero LaTeX warnings, so any
`Warning` line in the log after an edit is new.

Build output is split in two. `tmp/` receives every auxiliary file (`.aux`, `.log`, `.bbl`,
`.fdb_latexmk`, …), is created on demand, and is `.gitignore`d wholesale. `out/` receives only
the PDF and its `.synctex.gz`; of those, `out/Thesis.pdf` is **tracked on purpose** (plus the
`out/.gitkeep` placeholder), while the draft PDF and the SyncTeX files stay ignored. So every
build dirties `out/Thesis.pdf` — that is expected, not something to revert. `make clean` spares
it for the same reason; the next build is from scratch regardless, because latexmk's database
lived in `tmp/`. The split relies on latexmk's `-auxdir`/`-outdir` pair, which on TeX Live is
emulated: pdflatex writes everything to `tmp/` and latexmk then moves the PDF and SyncTeX file
to `out/`. Never edit anything in either directory. The Gnuplot
outputs under `src/figures/` are the opposite: `.tex`, `.eps`, and `.pdf` are all
committed, so running `make` after touching a `.gp` or `.dat` dirties the working tree
on purpose. Commit the regenerated files together with their source.

`.latexmkrc` at the repo root makes a bare `latexmk src/Thesis.tex` behave like `make`
(`$do_cd`, `$out_dir = '../out'`, `$aux_dir = '../tmp'`). Keep it in sync with `LATEXMK_FLAGS` in the `Makefile`;
both carry `-synctex=1`, without which forward and inverse search do nothing in any editor.

## Root-document resolution

A language server compiles **the file that is open**, not `src/Thesis.tex`. Two mechanisms
keep that working, and both must be maintained when files are added:

- Every `.tex` and `.sty` under `src/` starts with `% !TeX root = <relative>/Thesis.tex`.
  Lint check 12 enforces presence *and* the correct relative depth, so a new
  `src/chapters/09/00-Foo.tex` fails until it carries `../../Thesis.tex`.
- `src/.texlabroot` is an empty marker pinning the project root to `src/`. That is the
  directory `.latexmkrc`'s `$do_cd` / `$out_dir = '../out'` / `$aux_dir = '../tmp'` trio assumes; without it a build
  started from a chapter file resolves the output directory to `src/chapters/out`.

Two files are deliberately exempt and must stay that way: `src/Thesis.tex` (it *is* the root)
and `src/figures/05/example-scaling-diagram.tex` (gnuplot rewrites it on every
`make figures`, so any comment added there is wiped). `$FILES` in lint already excludes the
latter via the generated-file list built at the top of the script.

`.vscode/settings.json` and `.zed/settings.json` + `.zed/tasks.json` are committed; `.gitignore`
negates them out of the otherwise-ignored editor directories. Neither has been verified inside a
running editor — treat their schemas as documented-but-untested.

## Path semantics (the main source of confusion)

Three different working directories are in play:

1. **LaTeX**: `latexmk -cd` cd's into `src/` before compiling. Every `\input` path in
   `.tex` files is therefore relative to `src/` and must not start with `/` —
   e.g. `\input{chapters/01/00-Introduction}`, `\input{tables/05/example-results}`,
   `\input{figures/03/example-architecture}`.
2. **Graphics**: `thesis.sty` sets `\graphicspath{{figures/}}`, so
   `\includegraphics{00/hs-fulda_logo_2024.png}` resolves to
   `src/figures/00/hs-fulda_logo_2024.png`. Do not repeat the `figures/` prefix. This
   applies to `\includegraphics` only — a `.tex` file under `src/figures/` is pulled in
   with `\input{figures/<id>/<name>}`, which is case 1 and keeps the `figures/` prefix.
3. **Gnuplot**: the Makefile rule `%.tex: %.gp` cd's into `src/` before running
   gnuplot, so `set output` *and* every data-file path must be relative to `src/`
   (`set output "figures/05/example-scaling-diagram.tex"`). This matters more than it
   looks: gnuplot bakes that same path verbatim into the `\includegraphics` line of the
   generated `.tex`, so a repo-root-relative path here produces a file LaTeX cannot
   resolve.

## Gnuplot figures

The figures use gnuplot's `epslatex` terminal, which emits a `.tex` (labels, typeset by
LaTeX in the document font) plus an `.eps`. pdflatex cannot embed EPS, so the Makefile
runs `epstopdf` to produce the `.pdf` the generated `.tex` actually loads. Include such a
figure with `\input{figures/05/example-scaling-diagram}` — no file extension, and no
`width=`, since the natural size comes from `set terminal ... size` in the `.gp` file.
To shrink one at the include site, wrap the `\input` in `\resizebox{0.75\textwidth}{!}{...}`
as the Evaluation chapter does — noting that this scales the labels along with the
drawing, so the `.gp` size is the right knob when label size must match the document font.

Plot data lives in a whitespace-separated `.dat` file beside the script, not inline in
the plot command. Column names go on a leading `#` comment line, which gnuplot skips by
itself — no `set datafile separator` and no `skip 1` are needed. Assign the path to a
variable at the top of the script (`DATA = "figures/05/example-scaling-data.dat"`) and
select columns with `using 1:2`.

Because a pattern rule cannot know which data file a script reads, the Makefile declares
`$(GNUPLOT_OUTPUTS): $(GNUPLOT_DATA)` — every plot depends on every `.dat` under
`src/figures/`. Editing one data file therefore redraws all plots, which is deliberate:
coarse but always correct.

## Who decides what to rebuild

`make` does **not** gate the document build on a timestamp rule, and must not be changed
back to one. The `all` target always calls `latexmk`, which decides for itself from the
contents it recorded in `tmp/Thesis.fdb_latexmk`. Two reasons:

- macOS ships **GNU Make 3.81**, which compares mtimes with one-second granularity. A
  timestamp rule silently skips any edit saved in the same second as the previous build
  and hands back a stale PDF — no error, no warning. It really happens; switching
  `\ThesisLanguage` and rebuilding immediately used to produce the previous language.
- latexmk tracks every file LaTeX actually reads, so a newly included asset is picked up
  whatever its extension. There is no extension whitelist to maintain.

A no-op `make` costs about 0.1 s and prints `All targets ... are up-to-date`.

The one place make still arbitrates by timestamp is the gnuplot rule
(`%.tex: %.gp` plus `$(GNUPLOT_OUTPUTS): $(GNUPLOT_DATA)`), because always rerunning
gnuplot would rewrite committed `.eps`/`.pdf` files on every build and permanently dirty
the tree. The same one-second wart applies there: edit a `.dat` and run `make` within the
same second and the plot is redrawn on the next build instead.

## Configuration and the language switch

`src/thesis-config.tex` holds all thesis metadata. Three of its values are validated in
`thesis.sty` and raise a package error on anything else: `\ThesisType`
(`bachelor`/`master`), `\ThesisLanguage` (`english`/`german`), `\ThesisDraft`
(`true`/`false`). New fields get a `\providecommand` default in `thesis.sty` so that an
older config file still compiles after a template update — keep doing that.

Every fixed string the template contributes is defined once in `thesis.sty` as
`\ThesisStr...`, built on:

```tex
\newcommand{\ThesisText}[2]{\IfGermanTF{#2}{#1}}   % {english}{german}
```

**Never hardcode a user-visible English string in a chapter file.** Chapter and section
titles, float captions, and title-page labels all go through `\ThesisText`:

```tex
\ThesisChapter{\ThesisText{Background}{Grundlagen}}{ch:background}{...}
```

`\IfGermanTF` and `\ThesisText` are `\newcommand`-defined and therefore `\long`, so their
arguments may contain blank lines — that is what lets the declaration switch whole
multi-paragraph blocks.

Three things stay English on purpose: the long `TODO` guidance comments (instructions to
the author, not thesis content), the short hint paragraphs inside example sections
(they vanish with the examples), and pseudocode control-flow keywords. babel loads both
languages always, so the English abstract and German Zusammenfassung are each hyphenated
correctly.

Three upstream quirks are worked around in `thesis.sty`, all verified in a minimal
document — do not "simplify" them away:

- cleveref names every float in English unless it gets an explicit language option, so it
  is loaded as `[ngerman|english,nameinlink,noabbrev]`. Without `noabbrev` a single
  sentence mixes `Table 5.1` with `fig. 5.1`.
- algorithm2e's language option translates the float name but *not* `\KwIn`/`\KwOut`,
  which are set by hand for German. Its option is `german`, not `ngerman`: `ngerman`
  sets `\algocf@typo` to a space, giving `Eingabe :` — French typography, wrong for German.
- listings styles preprocessor directives only when the `#` sits in column 0, so an
  indented `#pragma` would stay unhighlighted. `\lst@Delim@directive` is redefined
  verbatim from `lstmisc.sty` with just that column test relaxed. `directivestyle` also
  needs `\lstloadaspects{directives}` first — the key does not exist until the aspect
  is loaded, which otherwise only happens with the first `language=C` listing.

`make draft` does not edit the config: it passes
`-usepretex='\def\ThesisDraftOverride{}'` and `-jobname=Thesis-draft`, so the review copy
lands beside the real PDF. `thesis.sty` checks for that macro before reading
`\ThesisDraft`.

## Package order in thesis.sty

Order is load-bearing at the end of the preamble: biblatex → hyperref → bookmark →
algorithm2e → acro → **cleveref last**. cleveref must see every float type and hyperref
before it initialises. Draft-mode packages (todonotes, eso-pic, lineno) load after
all of that.

The draft marker is drawn with eso-pic rather than draftwatermark, because draftwatermark
places exactly one stamp per page and the marker has to appear in *both* margins. The two
`\put`s sit 13mm from each paper edge, which stays clear of the text block on recto and
verso alike, even though `twoside` plus `BCOR` swaps the inner and outer margin widths.
The `hpc` colors are therefore defined *before* the draft block — do not move them back.

`cleveref` does not know `algocf` (algorithm2e) or `lstlisting`, so both get explicit
`\crefname`/`\Crefname` in each language inside `\AtBeginDocument`.

## Empty lists are skipped

`src/chapters/99/00-Lists.tex` prints each list only if it has entries. The mechanism, in
`thesis.sty`: `\addcontentsline` is patched to record which list file it fed; at
`\AtEndDocument` those flags are written to the `.aux`; the next run reads them back
before the front matter. A list therefore appears one `latexmk` pass after its first
entry, which latexmk performs anyway.

- If the `\pretocmd` patch ever fails, a toggle makes `\ThesisIfListSeen` print
  everything rather than silently dropping a list. Preserve that fallback.
- acro does not use `\addcontentsline`, so `\ac`, `\acs`, `\acl`, and `\acp` are patched
  separately to set an `acr` flag. Adding another acro entry point means patching it too.
- algorithm2e ignores the `listof=totoc` class option, so the List of Algorithms adds its
  own ToC line by hand in `00-Lists.tex`. The other lists must not do this — they would
  get a duplicate entry.

## Structure and conventions

**One sentence per line.** Every `.tex` file, `thesis.sty`, and `README.md` use semantic
linefeeds: each sentence starts on its own line and is never wrapped, however long it
runs (lines past 150 characters are normal and correct). This applies to `%` comments —
which is where most of this template's text lives — and to prose inside macro arguments
such as `\ThesisChapter` overviews and `\caption`. Never re-wrap a paragraph to a column
width; when editing a sentence, keep the edit on its one line. What `tools/lint.sh`
enforces is the load-bearing half — never two sentences on one line.
`src/figures/05/example-scaling-diagram.tex` is exempt because gnuplot regenerates it.

**Non-breaking space before every reference.** `\cite`, `\ref`, `\autoref`, `\pageref`,
`\eqref`, `\cref`, `\Cref` and `\url` are always bound to the preceding word with `~`,
never a plain space — `Table~\ref{tab:x}`, `is~\cite{key}`, `and~\cref{fig:y}`.

**`\enquote{...}`, never a straight `"`.** csquotes is loaded with `autostyle`, so quotes
follow the thesis language automatically.

**`\caption` before `\label`.** A `\label` placed first silently captures the enclosing
section's number instead of the float's. LaTeX never warns; lint does.

**A label after every numbered heading.** Each `\section`, `\subsection`, and
`\subsubsection` is followed on the next line by `\label{sec:...}`, referenced or not;
chapters get theirs from `\ThesisChapter`. Lint check 13 enforces it. `sec:` labels are
exempt from the orphan check, which only covers `fig:`/`tab:`/`lst:`/`alg:`.

- `src/Thesis.tex` — assembly only: front matter, chapters 01–08, `\printbibliography`,
  lists, `\appendix`, declaration. Adding or removing a chapter means editing this file.
- `src/thesis-config.tex` — all thesis metadata; see above.
- `src/thesis.sty` — all layout and all fixed strings: fonts, colors
  (`hpcgreen`/`hpcblue`/`hpcblack`/`hpcgray`), KOMA section styling, headers, listings,
  siunitx, algorithm2e, acro, caption defaults, TikZ (`calc`, `positioning`), biblatex,
  hyperref, cleveref, draft mode. Links are black text with thin colored border boxes
  (annotation-only, never printed); the ToC and the lists keep their links but suppress
  the boxes via `\ThesisBorderlessLinks`. Layout changes belong here, not in chapter files.
- `src/acronyms.tex` — the acronym database, a sibling of `references.bib`.
- `tools/lint.sh` — every source check; see below.
- `README.md` — the student-facing manual. It quotes `make help` verbatim, so keep that
  block in sync when a target changes. `.zed/tasks.json` mirrors the same list, one entry
  per `.PHONY` target in `make help` order — a new target means touching all three.
- Assets live under a chapter-ID folder mirroring the chapter number:
  `src/figures/<id>/`, `src/tables/<id>/`, `src/listings/<id>/`, where `<id>` is
  `00` (front matter/logos), `01`–`08` (main chapters), `99` (lists/appendix/declaration).
  The `figures/` and `tables/` folders all exist already (empty ones hold a `.gitkeep`);
  `listings/` folders are created when first needed. Use descriptive lowercase filenames
  without spaces.

### Logos are not MIT

The two files in `src/figures/00/` are excluded from the MIT License. The paragraph in
`LICENSE` about `hs-fulda_logo_2024.png` is wording agreed with the university — never
rephrase it; `README.md` (License section) and `src/figures/00/LOGO-NOTICE.txt` restate
it and must stay consistent with it. Never edit, recolor, crop, convert, vectorise, or
redraw (e.g. in TikZ) the university logo; scaling at the include site is the only
permitted operation. An `.svg` of it used to ship and was removed on purpose — do not add
one back. `FuldaHPC_Color_Full_Circle.pdf` is © Jonas Posner, likewise not MIT. The title
page wraps both includes in `\IfFileExists` so that deleting a logo, which `LICENSE` tells
outside users to do, leaves an empty slot instead of a fatal error — keep that.

### Chapter macro

Main chapters do **not** use `\chapter`. They use the custom three-argument macro from
`thesis.sty`:

```tex
\ThesisChapter{Title}{ch:label}{One-paragraph chapter overview.}
```

It emits a full-page chapter opener (badge number, rules, overview block), does the
`\refstepcounter`/`\addcontentsline`/`\label`/`\markboth` bookkeeping manually, and
starts the body on the next page. Chapters always open on an odd right-hand page
(`twoside`, `open=right`). After `\appendix`, `\ChapterBadgeNumber` automatically
switches from zero-padded digits to letters. Unnumbered front/back matter headings use
KOMA's `\addchap` instead (abstract, Zusammenfassung, acknowledgements, declaration).

Every chapter ships as a single `NN/00-<Name>.tex` file. A chapter that grows long may be
split: keep the `00-` file as the entry point holding `\ThesisChapter`, and add ordered
`\input` lines for `NN-Section.tex` files in the same folder. No shipped chapter is split,
so there is no live example to copy — the pattern is documented in `README.md`.

### One job per chapter

The eight-chapter split is deliberate and the guidance comments depend on it. Do not blur
these boundaries when editing chapter text:

- **05 Evaluation** presents results and does *not* interpret them.
- **06 Discussion** interprets the results and positions them against the related work in
  chapter 07; it must not introduce new results. Threats to validity live here.
- **07 Related Work** surveys the work of others and does *not* discuss this thesis's results.
- **08 Conclusion** has exactly two sections, Conclusion and Future Work. The research
  questions are answered *inside* the conclusion text, by name, not under a heading of
  their own.

An earlier version merged Related Work and Discussion into one chapter and told the student
in chapter 05 to "distinguish presentation from interpretation", which left it genuinely
ambiguous where interpretation belonged. That ambiguity is what the split fixes — restoring
it would undo the point.

**Chapter 01 has no section headings at all**, by explicit request: it is one file of
continuous prose in six parts — motivation, research questions, objectives, methodology,
contributions, structure. Do not add `\section`s back. The research questions and the
contributions are lists precisely because that is what keeps them findable without headings,
so those two must stay lists. Research questions use the `ThesisResearchQuestions`
environment from `thesis.sty` (enumitem-based, `label=RQ\arabic*`, `ref=RQ\arabic*`), which
is what lets chapter 08 answer them by name. Contributions exist separately from research
questions because a question states what was *asked* and a contribution what was *produced*;
the abstract asks for both.

Note the numbered comment banners in that file are written `% (1) Motivation`, not
`% 1. Motivation` — a digit followed by a period and a capital letter trips lint's
two-sentences-on-one-line check.

### Citations

All sources go in `src/references.bib` as BibLaTeX entries and are cited by key with
`\cite{...}`. Never hand-write a bibliography entry or reference list in a chapter file.
biblatex is configured `style=numeric, sorting=none` (citation order), backend biber.

- `title`, `booktitle`, and `journaltitle` are always double-braced — `{{...}}` — so
  biblatex cannot case-fold them.
- Include a `doi` field whenever one exists, without the `https://doi.org/` prefix.
- Without a DOI, provide `url` plus `urldate` in ISO `YYYY-MM-DD` format.
- No uncited entries, no cited keys missing from the `.bib`. Extra entry-type examples
  live at the end of the file, commented out precisely so they stay uncited — lint
  strips `%` lines before parsing entries.

### Figures, tables, listings, algorithms

Every float needs a caption and a unique label (`fig:`, `tab:`, `lst:`, `alg:`) and must
be referenced from the text — never a hand-typed number. Captions sit below the float.
Prefer vector PDF for diagrams and plots.

An `\input`-ed asset comes in two flavors, and mixing them up produces either a float
inside a float or an uncaptioned graphic:

- **Complete float** — the file itself opens `\begin{table}`/`\begin{figure}` and carries
  the `\caption` and `\label`; the chapter contributes nothing but the `\input` line.
  This is how external tables (`src/tables/05/example-results.tex`) and hand-drawn TikZ
  diagrams (`src/figures/03/example-architecture.tex`) work.
- **Bare body** — the gnuplot-generated `.tex` is only the picture. The chapter wraps it
  in its own `figure` environment and supplies caption and label there (see
  `src/chapters/05/00-Evaluation.tex`).

Captions are configured once, globally, in `thesis.sty`: `font=small`, `labelfont=bf`,
`justification=centering`, `singlelinecheck=true`, `position=bottom`. Every caption is
centered — do **not** add per-float `\captionsetup` overrides to new floats. Listings
get their look from the same global setup; `captionpos=b` in `\lstset` is what places
their captions below the code.

Source code is included with
`\lstinputlisting[float=htbp, language=..., caption={...}, label={lst:...}]{listings/<id>/file.c}`.
Pseudocode uses algorithm2e (`ruled,vlined,linesnumbered,algochapter`) with `\caption`
and `\label` at the end of the environment. Numbers and units use siunitx (`\qty`,
`\num`, `S` columns); German mode switches the decimal marker to a comma automatically.

TikZ is loaded with the `calc` and `positioning` libraries; draw diagrams of moderate
size directly in LaTeX and style them with `hpcgreen`/`hpcblue`/`hpcgray`.

Material adapted from external sources must be cited in the caption itself, and any
figure produced wholly or partly with an AI tool must be disclosed in its caption.

## Checks

`tools/lint.sh` holds all source checks; `make lint` runs it and `make submit-check`
runs it with `--submit`. It skips generated gnuplot `.tex` files, derived from the `.gp`
sources rather than hardcoded. `make lint` covers: missing `~` before a reference;
undefined references and citations (read from the last `tmp/Thesis.log`, so it is only
as fresh as your last build); two sentences on one line in sources *and* `README.md`;
duplicate labels; `fig:`/`tab:`/`lst:`/`alg:` labels that are never `\ref`'d; a bare
`\chapter` where `\ThesisChapter` belongs; `\label` before `\caption` inside a float;
straight double quotes; uncited `.bib` entries and cited keys with no entry; the
bibliography field rules (doi or url+urldate, no `https://doi.org/` prefix, ISO
`urldate`, double-braced titles); a missing or wrong-depth `% !TeX root` first line; and
a numbered heading with no `\label` on the same or the next line.

The sentence check masks abbreviations before looking for `. Capital` — English *and*
German ones (`bzw.`, `z.B.`, `Abb.`, `M.Sc.`, …) plus ordinal dates like `30. Juli`.
Add to `mask_abbreviations()` when a new false positive shows up. Markdown ordered-list
markers and fenced code blocks are stripped from `README.md` before the same check runs.

`--submit` adds leftover `TODO`s, `thesis-config.tex` placeholders, and overfull or
underfull boxes. It fails on the unmodified template on purpose — that is the point of a
submission gate.

When adding a check, verify it both ways: that it passes on the clean tree *and* that it
actually fires on a deliberately broken copy.
