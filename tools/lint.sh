#!/bin/sh
# Checks the thesis sources.
# Usage: tools/lint.sh [--submit]
#
# Without --submit only the checks worth running while drafting are executed.
# --submit adds the pre-submission checks and reports leftover template content.

set -u

# Paths below are relative to the repository root, so go there first.
cd "$(dirname "$0")/.." || exit 1

SRC=src
MAIN=Thesis
BIB=$SRC/references.bib
LOG=tmp/$MAIN.log
DOC=README.md

mode=lint
[ "${1:-}" = "--submit" ] && mode=submit

problems=0

# Gnuplot rewrites its .tex on every build, so those files are never checked.
tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp".*' EXIT
find "$SRC/figures" -name '*.gp' 2>/dev/null | sed 's/\.gp$/.tex/' > "$tmp"
echo '/nonexistent/never/matches' >> "$tmp"
FILES=$(find "$SRC" \( -name '*.tex' -o -name '*.sty' \) | grep -vxFf "$tmp" | sort)
TEXFILES=$(printf '%s\n' "$FILES" | grep '\.tex$')

# Masks abbreviations and ordinal dates so that they do not look like the end of
# a sentence. Reads a file on stdin and writes the masked text to stdout.
mask_abbreviations() {
  sed -E \
    -e 's/\\,//g' \
    -e 's/e\.g\./eg/g'     -e 's/i\.e\./ie/g'      -e 's/cf\./cf/g' \
    -e 's/vs\./vs/g'       -e 's/etc\./etc/g'      -e 's/approx\./approx/g' \
    -e 's/resp\./resp/g'   -e 's/Prof\./Prof/g'    -e 's/Dr\./Dr/g' \
    -e 's/et al\./et al/g' -e 's/Fig\./Fig/g'      -e 's/Eq\./Eq/g' \
    -e 's/No\./No/g'       -e 's/Sec\./Sec/g'      -e 's/Ch\./Ch/g' \
    -e 's/M\.Sc\./MSc/g'   -e 's/B\.Sc\./BSc/g'    -e 's/Ph\.D\./PhD/g' \
    -e 's/Dipl\./Dipl/g'   -e 's/Ing\./Ing/g'      -e 's/St\./St/g' \
    -e 's/bzw\./bzw/g'     -e 's/z\.B\./zB/g'      -e 's/d\.h\./dh/g' \
    -e 's/u\.a\./ua/g'     -e 's/o\.g\./og/g'      -e 's/s\.o\./so/g' \
    -e 's/s\.u\./su/g'     -e 's/ggf\./ggf/g'      -e 's/usw\./usw/g' \
    -e 's/vgl\./vgl/g'     -e 's/ca\./ca/g'        -e 's/evtl\./evtl/g' \
    -e 's/inkl\./inkl/g'   -e 's/bspw\./bspw/g'    -e 's/Abb\./Abb/g' \
    -e 's/Tab\./Tab/g'     -e 's/Kap\./Kap/g'      -e 's/Nr\./Nr/g' \
    -e 's/Hrsg\./Hrsg/g'   -e 's/Aufl\./Aufl/g'    -e 's/Bd\./Bd/g' \
    -e 's/([0-9])\. (Januar|Februar|M.rz|April|Mai|Juni|Juli|August|September|Oktober|November|Dezember|January|February|March|May|June|July|October|December)/\1 \2/g'
}

# ---------------------------------------------------------------------------
# 1. A cross-reference must be bound to the previous word with ~.
# ---------------------------------------------------------------------------
hits=$(grep -nE ' \\(cite|ref|autoref|pageref|eqref|cref|Cref|url)\{' $FILES 2>/dev/null || true)
if [ -n "$hits" ]; then
  printf '%s\n' "$hits" | while IFS= read -r l; do
    printf 'missing ~ before reference: %s\n' "$l"
  done
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# 2. Undefined references and citations, taken from the last build log.
# ---------------------------------------------------------------------------
if [ -f "$LOG" ]; then
  # LaTeX writes "Reference `x' on page 5 undefined ...", quoting references with
  # a backtick and citations with a straight quote, and wraps the log at 79
  # columns. Match the whole warning line rather than an exact phrase.
  undef=$(grep -E "LaTeX Warning: (Reference|Citation) .*undefined" "$LOG" \
    | sed 's/[[:space:]]*$//' | sort -u || true)
  if [ -z "$undef" ]; then
    # A very long key can push "undefined" onto the next line; fall back to the
    # summary LaTeX prints at the end of the run.
    undef=$(grep -E "LaTeX Warning: There were undefined" "$LOG" | sort -u || true)
  fi
  if [ -n "$undef" ]; then
    printf '%s\n' "$undef" | while IFS= read -r l; do
      printf '%s: %s\n' "$LOG" "$l"
    done
    problems=$((problems + 1))
  fi
