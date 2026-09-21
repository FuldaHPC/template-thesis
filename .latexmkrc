# Editor-agnostic latexmk configuration.
#
# Any editor that builds src/Thesis.tex by calling latexmk now behaves like
# "make": it compiles with pdflatex, runs biber, writes the PDF to out/ and every
# auxiliary file to tmp/ instead of scattering .aux and .log files through the
# source tree.
#
# $do_cd makes latexmk change into src/ first, exactly as the Makefile does, so
# every \input path resolves the same way and the relative directories below are
# read as <repository root>/out and <repository root>/tmp.

$pdf_mode  = 1;
$do_cd     = 1;
$out_dir   = '../out';
$aux_dir   = '../tmp';
$bibtex_use = 2;

# -synctex=1 is what makes an editor able to jump between source and PDF.
$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
