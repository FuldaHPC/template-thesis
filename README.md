# FuldaHPC Thesis Template

LaTeX template for Bachelor's and Master's theses at the Department of Applied Computer Science at Fulda University of Applied Sciences.
It is intended primarily for work in High Performance Computing, Operating Systems, and related areas supervised by Prof. Dr. Jonas Posner.
The thesis can be written in English or in German.

## Scope

This repository provides a suggested structure, a formatting foundation, and practical guidance.
It is a template, not a content specification: all text, chapter titles, sections, examples, and other elements may be changed, rearranged, extended, or removed.
Unless the supervisor or the applicable examination regulations state otherwise, none of the proposed contents is mandatory.

**The complete chapter structure is only an example.
It must be reviewed and adapted to the specific thesis topic, research questions, methodology, and supervisor requirements.
Chapters and sections should be added, removed, merged, reordered, or renamed whenever this results in a more appropriate structure for the individual thesis.
Do not retain content solely because it is included in this template.**

Students remain responsible for the academic quality, correctness, originality, and completeness of their thesis.
Requirements issued by the examination board, the department, or the supervisors always take precedence.

## Requirements

Install the following tools to build the thesis locally:

- a current TeX Live or MacTeX distribution;
- `latexmk`;
- `biber`; and
- GNU Make or a compatible `make` implementation.

A current full TeX distribution normally contains all required LaTeX packages.
Gnuplot is only needed to regenerate or modify Gnuplot-based figures, including the example diagram.

## Quick start

1. Enter the thesis metadata in `src/thesis-config.tex`, including the thesis type and the language.
2. Adapt the proposed overall chapter structure to the thesis topic.
3. Replace the remaining example and placeholder content in `src/chapters/`.
4. Store figures, tables, and source-code listings in chapter-specific folders.
5. Add every cited source to `src/references.bib`.
6. Run `make` from the repository root.
7. Review the generated document at `out/Thesis.pdf`.

Do not edit files in `out/` or `tmp/`.
Both directories contain generated files that are replaced by the next build.

## Repository structure

```text
thesis-template/
├── Makefile
├── README.md
├── LICENSE
├── .latexmkrc
├── .vscode/
│   └── settings.json
├── .zed/
│   ├── settings.json
│   └── tasks.json
├── out/
├── tmp/
├── src/
│   ├── .texlabroot
│   ├── Thesis.tex
│   ├── thesis-config.tex
│   ├── thesis.sty
│   ├── references.bib
│   ├── acronyms.tex
│   ├── chapters/
│   │   ├── 00/
│   │   │   ├── 00-Frontmatter.tex
│   │   │   ├── 01-Titlepage.tex
│   │   │   ├── 02-Abstract.tex
│   │   │   ├── 03-Zusammenfassung.tex
│   │   │   └── 04-Acknowledgements.tex
│   │   ├── 01/00-Introduction.tex
│   │   ├── 02/00-Background.tex
│   │   ├── 03/00-Concepts.tex
│   │   ├── 04/00-Implementation.tex
│   │   ├── 05/00-Evaluation.tex
│   │   ├── 06/00-Discussion.tex
│   │   ├── 07/00-RelatedWork.tex
│   │   ├── 08/00-Conclusion.tex
│   │   └── 99/
│   │       ├── 00-Lists.tex
│   │       ├── 01-Appendix.tex
│   │       └── 02-Declaration.tex
│   ├── figures/
│   │   ├── 00/
│   │   ├── 03/
│   │   └── 05/
│   ├── listings/
│   │   └── 05/
│   └── tables/
│       └── 05/
└── tools/
    └── lint.sh
```

