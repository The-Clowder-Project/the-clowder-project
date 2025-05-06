# Known suffixes.
.SUFFIXES: .aux .bbl .bib .blg .dvi .htm .html .css .log .out .pdf .ps .tex \
	.toc .foo .bar

# Master list of stems of tex files in the project.
# This should be in order.
LIJST = sets \
		constructions-with-sets \
		monoidal-structures-on-the-category-of-sets \
		pointed-sets \
		tensor-products-of-pointed-sets \
		relations \
		constructions-with-relations \
		equivalence-relations-and-apartness-relations \
		categories \
		constructions-with-monoidal-categories \
		types-of-morphisms-in-bicategories

# Add book to get all stems of tex files needed for tags
LIJST_TAGS = $(LIJST_FDL) book

# Different extensions
SOURCES = $(patsubst %,%.tex,$(LIJST))
TAGS = $(patsubst %,tags/tmp/%.tex,$(LIJST_TAGS))
TAG_EXTRAS = tags/tmp/bibliography.bib tags/tmp/hyperref.cfg \
	tags/tmp/stacks-project.cls tags/tmp/stacks-project-book.cls \
	tags/tmp/Makefile tags/tmp/chapters.tex \
	tags/tmp/preamble.tex tags/tmp/bibliography.tex
FOO_SOURCES = $(patsubst %,%.foo,$(LIJST))
FOOS = $(patsubst %,%.foo,$(LIJST_FDL))
BARS = $(patsubst %,%.bar,$(LIJST_FDL))
PDFS = $(patsubst %,%.pdf,$(LIJST_FDL))
DVIS = $(patsubst %,%.dvi,$(LIJST_FDL))

# Be careful. Files in INSTALLDIR will be overwritten!
INSTALLDIR=

# Default latex commands
LATEX := lualatex -src
#LATEX := ./scripts/latex.sh "$(CURDIR)" "latex -src"

PDFLATEX := lualatex
#PDFLATEX := ./scripts/latex.sh "$(CURDIR)" pdflatex

FOO_LATEX := $(LATEX)
#FOO_LATEX := $(PDFLATEX)

# Currently the default target runs latex once for each updated tex file.
# This is what you want if you are just editing a single tex file and want
# to look at the resulting dvi file. It does latex the license of the index.
# We use the aux file to keep track of whether the tex file has been updated.
.PHONY: default
default: $(FOO_SOURCES)
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "% This target latexs each updated tex file just once. %"
	@echo "% See the file documentation/make-project for others. %"
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

# Target which creates all dvi files of chapters
.PHONY: dvis
dvis: $(FOOS) $(BARS) $(DVIS)

# We need the following to cancel the built-in rule for
# dvi files (which uses tex not latex).
%.dvi : %.tex

# Automatically generated tex files
tmp/index.tex: *.tex
	python ./scripts/make_index.py "$(CURDIR)" > tmp/index.tex

tmp/book.tex: *.tex tmp/index.tex
	python ./scripts/make_book.py "$(CURDIR)" > tmp/book.tex

# Creating aux files
index.foo: tmp/index.tex
	$(FOO_LATEX) tmp/index
	touch index.foo

book.foo: tmp/book.tex
	$(FOO_LATEX) tmp/book
	touch book.foo

%.foo: %.tex
	$(FOO_LATEX) $*
	touch $*.foo

# Creating bbl files
index.bar: tmp/index.tex index.foo
	@echo "Do not need to bibtex index.tex"
	touch index.bar

#fdl.bar: fdl.tex fdl.foo
#	@echo "Do not need to bibtex fdl.tex"
#	touch fdl.bar

book.bar: tmp/book.tex book.foo
	bibtex book
	touch book.bar

%.bar: %.tex %.foo
	bibtex $*
	touch $*.bar

# Creating pdf files
index.pdf: tmp/index.tex index.bar $(FOOS)
	$(PDFLATEX) tmp/index
	$(PDFLATEX) tmp/index

book.pdf: tmp/book.tex book.bar
	$(PDFLATEX) tmp/book
	$(PDFLATEX) tmp/book

%.pdf: %.tex %.bar $(FOOS)
	$(PDFLATEX) $*
	$(PDFLATEX) $*

# Creating dvi files
index.dvi: tmp/index.tex index.bar $(FOOS)
	$(LATEX) tmp/index
	$(LATEX) tmp/index

book.dvi: tmp/book.tex book.bar
	$(LATEX) tmp/book
	$(LATEX) tmp/book

%.dvi : %.tex %.bar $(FOOS)
	$(LATEX) $*
	$(LATEX) $*

#
#
# Tags stuff
#
#
tags/tmp/book.tex: tmp/book.tex tags/tags
	python ./scripts/tag_up.py "$(CURDIR)" book > tags/tmp/book.tex

tags/tmp/index.tex: tmp/index.tex
	cp tmp/index.tex tags/tmp/index.tex

tags/tmp/preamble.tex: preamble.tex tags/tags
	python ./scripts/tag_up.py "$(CURDIR)" preamble > tags/tmp/preamble.tex

tags/tmp/chapters.tex: chapters.tex
	cp chapters.tex tags/tmp/chapters.tex