else
  printf 'note: %s not found, run make first to check undefined references\n' "$LOG"
fi

# ---------------------------------------------------------------------------
# 3. One sentence per line, in the sources and in README.md.
# ---------------------------------------------------------------------------
for f in $FILES; do
  mask_abbreviations < "$f" \
  | grep -nE '[a-z0-9)]\. +[A-Z]' | while IFS= read -r l; do
      printf '%s:%s  two sentences on one line\n' "$f" "${l%%:*}"
    done
done > "$tmp".sent

# Fenced code blocks in the README are skipped; their content is not prose.
# A leading "1. " is an ordered-list marker, not the end of a sentence.
if [ -f "$DOC" ]; then
  mask_abbreviations < "$DOC" \
  | sed -E 's/^[[:space:]]*[0-9]+\. //' \
  | awk '
      /^```/ { fence = !fence; next }
      fence  { next }
      { print NR ":" $0 }
    ' \
  | grep -E ':.*[a-z0-9)]\. +[A-Z]' | while IFS= read -r l; do
      printf '%s:%s  two sentences on one line\n' "$DOC" "${l%%:*}"
    done >> "$tmp".sent
fi

if [ -s "$tmp".sent ]; then
  cat "$tmp".sent
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# 4. Duplicate labels, and 5. float labels that are never referenced.
# ---------------------------------------------------------------------------
# Label keys contain colons, so location and key are separated by a pipe.
grep -nHoE '\\label\{[^}]*\}|label=\{[^}]*\}' $FILES 2>/dev/null \
  | sed -E 's/^([^:]+:[0-9]+):.*\{([^}]*)\}$/\1|\2/' > "$tmp".labels || true

dups=$(cut -d'|' -f2 "$tmp".labels | sort | uniq -d || true)
if [ -n "$dups" ]; then
  for d in $dups; do
    printf 'label "%s" is defined more than once:\n' "$d"
    # Exact field match, so that "fig:a" does not also list "fig:ab".
    awk -F'|' -v k="$d" '$2 == k { print "  " $1 }' "$tmp".labels
  done
  problems=$((problems + 1))
fi

grep -ohE '\\(auto|page|eq|c|C)?ref\{[^}]*\}' $FILES 2>/dev/null \
  | sed -e 's/.*{//' -e 's/}//' | tr ',' '\n' | tr -d ' ' | sort -u > "$tmp".refs || true

: > "$tmp".orphans
while IFS='|' read -r loc key; do
  case "$key" in
    fig:*|tab:*|lst:*|alg:*)
      grep -qxF "$key" "$tmp".refs || \
        printf '%s  label "%s" is never referenced\n' "$loc" "$key" >> "$tmp".orphans
      ;;
  esac
done < "$tmp".labels
if [ -s "$tmp".orphans ]; then
  cat "$tmp".orphans
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# 6. Numbered chapters must use \ThesisChapter, not \chapter.
# ---------------------------------------------------------------------------
chap=$(grep -nE '\\chapter[{[]' $TEXFILES 2>/dev/null || true)
if [ -n "$chap" ]; then
  printf '%s\n' "$chap" | while IFS= read -r l; do
    printf 'use \\ThesisChapter{title}{ch:label}{overview}, not \\chapter: %s\n' "$l"
  done
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# 7. Inside a float, \label must follow \caption.
#    A \label placed before the \caption captures the number of the enclosing
#    counter instead of the float's own, so the reference silently points
#    somewhere else. LaTeX gives no warning for this.
# ---------------------------------------------------------------------------
for f in $TEXFILES; do
  awk -v f="$f" '
    /\\begin\{(figure|table|algorithm|wrapfigure|SCfigure)\*?\}/ {
      infloat = 1; capline = 0; labline = 0; next
    }
    infloat && /\\caption/ && capline == 0 { capline = NR }
    infloat && /\\label\{/  && labline == 0 { labline = NR }
    /\\end\{(figure|table|algorithm|wrapfigure|SCfigure)\*?\}/ {
      if (infloat && labline > 0 && capline > 0 && labline < capline)
        printf "%s:%d  \\label comes before \\caption, so the reference will show the wrong number\n", f, labline
      infloat = 0; capline = 0; labline = 0
    }
  ' "$f"
done > "$tmp".labelorder
if [ -s "$tmp".labelorder ]; then
  cat "$tmp".labelorder
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# 8. Straight double quotes produce the wrong glyphs; csquotes is loaded.
#    Comments and verbatim material are ignored.
# ---------------------------------------------------------------------------
for f in $FILES; do
  sed -e 's/\\%/PERCENT/g' -e 's/%.*//' -e 's/\\"//g' "$f" \
  | grep -n '"' | grep -vE '\\(verb|lstinline|lstset|lstinputlisting|DeclareAcronym)' \
  | while IFS= read -r l; do
      printf '%s:%s  straight quote, use \\enquote{...}\n' "$f" "${l%%:*}"
    done
done > "$tmp".quotes
if [ -s "$tmp".quotes ]; then
  cat "$tmp".quotes
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# 9. Bibliography: uncited entries and cited keys with no entry.
# ---------------------------------------------------------------------------
if [ -f "$BIB" ]; then
  grep -oE '^[[:space:]]*@[a-zA-Z]+\{[^,]+,' "$BIB" \
    | sed -e 's/.*{//' -e 's/,$//' | tr -d ' ' | sort -u > "$tmp".bibkeys

  grep -ohE '\\cite[a-zA-Z]*(\[[^]]*\])*\{[^}]*\}' $FILES 2>/dev/null \
    | sed -e 's/.*{//' -e 's/}//' | tr ',' '\n' | tr -d ' ' \
    | grep -v '^$' | sort -u > "$tmp".citekeys || true

  uncited=$(comm -23 "$tmp".bibkeys "$tmp".citekeys)
  if [ -n "$uncited" ]; then
    for k in $uncited; do
      printf '%s: entry "%s" is never cited\n' "$BIB" "$k"
    done
    problems=$((problems + 1))
  fi

  missing=$(comm -13 "$tmp".bibkeys "$tmp".citekeys)
  if [ -n "$missing" ]; then
    for k in $missing; do
      printf '%s: cited key "%s" has no entry\n' "$BIB" "$k"
    done
    problems=$((problems + 1))
  fi

  # ------------------------------------------------------------------------
  # 10. Every entry needs a doi, or a url with an ISO urldate.
  #     The doi field must not carry the https://doi.org/ prefix.
  # 11. Titles must be double-braced so that biblatex cannot case-fold them.
  # ------------------------------------------------------------------------
  # Commented-out example entries are dropped first, so that they are not
  # parsed as real entries by the record splitter below.
  sed 's/^[[:space:]]*%.*//' "$BIB" | awk -v bib="$BIB" '
    BEGIN { RS = "@"; split("title booktitle journaltitle", tf, " ") }
    NR == 1 { next }
    {
      key = $0
      sub(/^[^{]*\{/, "", key)
      sub(/[,\n].*/, "", key)
      gsub(/[ \t]/, "", key)
      if (key == "") next

      hasdoi     = ($0 ~ /(\n|^)[ \t]*doi[ \t]*=/)
      hasurl     = ($0 ~ /(\n|^)[ \t]*url[ \t]*=/)
      hasurldate = ($0 ~ /(\n|^)[ \t]*urldate[ \t]*=/)

      if (hasdoi) {
        d = $0
        match(d, /(\n|^)[ \t]*doi[ \t]*=[ \t]*[{"][^}"]*/)
        v = substr(d, RSTART, RLENGTH)
        sub(/^[^{"]*[{"]/, "", v)
        if (v ~ /doi\.org/ || v ~ /^https?:/)
          printf "%s: %s: strip the https://doi.org/ prefix from doi\n", bib, key
      } else if (!hasurl || !hasurldate) {
        printf "%s: %s: needs a doi, or a url with urldate\n", bib, key
      }

      if (hasurldate) {
        u = $0
        match(u, /(\n|^)[ \t]*urldate[ \t]*=[ \t]*[{"][^}"]*/)
        v = substr(u, RSTART, RLENGTH)
        sub(/^[^{"]*[{"]/, "", v)
        if (v !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/)
          printf "%s: %s: urldate \"%s\" is not YYYY-MM-DD\n", bib, key, v
      }

      for (i = 1; i <= 3; i++) {
        f = tf[i]
        if ($0 ~ "(\n|^)[ \t]*" f "[ \t]*=" && $0 !~ "(\n|^)[ \t]*" f "[ \t]*=[ \t]*\\{\\{")
          printf "%s: %s: %s must be double-braced, {{...}}, so biblatex keeps its capitalization\n", bib, key, f
      }
    }
  ' > "$tmp".bib
  if [ -s "$tmp".bib ]; then
    cat "$tmp".bib
    problems=$((problems + 1))
  fi
fi

# ---------------------------------------------------------------------------
# 12. Every source must name the root document on its first line.
#     An editor's language server builds whichever file is open, so without this
#     comment a chapter file is compiled on its own and fails. texlab, LaTeX
#     Workshop, TeXstudio and TeXShop all honour it. Generated gnuplot .tex
#     files are already excluded from $FILES, and the root cannot point at itself.
# ---------------------------------------------------------------------------
for f in $FILES; do
  [ "$f" = "$SRC/$MAIN.tex" ] && continue

  dir=${f%/*}
  rel=${dir#"$SRC"}
  rel=${rel#/}
  if [ -z "$rel" ]; then
    want="$MAIN.tex"
  else
    depth=$(printf '%s' "$rel" | awk -F/ '{print NF}')
    want=""
    i=0
    while [ "$i" -lt "$depth" ]; do
      want="../$want"
      i=$((i + 1))
    done
    want="$want$MAIN.tex"
  fi

  got=$(head -1 "$f" | sed -n 's/^%[[:space:]]*!TeX root[[:space:]]*=[[:space:]]*//p' | tr -d '[:space:]')
  if [ -z "$got" ]; then
    printf '%s:1  first line must be "%% !TeX root = %s"\n' "$f" "$want"
  elif [ "$got" != "$want" ]; then
    printf '%s:1  root path is "%s" but should be "%s"\n' "$f" "$got" "$want"
  fi
done > "$tmp".texroot
if [ -s "$tmp".texroot ]; then
  cat "$tmp".texroot
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# 13. Every numbered heading carries a \label on the same or the next line.
#     Chapters are covered separately: \ThesisChapter places its own label.
#     Comments are stripped first, so a \section shown in a guidance comment
#     does not count as a heading.
# ---------------------------------------------------------------------------
for f in $TEXFILES; do
  sed -e 's/\\%/PERCENT/g' -e 's/%.*//' "$f" | awk -v f="$f" '
    pending && /\\label\{/ { pending = 0 }
    pending { printf "%s:%d  heading has no \\label on the same or the next line\n", f, headline; pending = 0 }
    /\\(sub)?(sub)?section\{/ && !/\\label\{/ { pending = 1; headline = NR }
    END { if (pending) printf "%s:%d  heading has no \\label on the same or the next line\n", f, headline }
  '
done > "$tmp".seclabels
if [ -s "$tmp".seclabels ]; then
  cat "$tmp".seclabels
  problems=$((problems + 1))
fi

# ---------------------------------------------------------------------------
# Pre-submission only: leftover template content and bad boxes.
# ---------------------------------------------------------------------------
if [ "$mode" = submit ]; then
  todos=$(grep -rn 'TODO' $FILES 2>/dev/null | wc -l | tr -d ' ')
  if [ "$todos" != 0 ]; then
    printf '%s TODO comments still present:\n' "$todos"
    grep -rn 'TODO' $FILES 2>/dev/null | sed 's/^/  /' | head -20
    [ "$todos" -gt 20 ] && printf '  ... and %s more\n' "$((todos - 20))"
    problems=$((problems + 1))
  fi

  # The placeholders all live in thesis-config.tex, and searching only there
  # keeps the check from firing on look-alikes elsewhere, such as the number
  # 1234567 in a thesis.sty comment.
  for p in 'Title of the Thesis' 'First\_name Last\_name' '123456' \
           'first.last@cs.hs-fulda.de' 'Title, name of second supervisor' \
           'Name of the study program'; do
    # /dev/null keeps grep printing the file name even though only one file is searched.
    hit=$(grep -nF "$p" "$SRC/thesis-config.tex" /dev/null 2>/dev/null || true)
    if [ -n "$hit" ]; then
      printf '%s\n' "$hit" | while IFS= read -r l; do
        printf 'placeholder still present: %s\n' "$l"
      done
      problems=$((problems + 1))
    fi
  done

  if [ -f "$LOG" ]; then
    boxes=$(grep -cE '^(Overfull|Underfull)' "$LOG" || true)
    if [ "$boxes" != 0 ]; then
      printf '%s overfull/underfull boxes:\n' "$boxes"
      grep -E '^(Overfull|Underfull)' "$LOG" | head -10 | sed 's/^/  /'
      problems=$((problems + 1))
    fi
  else
    printf 'note: %s not found, run make first to check for bad boxes\n' "$LOG"
  fi
fi

if [ "$problems" -eq 0 ]; then
  printf '%s: all checks passed\n' "$mode"
  exit 0
fi
printf '\n%s: %s check(s) reported problems\n' "$mode" "$problems"
exit 1