| Path                         | Purpose                                                                                                                                      |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `Makefile`                   | Defines the commands for compiling, opening, regenerating figures, checking, and cleaning the thesis.                                        |
| `LICENSE`                    | MIT, with the university logos explicitly excluded.                                                                                          |
| `.latexmkrc`                 | Makes any editor that runs `latexmk` use `out/` and `tmp/` exactly as `make` does.                                                           |
| `.vscode/settings.json`      | Shared LaTeX Workshop setup that builds through the Makefile.                                                                                |
| `.zed/`                      | Shared Zed setup: texlab configuration plus tasks that call the Makefile.                                                                    |
| `src/.texlabroot`            | Empty marker that pins the project root to `src/` for texlab.                                                                                |
| `out/`                       | Receives the finished PDF and its SyncTeX file; `out/Thesis.pdf` is under version control.                                                   |
| `tmp/`                       | Receives every auxiliary LaTeX file (`.aux`, `.log`, `.bbl`, …); created by the first build and ignored by Git.                              |
| `src/Thesis.tex`             | Assembles the front matter, main chapters, references, lists, appendix, and declaration in document order.                                   |
| `src/thesis-config.tex`      | Contains thesis-specific metadata for the title page and PDF metadata.                                                                       |
| `src/thesis.sty`             | Defines the typography, page layout, headers, chapter openers, captions, listings, bibliography style, fixed strings, and reusable commands. |
| `src/references.bib`         | Is the mandatory central bibliography database for every cited source.                                                                       |
| `src/acronyms.tex`           | Is the central list of acronym definitions.                                                                                                  |
| `src/chapters/00/`           | Contains the title page, abstract, Zusammenfassung, optional acknowledgements, and table of contents.                                        |
| `src/chapters/01/`–`08/`     | Contain the main thesis chapters.                                                                                                            |
| `src/chapters/99/`           | Contains the lists, optional appendix, supplementary material, and declaration of authorship.                                                |
| `src/figures/<chapter-id>/`  | Stores figures belonging to the corresponding chapter.                                                                                       |
| `src/tables/<chapter-id>/`   | Stores external table definitions belonging to the corresponding chapter.                                                                    |
| `src/listings/<chapter-id>/` | Stores source-code files included in the corresponding chapter.                                                                              |
| `tools/lint.sh`              | Checks the sources for common mistakes; run through `make lint` and `make submit-check`.                                                     |

Empty chapter folders already exist under `src/figures/` and `src/tables/`.
Only `src/figures/00/`, `src/figures/03/`, `src/figures/05/`, `src/tables/05/`, and `src/listings/05/` contain content; create further folders, such as `src/listings/04/`, as needed.
Chapter ID `00` is reserved for front-matter assets such as the university and Fulda HPC logos.

## Building the thesis

Run these commands from the repository root:

```console
$ make help
  make               Build out/Thesis.pdf
  make view          Build and open the PDF
  make draft         Build out/Thesis-draft.pdf with line numbers and TODOs
  make view-draft    Build and open the draft PDF
  make watch         Rebuild automatically on every save
  make figures       Regenerate gnuplot figures
  make lint          Check sources for common mistakes
  make submit-check  Run lint plus the pre-submission checks
  make clean         Delete tmp/ and all of out/ except Thesis.pdf
  make help          Show this list
```

