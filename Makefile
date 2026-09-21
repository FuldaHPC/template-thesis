MAIN := Thesis
SRC  := src
OUT  := out
TMP  := tmp

DRAFT := $(MAIN)-draft

TEX_SOURCE := $(SRC)/$(MAIN).tex
GNUPLOT_SOURCES := $(shell find $(SRC)/figures -type f -name '*.gp')
GNUPLOT_OUTPUTS := $(GNUPLOT_SOURCES:.gp=.tex)
GNUPLOT_DATA    := $(shell find $(SRC)/figures -type f -name '*.dat')

LATEXMK := latexmk
GNUPLOT := gnuplot
EPSTOPDF := epstopdf

LINT := tools/lint.sh

# Only the PDF and its SyncTeX file land in out/; every auxiliary file goes to tmp/,
# which is not under version control.
LATEXMK_DIRS := -cd \
	-outdir="$(abspath $(OUT))" \
	-auxdir="$(abspath $(TMP))"
# -synctex=1 records which source line produced which spot on the page, which is
# what lets an editor jump between the two. Without it forward and inverse search
# silently do nothing, in every editor.
LATEXMK_FLAGS := -pdf \
	-synctex=1 \
	-interaction=nonstopmode \
	-halt-on-error \
	-file-line-error \
	$(LATEXMK_DIRS)
# -pvc keeps running, so it must not stop at the first error.
LATEXMK_WATCH_FLAGS := -pdf \
	-synctex=1 \
	-interaction=nonstopmode \
	-file-line-error \
	$(LATEXMK_DIRS)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	OPEN_CMD := open
else
	OPEN_CMD := xdg-open
endif

.DEFAULT_GOAL := all

all: figures | $(OUT) $(TMP)
	$(LATEXMK) $(LATEXMK_FLAGS) "$(abspath $(TEX_SOURCE))"

help:
	@echo "  make               Build $(OUT)/$(MAIN).pdf"
	@echo "  make view          Build and open the PDF"
	@echo "  make draft         Build $(OUT)/$(DRAFT).pdf with line numbers and TODOs"
	@echo "  make view-draft    Build and open the draft PDF"
	@echo "  make watch         Rebuild automatically on every save"
	@echo "  make figures       Regenerate gnuplot figures"
	@echo "  make lint          Check sources for common mistakes"
	@echo "  make submit-check  Run lint plus the pre-submission checks"
	@echo "  make clean         Delete $(TMP)/ and all of $(OUT)/ except $(MAIN).pdf"
	@echo "  make help          Show this list"

lint:
	@$(LINT)

submit-check:
	@$(LINT) --submit

figures: $(GNUPLOT_OUTPUTS)

$(GNUPLOT_OUTPUTS): $(GNUPLOT_DATA)

%.tex: %.gp
	cd "$(SRC)" && $(GNUPLOT) "$(patsubst $(SRC)/%,%,$<)"
	$(EPSTOPDF) --outfile="$*.pdf" "$*.eps"

$(OUT) $(TMP):
	mkdir -p "$@"

# A review copy: line numbers, visible \todo notes, and a DRAFT watermark.
# The override is passed on the command line, so thesis-config.tex stays untouched
# and the draft lands beside the normal PDF rather than replacing it.
draft: figures | $(OUT) $(TMP)
	$(LATEXMK) $(LATEXMK_FLAGS) \
		-jobname="$(DRAFT)" \
		-usepretex='\def\ThesisDraftOverride{}' \
		"$(abspath $(TEX_SOURCE))"

watch: figures | $(OUT) $(TMP)
	$(LATEXMK) $(LATEXMK_WATCH_FLAGS) -pvc "$(abspath $(TEX_SOURCE))"

view: all
	$(OPEN_CMD) "$(OUT)/$(MAIN).pdf" >/dev/null 2>&1 &

view-draft: draft
	$(OPEN_CMD) "$(OUT)/$(DRAFT).pdf" >/dev/null 2>&1 &

# $(OUT)/$(MAIN).pdf is under version control and therefore survives; the next
# build starts from scratch anyway, because latexmk's database lived in $(TMP)/.
clean:
	rm -rf "$(TMP)"
	find "$(OUT)" -mindepth 1 ! -name '.gitkeep' ! -name '$(MAIN).pdf' -delete

.PHONY: all help lint submit-check figures draft watch view view-draft clean