tags/tmp/%.tex: %.tex tags/tags
	python ./scripts/tag_up.py "$(CURDIR)" $* > tags/tmp/$*.tex

tags/tmp/stacks-project.cls: stacks-project.cls
	cp stacks-project.cls tags/tmp/stacks-project.cls

tags/tmp/stacks-project-book.cls: stacks-project-book.cls
	cp stacks-project-book.cls tags/tmp/stacks-project-book.cls

tags/tmp/hyperref.cfg: hyperref.cfg
	cp hyperref.cfg tags/tmp/hyperref.cfg

tags/tmp/bibliography.bib: bibliography.bib
	cp bibliography.bib tags/tmp/bibliography.bib

tags/tmp/Makefile: tags/Makefile
	cp tags/Makefile tags/tmp/Makefile

# Target dealing with tags
.PHONY: tags
tags: $(TAGS) $(TAG_EXTRAS)
	@echo "TAGS TARGET"
	$(MAKE) -C tags/tmp

.PHONY: tags_install
tags_install: tags tarball
ifndef INSTALLDIR
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "% Set INSTALLDIR value in the Makefile!               %"
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
else
	cp tags/tmp/*.pdf $(INSTALLDIR)
	tar -c -f $(INSTALLDIR)/stacks-pdfs.tar --exclude book.pdf --transform=s@tags/tmp@stacks-pdfs@ tags/tmp/*.pdf
	git archive --format=tar HEAD | (cd $(INSTALLDIR) && tar xf -)
	cp stacks-project.tar.bz2 $(INSTALLDIR)
	git log --pretty=oneline -1 > $(INSTALLDIR)/VERSION
endif

.PHONY: tags_clean
tags_clean:
	rm -f tags/tmp/*
	rm -f tmp/book.tex tmp/index.tex
	rm -f stacks-project.tar.bz2

# Additional targets
.PHONY: book
book: book.foo book.bar book.dvi book.pdf

.PHONY: clean
clean:
	rm -f *.aux *.bbl *.blg *.dvi *.log *.pdf *.ps *.out *.toc *.foo *.bar
	rm -f tmp/book.tex tmp/index.tex
	rm -f stacks-project.tar.bz2

.PHONY: distclean
distclean: clean tags_clean

.PHONY: backup
backup:
	git archive --prefix=stacks-project/ HEAD | bzip2 > \
		../stacks-project_backup.tar.bz2

.PHONY: tarball
tarball:
	git archive --prefix=stacks-project/ HEAD | bzip2 > stacks-project.tar.bz2

# Target which makes all dvis and all pdfs, as well as the tarball
.PHONY: all
all: dvis pdfs book tarball

.PHONY: install
install:
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "% To install the project, use the tags_install target %"
	@echo "% Be sure to change INSTALLDIR value in the Makefile! %"
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

WEBDIR=../WEB
.PHONY: web
web: tmp/index.tex
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "% Stuff in WEBDIR will be overwritten!!!!!!!!!        %"
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	cp bibliography.bib $(WEBDIR)/bibliography.bib
	cp tags/tags $(WEBDIR)/tags
	python ./scripts/web_book.py "$(CURDIR)" > $(WEBDIR)/book.tex

# Define the name for the conda environment (NO trailing spaces!)
CONDA_ENV_NAME = clowder_py36_env
PYTHON_VERSION = 3.6
#
PLASTEX_REPO = https://github.com/The-Clowder-Project/plastex.git
GERBY_WEBSITE_REPO = https://github.com/The-Clowder-Project/gerby-website.git
PYBTEX_REPO = https://github.com/live-clones/pybtex.git
PYBTEX_PATCH_URL = https://bitbucket.org/pybtex-devs/pybtex/issues/attachments/110/pybtex-devs/pybtex/1514284299.07/110/no-protected-in-math-mode.patch

# Target to create conda environment
.PHONY: conda-create
conda-create:
	@echo "--- Starting init target ---"
	@echo "Checking for conda environment '$(CONDA_ENV_NAME)'..."
	@echo "Running check command: conda env list | grep -E '^$(CONDA_ENV_NAME)\s+'"
	@conda env list | grep -E '^$(CONDA_ENV_NAME)\s+' > /dev/null; \
	check_result=$$?; \
	echo "Check command exit status: $$check_result (0 = found, non-zero = not found)"; \
	\
	if [ $$check_result -eq 0 ]; then \
		echo "-- Conda environment '$(CONDA_ENV_NAME)' already exists."; \
		echo "-- To activate it, run: conda activate $(CONDA_ENV_NAME)"; \
	else \
		echo "-- Environment not found. Proceeding with creation..."; \
		echo "-- Creating conda environment '$(CONDA_ENV_NAME)' with Python $(PYTHON_VERSION)..."; \
		conda create -y --name $(CONDA_ENV_NAME) python=$(PYTHON_VERSION); \
		create_result=$$?; \
		echo "Conda create exit status: $$create_result"; \
		if [ $$create_result -eq 0 ]; then \
			 echo "-- Conda environment created successfully."; \
			 echo "-- To activate it, run: conda activate $(CONDA_ENV_NAME)"; \
		else \
			 echo "-- Failed to create conda environment '$(CONDA_ENV_NAME)'. Please check conda output above."; \
			 exit 1; \
		fi; \
	fi
	@echo "--- Init target finished ---"

.PHONY: clean-env
clean-env:
	@echo "Attempting to remove conda environment '$(CONDA_ENV_NAME)'..."
	@conda env remove -y --name $(CONDA_ENV_NAME) || echo "-- Environment '$(CONDA_ENV_NAME)' not found or removal failed."
	@echo "Environment removal attempt finished."

# Target to install dependencies
.PHONY: init
init:
	@echo "--- Checking if conda environment '$(CONDA_ENV_NAME)' is active ---"
	@# Check if the CONDA_PREFIX environment variable is set and if its
	@# basename (the last part of the path) matches the desired environment name.
	@# This is the most common way Conda indicates the active environment.
	@# We use $$CONDA_PREFIX because make interprets single $.
	@# We use $${CONDA_PREFIX##*/} which is shell parameter expansion for basename.
	@if [ -z "$$CONDA_PREFIX" ] || [ "$${CONDA_PREFIX##*/}" != "$(CONDA_ENV_NAME)" ]; then \
		echo >&2 ""; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 "!! ERROR: Conda environment '$(CONDA_ENV_NAME)' does not appear to be active."; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		echo "-- Conda environment '$(CONDA_ENV_NAME)' is active ($$CONDA_PREFIX)."; \
		echo "-- Installing/updating requirements from requirements.txt..."; \
		if [ -f "requirements.txt" ]; then \
			python$(PYTHON_VERSION) -m pip install -r requirements.txt; \
		else \
			echo "-- Warning: requirements.txt not found, skipping pip install."; \
		fi; \
		\
		echo "-- Installing (Clowder's version of) plastex..."; \
		git clone $(PLASTEX_REPO); \
		cd plastex; \
		git checkout gerby; \
		python$(PYTHON_VERSION) -m pip install --user .; \
		cd ../; \
		echo "-- Installing pybtex..."; \
		git clone $(PYBTEX_REPO); \
		cd pybtex; \
		wget $(PYBTEX_PATCH_URL); \
		git apply ./no-protected-in-math-mode.patch; \
		python$(PYTHON_VERSION) -m pip install --user .; \
		cd ../; \
		echo "-- Cloning Gerby website..."; \
		git clone $(GERBY_WEBSITE_REPO); \
		echo "-- Downloading fonts..."; \
		mkdir -p fonts/japanese; \
		curl "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Variable/OTF/Subset/NotoSansJP-VF.otf" -o fonts/japanese/NotoSansJP-Regular.otf; \
		echo "-- Run target finished successfully."; \
	fi