| Command             | Effect                                                                                                                                           |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `make`              | Builds `src/Thesis.tex`, runs Gnuplot and the bibliography tool when required, and writes the PDF to `out/` and all auxiliary files to `tmp/`.   |
| `make view`         | Builds if necessary and opens `out/Thesis.pdf` in the default PDF viewer.                                                                        |
| `make draft`        | Builds a review copy at `out/Thesis-draft.pdf`; see [Draft builds](#draft-builds).                                                               |
| `make view-draft`   | Builds the review copy and opens it.                                                                                                             |
| `make watch`        | Runs `latexmk -pvc`, which rebuilds and refreshes the viewer on every save until you stop it.                                                    |
| `make figures`      | Regenerates each Gnuplot figure whose `.gp` script or `.dat` data is newer than its output; `make` runs this step automatically.                 |
| `make lint`         | Checks the sources for common mistakes; see [Checking the sources](#checking-the-sources).                                                       |
| `make submit-check` | Runs the same checks plus the pre-submission checks.                                                                                             |
| `make clean`        | Deletes `tmp/` and everything in `out/` except the version-controlled `Thesis.pdf`, so that the next `make` rebuilds from scratch.               |
| `make help`         | Lists the available targets.                                                                                                                     |

Deciding what needs recompiling is left entirely to `latexmk`, which tracks every file the document actually reads.
A new figure, table, or listing is therefore picked up automatically, whatever its file extension, and `make` never hands back a stale PDF.
Run `make` again after a change; generated compilation files must not be stored outside `out/` and `tmp/`.
`out/Thesis.pdf` is committed so that the current state of the thesis can be read straight from the repository; every rebuild changes it, so commit it together with the sources it was built from.

### Draft builds

A draft build is meant for circulation and feedback, never for submission.
It numbers every line, makes `\todo{...}` notes visible in the margin, and marks both page margins with a vertical DRAFT label.
The label sits beside the text rather than behind it, so it never obscures a figure, a table, or a formula.
Line numbers matter most in practice, because they let a supervisor point at an exact sentence.

`make draft` writes to `out/Thesis-draft.pdf`, so the review copy and the final PDF can exist side by side, and it leaves `src/thesis-config.tex` untouched.
`make view-draft` builds it and opens it straight away.
To make every build a draft instead, set `\ThesisDraft` to `true` in the configuration file.

A draft build prints one harmless warning about `\@parboxrestore`, which comes from the interaction between line numbering and the caption package.
It has no effect on the output and does not appear in a normal build.

## Writing conventions

Four conventions apply throughout the sources, and `make lint` enforces all of them.

Write one sentence per line.
Never wrap a sentence to a fixed column width, however long the line becomes, and never put two sentences on the same line.
This keeps changes small and readable, because editing one sentence changes exactly one line.
The rule applies to `.tex` files, to `src/thesis.sty`, and to this README.

Bind every citation and cross-reference to the preceding word with a non-breaking space (`~`) rather than a normal space:

```tex
Table~\ref{tab:example-results} lists the measurements.
The scheduler is described in~\cite{lozi2016LinuxScheduler}.
```

This applies to `\cite`, `\ref`, `\autoref`, `\pageref`, `\eqref`, `\cref`, and `\url`, and prevents a number or URL from being orphaned at the start of a line.

Write quotation marks with `\enquote{...}` instead of typing `"`.
The `csquotes` package then produces the correct marks for the selected language automatically, which matters because English and German use different ones.

Give every numbered heading a label: follow each `\section`, `\subsection`, or `\subsubsection` directly with a `\label{sec:...}` line, whether or not it is referenced yet.
Chapters need no extra label, because `\ThesisChapter` places one itself.

## Checking the sources

`make lint` reports mistakes that are easy to overlook while writing:

- a citation or cross-reference that is not bound to the preceding word with a non-breaking space;
- undefined references and citations, read from the log of the last build;
- two sentences on the same source line, in the sources and in this README;
- duplicate labels, and figure, table, listing, or algorithm labels that are never referenced from the text;
- a chapter started with `\chapter` instead of `\ThesisChapter`;
- a `\label` placed before its `\caption` inside a float, which silently produces a wrong cross-reference;
- straight double quotes that should be `\enquote{...}`;
- bibliography entries that are never cited and cited keys that are missing from `references.bib`;
- entries without a DOI or without a URL and an ISO `urldate`, and DOIs that still carry the `https://doi.org/` prefix;
- titles that are not double-braced;
- a source file whose first line does not name the root document, or names it with the wrong relative path; and
- a numbered section heading without a `\label` on the same or the following line.

`make submit-check` adds the checks that matter shortly before handing in: remaining `TODO` markers, unchanged placeholders in `src/thesis-config.tex`, and overfull or underfull boxes.
It deliberately fails on the unmodified template, which still contains `TODO` markers and placeholders.

Both targets read `tmp/Thesis.log` for the checks that depend on a build, so run `make` first to get current results.

## Central configuration

Edit the values in `src/thesis-config.tex`:

| Command                      | Value                                                       |
| ---------------------------- | ----------------------------------------------------------- |
| `\ThesisType`                | `bachelor` or `master`                                      |
| `\ThesisLanguage`            | `english` or `german`                                       |
| `\ThesisDraft`               | `true` or `false`                                           |
| `\ThesisTitle`               | Thesis title                                                |
| `\ThesisAuthor`              | Student's full name                                         |
| `\ThesisMatriculationNumber` | Student ID                                                  |
| `\ThesisEmail`               | Contact address                                             |
| `\ThesisProgram`             | Study program, for example the degree and its name          |
| `\ThesisSupervisorOne`       | First supervisor or reviewer                                |
| `\ThesisSupervisorTwo`       | Second supervisor or reviewer                               |
| `\ThesisKeywords`            | Comma-separated keywords for the PDF metadata, may be empty |
| `\ThesisSubmissionDate`      | Optional submission date                                    |

An invalid value for `\ThesisType`, `\ThesisLanguage`, or `\ThesisDraft` stops the build with an explicit error rather than producing a silently wrong document.
Leaving `\ThesisProgram` or `\ThesisKeywords` empty simply omits them.

Enter a manual date in an unambiguous format:

```tex
\newcommand{\ThesisSubmissionDate}{30 July 2026}
```

Leave the value empty to use the current compilation date automatically, formatted in the selected language:

```tex
\newcommand{\ThesisSubmissionDate}{}
```

Only edit the values inside the braces.
Discuss layout changes with the supervisor if they affect formal requirements.

## Language

`\ThesisLanguage` switches hyphenation, the date format, the quotation marks produced by `\enquote{...}`, and every fixed heading the template itself contributes.
That includes the title page labels, the chapter opener, the names of all lists, the bibliography heading, and the declaration of authorship.

Both languages are always loaded, so the English abstract and the German Zusammenfassung are each hyphenated correctly no matter which language the thesis uses.

The chapter and section titles shipped with the template are translated as well, through a helper that picks one of two strings:

```tex
\ThesisChapter{\ThesisText{Background}{Grundlagen}}{ch:background}{...}
```

Three things deliberately stay in English regardless of the setting.
The long `TODO` guidance comments are English, because they are instructions to the author rather than part of the thesis.
The short hint paragraphs inside the example sections are English too, and they disappear as soon as those example sections are deleted.
Pseudocode control-flow keywords such as `for`, `while`, and `return` also stay English, which is the norm in German computer science writing; only the `Eingabe` and `Ausgabe` headers are translated.

## Organising chapters

The following main chapters are one possible example:

1. Introduction
2. Background
3. Concepts and Architecture
4. Implementation
5. Experiments and Evaluation
6. Discussion
7. Related Work
8. Conclusion and Future Work

This sequence is not a required thesis structure.
Its chapters, order, sectioning, and level of detail must be adapted to the topic and research methodology; chapters may be renamed, combined, split, reordered, added, or removed.
Only retain elements that support the argument and objectives of the individual thesis.

Each chapter has one job, and the guidance comments are written on that assumption.
Chapter 5 presents results without interpreting them, chapter 6 interprets them, and chapter 7 surveys the work of others and positions the thesis within it.
Keeping the three apart separates what was measured from what it means, and both from what others have done.

A Bachelor's thesis may legitimately merge Related Work back into Discussion, which gives the shorter seven-chapter structure.
That is a reasonable simplification when the literature comparison is brief, and it saves a full chapter opener page; discuss it with the supervisor.

As non-binding orientation, a Bachelor's thesis usually has about 30 to 50 pages of body text and a Master's thesis about 50 to 80.
Body text means the chapters, excluding title page, front matter, bibliography, lists, and appendix.
The examination regulations and the supervisor always take precedence over these figures.

Regardless of the selected content structure, each chapter starts on an odd-numbered right-hand page for double-sided printing.
A dedicated opening page contains the chapter title and brief overview; the chapter body begins on the following page.

The introduction is written as continuous prose, without section headings, in six parts: motivation and problem statement, research questions, objectives, methodology, contributions, and the structure of the thesis.
The research questions use the `ThesisResearchQuestions` environment, which numbers them RQ1, RQ2, and so on, and lets the conclusion refer to each one by name.
The contributions are an itemized list.
Those two lists are what makes both findable without headings, so keep them as lists.

Every chapter is a single file by default.
A long chapter can be split across several files: keep a `00-<Name>.tex` entry point holding the chapter title and overview, and `\input` one file per section from it in reading order.

```text
src/chapters/04/
├── 00-Implementation.tex
├── 01-Architecture.tex
└── 02-Deployment.tex
```

```tex
\input{chapters/04/01-Architecture}
\input{chapters/04/02-Deployment}
```

Paths are relative to `src/Thesis.tex`, must not begin with `/`, and may omit the `.tex` extension.
Numbered filename prefixes make the inclusion order explicit.
Splitting is worth doing once a chapter grows past a few pages; below that a single file is easier to navigate.

## Front and back matter

The front matter contains the title page, the English abstract, the German Zusammenfassung, an optional acknowledgements page, and the table of contents.
The acknowledgements are commented out in `src/chapters/00/00-Frontmatter.tex`; remove the comment character to include them.
Check with the supervisor whether a Zusammenfassung is required, and remove the file from the front matter if it is not.

The lists of figures, tables, listings, algorithms, and acronyms sit behind the bibliography, in `src/chapters/99/00-Lists.tex`.
Each one is printed only if it actually has entries, so a thesis without listings does not carry an empty List of Listings.
Because the decision is based on the previous compilation, a newly added first figure appears in the List of Figures one `latexmk` pass later, which `latexmk` performs anyway.
To move the lists in front of the first chapter instead, move the corresponding `\input` line into `src/chapters/00/00-Frontmatter.tex`, directly after `\tableofcontents`.

`src/chapters/99/02-Declaration.tex` contains the official declaration of authorship of Hochschule Fulda, in the version dated November 2025.
The German wording is the binding original and the English version is a translation; `\ThesisLanguage` selects which one is printed.
Verify the text against the current official form before submitting, and note that its third paragraph requires the documentation of any AI tools used to be attached to the thesis.

## Included examples

| Topic                                         | Example location                                                                     |
| --------------------------------------------- | ------------------------------------------------------------------------------------ |
| Paper and website citations                   | `src/chapters/07/00-RelatedWork.tex`                                                 |
| Numbered research questions and contributions | `src/chapters/01/00-Introduction.tex`                                                |
| BibLaTeX entries with DOI and URL             | `src/references.bib`                                                                 |
| Numbered equations and acronyms               | `src/chapters/02/00-Background.tex`                                                  |
| Diagram drawn directly in LaTeX with TikZ     | `src/figures/03/example-architecture.tex`                                            |
| Pseudocode set with algorithm2e               | `src/chapters/04/00-Implementation.tex`                                              |
| External table with aligned numbers and units | `src/tables/05/example-results.tex`                                                  |
| Gnuplot source and generated vector figure    | `src/figures/05/example-scaling-diagram.gp` and the generated `.tex`, `.eps`, `.pdf` |
| Measurement data read by a Gnuplot script     | `src/figures/05/example-scaling-data.dat`                                            |
| Figure inclusion and textual cross-reference  | `src/chapters/05/00-Evaluation.tex` and `src/chapters/03/00-Concepts.tex`            |
| External source-code listing                  | `src/listings/05/example-parallel-sum.c`                                             |
| All lists                                     | `src/chapters/99/00-Lists.tex`                                                       |

### References and citations

**All references must be managed in `src/references.bib`.
Never create bibliography entries or reference lists manually.**

Add each source as a valid BibLaTeX/BibTeX entry with a unique citation key and cite that key in the text:

```tex
An example citation of a peer-reviewed paper is~\cite{lozi2016LinuxScheduler}.
An official website is cited in the same way~\cite{schedmdSlurmOverview}.
```

Always wrap `title`, `booktitle`, and `journaltitle` in double braces:

```bibtex
title = {{The Linux Scheduler: A Decade of Wasted Cores}},
```

The inner pair protects the capitalization.
Without it, biblatex is free to lowercase the words itself, which turns a carefully capitalized paper title into something the original authors never wrote.

The bibliography contains two real examples: a peer-reviewed conference paper with a DOI and an official website without a DOI.
Their use is demonstrated in `src/chapters/07/00-RelatedWork.tex`; replace or remove them if they are not relevant to the thesis.
Commented-out examples of the other common entry types are included at the end of the file.

Bibliographic databases such as [DBLP](https://dblp.org/) can help find and export publication metadata.
Always verify exported data against the original publication.

Every source must contain a valid DOI whenever one exists:

```bibtex
doi = {10.xxxx/example-doi},
```

Do not include `https://doi.org/` in the `doi` field.
Before submission, check every DOI for validity, typographical errors, and correspondence with the cited publication.
If no DOI exists, provide a stable URL and access date:

```bibtex
url     = {https://example.org/publication},
urldate = {2026-07-30},
```

Use ISO format `YYYY-MM-DD` for `urldate`.
Do not leave uncited entries in the bibliography and do not cite keys that are missing from `references.bib`.

### Figures and tables

Store assets under the ID of the chapter that uses them:

```text
src/figures/01/system-overview.pdf
src/tables/05/benchmark-results.tex
```

Use descriptive lowercase filenames without spaces.
Prefer vector PDF for diagrams and plots; use sufficiently high-resolution PNG or JPEG for raster images.
The Gnuplot example in chapter `05` uses the `epslatex` terminal, so its labels are typeset by LaTeX in the document font.
`make figures` generates the `.tex`, `.eps`, and `.pdf` next to the `.gp` script, and the figure is included without a file extension and without `width=`:

```tex
\input{figures/05/example-scaling-diagram}
```

Set the plot size in the `.gp` file via `set terminal ... size`.
The chapter can additionally shrink the drawing by wrapping the `\input` in `\resizebox{0.75\textwidth}{!}{...}`, as chapter `05` demonstrates, at the cost of scaling the labels along with it.
Measurements belong in a data file next to the script rather than in the plot command, so the numbers can be replaced without touching the plot:

```gnuplot
DATA = "figures/05/example-scaling-data.dat"
plot DATA using 1:2 with linespoints title "mean time"
```

The data file is whitespace-separated, with the column names on a leading comment line that Gnuplot skips automatically:

```text
# Threads MeanTime[s] Variance[s^2] StdDev[s] Speedup
1 81.543233 0.000026 0.005059 1.000000
2 40.885742 0.000092 0.009604 1.994417
```

Note that `make` runs Gnuplot from inside `src/`, so `set output` and every data-file path in a `.gp` script are relative to `src/`, not to the repository root.
Editing any `.dat` file under `src/figures/` makes the next `make` redraw the plots.

Smaller diagrams can be drawn directly in LaTeX with TikZ instead, which keeps them vector-based and matches the fonts and colors of the surrounding text.
Chapter `03` demonstrates this: the drawing lives in `src/figures/03/example-architecture.tex` together with its caption and label, and the chapter only includes it:

```tex
\input{figures/03/example-architecture}
```

The example table works the same way and is included with:

```tex
\input{tables/05/example-results}
```

Every figure and table needs a meaningful caption and a unique label and should be referenced from the text.
Inside a float, always write `\caption` before `\label`.
A `\label` placed first captures the number of the enclosing section instead of the float, and LaTeX reports nothing; `make lint` catches it.

Beyond `\ref`, the `\cref` command prints the type of the target itself:

```tex
\Cref{tab:example-results} and~\cref{fig:example-scaling} present the same data.
```

That way a float which later changes from a table into a figure does not leave a wrong word behind in the running text.

Material taken or adapted from external sources must be cited explicitly in the caption or surrounding text; a bibliography entry alone is insufficient.
Figures created entirely or partially with an AI-based tool must be identified as such, properly referenced, and clearly disclosed in the figure caption.

Use [Gnuplot](https://www.gnuplot.info/) for suitable plots and [draw.io/diagrams.net](https://app.diagrams.net/) for freely designed diagrams.
The same guidance is displayed in the example section of chapter `05`.

### Equations, algorithms, and units

Number an equation and reference it with `\eqref`, never by typing the number:

```tex
\begin{equation}
  \label{eq:speedup}
  S(p) = \frac{T(1)}{T(p)}
\end{equation}
```

Pseudocode is set with `algorithm2e` and is the right level of detail whenever the idea matters more than the syntax of a particular language.
Captioned algorithms are collected automatically in the List of Algorithms.
Chapter `04` contains a complete example.

Numbers and units are set with `siunitx`, so that they look the same everywhere in the document:

```tex
a runtime of \qty{120.0}{\second} and a bandwidth of \qty{2.4}{\giga\byte\per\second}
```

In result tables, the `S` column type aligns numbers on the decimal marker, as demonstrated in `src/tables/05/example-results.tex`.
In German, the decimal marker automatically becomes a comma.

### Acronyms

Declare every acronym once in `src/acronyms.tex`:

```tex
\DeclareAcronym{hpc}{
  short = HPC,
  long  = High Performance Computing
}
```

Write `\ac{hpc}` in the text.
The first use expands to the long form followed by the short form in parentheses, and every later use prints only the short form, so an acronym can never be introduced twice or used before it is introduced.
Only acronyms that are actually used appear in the List of Acronyms, and unused declarations are harmless.

### Source-code listings

Keep source code in the listing folder of the chapter where it is discussed and include it with `\lstinputlisting`:

```tex
\lstinputlisting[
  float=htbp,
  language=C,
  caption={Example OpenMP reduction for summing an array in parallel.},
  label={lst:example-parallel-sum}
]{listings/05/example-parallel-sum.c}
```

Select the appropriate language for syntax highlighting.
Every relevant listing needs a concise caption, a unique `lst:` label, and a reference from the surrounding text.
Captions appear below the source code, and captioned listings are collected automatically in the List of Listings.

## Editor setup

`.latexmkrc` configures `latexmk` itself, so any editor that builds by calling it writes the PDF to `out/` and the auxiliary files to `tmp/`, and resolves paths exactly as `make` does.
This prevents `.aux` and `.log` files from appearing next to the sources.

Every source file starts with a line naming the root document:

```tex
% !TeX root = ../../Thesis.tex
```

This matters because a language server compiles whichever file you currently have open.
A chapter file is not a standalone document, so without that line it fails to build on its own.
The comment is understood by texlab, LaTeX Workshop, TeXstudio, and TeXShop alike, and `make lint` checks that every file carries it with the correct relative path.
Keep it as the first line when you add a new chapter or asset file.
The empty `src/.texlabroot` marker does the same job for texlab specifically: it pins the project root to `src/`, which is the directory the build expects to run from.

The build passes `-synctex=1`, so jumping between a source line and the corresponding place in the PDF works in any editor that supports it.

`.vscode/settings.json` and `.zed/settings.json` are both committed.
The VS Code setup drives LaTeX Workshop through the Makefile, with a second recipe for draft builds.
The Zed setup configures texlab and adds `.zed/tasks.json`, which exposes `make`, `make draft`, `make view-draft`, `make lint`, and `make submit-check` in the task picker.
Both are starting points rather than fixed requirements; adjust them to your own setup, and note that neither has been tested on every machine.
Users of other editors need nothing beyond `.latexmkrc` and the root comments.

Zed has no built-in PDF viewer, so it drives an external one.
The committed configuration points at Skim in its default macOS location; change the path if you installed it elsewhere, or swap in zathura, sioyek, okular, or evince.
Forward search from editor to PDF works out of the box.
Inverse search back from the PDF is not something texlab can configure for Skim automatically, so it needs a one-time manual setting inside Skim's own preferences; the other viewers listed above do not need this.

## License

The template is available under the MIT License, see `LICENSE`.

The two logos in `src/figures/00/` are explicitly excluded from that license; the binding wording is in `LICENSE`.

`hs-fulda_logo_2024.png` is a trademark and copyrighted work of Fulda University of Applied Sciences.
It is included solely so that students of the university can produce a thesis title page that complies with its corporate design.
It may be scaled, and nothing else: no modification, no recoloring, no extraction of individual elements, and no use outside that purpose.

`FuldaHPC_Color_Full_Circle.pdf` is the logo of Fulda HPC, copyright Jonas Posner, and any use beyond a thesis written in that group requires permission.

If you reuse the template outside Fulda University of Applied Sciences, delete both files and include your own institution's logo in `src/chapters/00/01-Titlepage.tex` instead.
The title page still builds while a logo file is missing, leaving its slot empty.

## Recommended workflow and final checks

- Compile frequently and review unresolved references, missing citations, overfull boxes, and other LaTeX warnings.
- Run `make lint` while writing to catch these and the other common mistakes early.
- Use `make watch` while writing longer passages, so every save is compiled without further action.
- Send `make draft` output for feedback, because its line numbers let reviewers point at an exact sentence.
- Use `\label` and `\ref` instead of typing chapter, section, figure, table, equation, or appendix numbers manually.
- Keep source files focused and comment only non-obvious LaTeX decisions.
- Confirm that all title-page data, the thesis type, the language, and the submission date are correct.
- Ensure that every citation resolves, every bibliography entry is used, and every DOI and URL is valid.
- Ensure that every relevant figure, table, equation, listing, algorithm, and appendix is referenced from the text.
- Review the table of contents and all lists.
- Remove all placeholders, example data, and unused template content.
- Set `\ThesisDraft` back to `false` before producing the final PDF.
- Check the final PDF at normal zoom and in a two-page view, including blank pages and right-hand chapter openings.
- Print representative pages to verify margins, grayscale readability, figure quality, and binding-side spacing.
- Confirm compliance with the examination regulations and supervisor requirements.
- Before submission, run `make clean`, then `make`, then `make submit-check`, and review `out/Thesis.pdf`.