# Target which creates all pdf files of chapters
.PHONY: cm
cm:
	@echo "--- Checking if conda environment '$(CONDA_ENV_NAME)' is active ---"
	@# Check if the CONDA_PREFIX environment variable is set and if its
	@# basename (the last part of the path) matches the desired environment name.
	@# This is the most common way Conda indicates the active environment.
	@# We use $$CONDA_PREFIX because make interprets single $.
	@# We use $${CONDA_PREFIX##*/} which is shell parameter expansion for basename.
	@if [ -z "$$CONDA_PREFIX" ] || [ "$${CONDA_PREFIX##*/}" != "$(CONDA_ENV_NAME)" ]; then \
		echo >&2 ""; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 "!! ERROR: Conda environment '$(CONDA_ENV_NAME)' does not appear to be active."; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		mkdir tmp/cm; \
		echo "Generating the .TEX..."; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py cm > tmp/cm/book.tex; \
		cd tmp/cm/; \
		echo "Processing the .TEX..."; \
		python$(PYTHON_VERSION) ../../scripts/process_raw_html_latex.py book.tex; \
		lualatex book.tex; \
	fi

# Target which creates all pdf files of chapters
.PHONY: pdfs
pdfs: $(FOOS) $(BARS) $(PDFS)

# Target which compiles website with Gerby and serves it on 127.0.0.1:5000
.PHONY: web-and-serve
web-and-serve:
	@echo "--- Checking if conda environment '$(CONDA_ENV_NAME)' is active ---"
	@# Check if the CONDA_PREFIX environment variable is set and if its
	@# basename (the last part of the path) matches the desired environment name.
	@# This is the most common way Conda indicates the active environment.
	@# We use $$CONDA_PREFIX because make interprets single $.
	@# We use $${CONDA_PREFIX##*/} which is shell parameter expansion for basename.
	@if [ -z "$$CONDA_PREFIX" ] || [ "$${CONDA_PREFIX##*/}" != "$(CONDA_ENV_NAME)" ]; then \
		echo >&2 ""; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 "!! ERROR: Conda environment '$(CONDA_ENV_NAME)' does not appear to be active."; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		echo "-- Conda environment '$(CONDA_ENV_NAME)' is active ($$CONDA_PREFIX)."; \
		echo "-- Compiling preambles..."; \
		python scripts/make_preamble.py; \
		python scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		echo "-- Run target finished successfully."; \
	fi
