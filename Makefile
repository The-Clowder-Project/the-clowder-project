# Known suffixes.
.SUFFIXES: .aux .bbl .bib .blg .dvi .htm .html .css .log .out .pdf .ps .tex \
	.toc .foo .bar

# Master list of stems of tex files in the project.
# This should be in order.
LIJST = introduction \
        sets \
		constructions-with-sets \
		monoidal-structures-on-the-category-of-sets \
		pointed-sets \
		tensor-products-of-pointed-sets \
		relations \
		constructions-with-relations \
		conditions-on-relations \
		categories \
		constructions-with-monoidal-categories \
		types-of-morphisms-in-bicategories \
		notes

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

.PHONY: distclean
distclean: clean tags_clean

.PHONY: backup
backup:
	git archive --prefix=stacks-project/ HEAD | bzip2 > \
		../stacks-project_backup.tar.bz2

.PHONY: tarball
tarball:
	git archive --prefix=stacks-project/ HEAD | bzip2 > stacks-project.tar.bz2

.PHONY: install
install:
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "% To install the project, use the tags_install target %"
	@echo "% Be sure to change INSTALLDIR value in the Makefile! %"
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

WEBDIR=./WEB
.PHONY: web
web: tmp/index.tex
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "% Stuff in WEBDIR will be overwritten!!!!!!!!!        %"
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	cp bibliography.bib $(WEBDIR)/bibliography.bib
	cp tags/tags $(WEBDIR)/tags
	python$(PYTHON_VERSION) ./scripts/make_book.py web > $(WEBDIR)/book.tex

# Define the name for the conda environment (NO trailing spaces!)
CONDA_ENV_NAME = clowder_py36_env
PYTHON_VERSION = 3.6
#
PLASTEX_REPO = https://github.com/The-Clowder-Project/plastex.git
GERBY_WEBSITE_REPO = https://github.com/The-Clowder-Project/gerby-website.git
PYBTEX_REPO = https://github.com/live-clones/pybtex.git
PYBTEX_PATCH_URL = https://bitbucket.org/pybtex-devs/pybtex/issues/attachments/110/pybtex-devs/pybtex/1514284299.07/110/no-protected-in-math-mode.patch
# Define LuaLaTeX arguments
LUALATEX = lualatex -halt-on-error
LUALATEX_ARGS = max_strings=80000000 hash_extra=10000000 pool_size=4250000 main_memory=12000000

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
		python$(PYTHON_VERSION) -m pip install -r requirements.txt; \
		python$(PYTHON_VERSION) -m pip install --user .; \
		cd ../; \
		echo "-- Installing pybtex..."; \
		git clone $(PYBTEX_REPO); \
		cd pybtex; \
		wget $(PYBTEX_PATCH_URL); \
		git apply ./no-protected-in-math-mode.patch; \
		python$(PYTHON_VERSION) -m pip install --user .; \
		cd ../; \
		echo "-- Cloning Gerby website and installing Gerby..."; \
		git clone $(GERBY_WEBSITE_REPO); \
		cd gerby-website; \
		python$(PYTHON_VERSION) -m pip install --user .; \
		cd ../; \
		echo "-- Downloading fonts..."; \
		mkdir -p fonts; \
		curl "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Variable/OTF/Subset/NotoSansJP-VF.otf" -o fonts/NotoSansJP-VF.otf; \
		curl "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Variable/OTF/Subset/NotoSansSC-VF.otf" -o fonts/NotoSansSC-VF.otf; \
		curl "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Variable/OTF/Subset/NotoSansTC-VF.otf" -o fonts/NotoSansTC-VF.otf; \
		cd fonts; \
		git clone https://github.com/The-EPL-Type-Foundry/Hundar; \
		cp -r Hundar/fonts/otf/Hundar.otf ./; \
		rm -rf Hundar; \
		mkdir -p Hundar; \
		mv Hundar.otf Hundar/Hundar-Regular.otf; \
		mkdir -p brill; \
		git clone https://github.com/itamarkast/UoEmorphology; \
		cp UoEmorphology/Brill-Roman.ttf brill/; \
		rm -rf UoEmorphology; \
		git clone https://github.com/huertatipografica/Alegreya-Sans; \
		mkdir -p alegreya-sans; \
		mv Alegreya-Sans/fonts/otf/*.otf alegreya-sans/; \
		rm -rf Alegreya-Sans; \
		git clone https://github.com/CatharsisFonts/Ysabeau; \
		mkdir -p ysabeau; \
		mv Ysabeau/fonts/googlefonts/variable/Ysabeau[wght].ttf ysabeau/Ysabeau.ttf; \
		rm -rf Ysabeau; \
		cd ../; \
		echo "-- Compiling preambles."; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		echo "-- Creatings directories."; \
		mkdir -p gerby-website/gerby/static/gifs/dark-mode; \
		mkdir -p preamble/compiled; \
		mkdir -p tmp/alegreya-sans-tcb; \
		mkdir -p tmp/alegreya-tcb; \
		mkdir -p tmp/cm-tcb; \
		mkdir -p tmp/crimson-pro-tcb; \
		mkdir -p tmp/eb-garamond-tcb; \
		mkdir -p tmp/xcharter-tcb; \
		mkdir -p tmp/alegreya-sans; \
		mkdir -p tmp/alegreya; \
		mkdir -p tmp/cm; \
		mkdir -p tmp/crimson-pro; \
		mkdir -p tmp/eb-garamond; \
		mkdir -p tmp/xcharter; \
		mkdir -p tmp/webcompile; \
		mkdir -p tmp/tags/alegreya-sans-tcb; \
		mkdir -p tmp/tags/alegreya-tcb; \
		mkdir -p tmp/tags/cm-tcb; \
		mkdir -p tmp/tags/crimson-pro-tcb; \
		mkdir -p tmp/tags/eb-garamond-tcb; \
		mkdir -p tmp/tags/xcharter-tcb; \
		mkdir -p tmp/tags/alegreya-sans; \
		mkdir -p tmp/tags/alegreya; \
		mkdir -p tmp/tags/cm; \
		mkdir -p tmp/tags/crimson-pro; \
		mkdir -p tmp/tags/eb-garamond; \
		mkdir -p tmp/tags/xcharter; \
		mkdir -p output/book; \
		mkdir -p output/tags-book; \
		mkdir -p output/chapters/alegreya-sans-tcb; \
		mkdir -p output/chapters/alegreya-tcb; \
		mkdir -p output/chapters/cm-tcb; \
		mkdir -p output/chapters/crimson-pro-tcb; \
		mkdir -p output/chapters/eb-garamond-tcb; \
		mkdir -p output/chapters/xcharter-tcb; \
		mkdir -p output/chapters/alegreya-sans; \
		mkdir -p output/chapters/alegreya; \
		mkdir -p output/chapters/cm; \
		mkdir -p output/chapters/crimson-pro; \
		mkdir -p output/chapters/eb-garamond; \
		mkdir -p output/chapters/xcharter; \
		mkdir -p output/tags-chapters/alegreya-sans-tcb; \
		mkdir -p output/tags-chapters/alegreya-tcb; \
		mkdir -p output/tags-chapters/cm-tcb; \
		mkdir -p output/tags-chapters/crimson-pro-tcb; \
		mkdir -p output/tags-chapters/eb-garamond-tcb; \
		mkdir -p output/tags-chapters/xcharter-tcb; \
		mkdir -p output/tags-chapters/alegreya-sans; \
		mkdir -p output/tags-chapters/alegreya; \
		mkdir -p output/tags-chapters/cm; \
		mkdir -p output/tags-chapters/crimson-pro; \
		mkdir -p output/tags-chapters/eb-garamond; \
		mkdir -p output/tags-chapters/xcharter; \
		echo "-- Run target finished successfully."; \
	fi

.PHONY: titlepage
titlepage:
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
		cd titlepage; \
		python$(PYTHON_VERSION) make_version.py ../ > text/version.tex; \
		cd text; \
		$(LUALATEX) title.tex; \
		$(LUALATEX) year.tex; \
		$(LUALATEX) author.tex; \
		$(LUALATEX) version.tex; \
		cd ../; \
		$(LUALATEX) titlepage.tex; \
	fi

###############################
## ▗▄▄▖  ▗▄▖  ▗▄▖ ▗▖ ▗▖ ▗▄▄▖ ##
## ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌▗▞▘▐▌    ##
## ▐▛▀▚▖▐▌ ▐▌▐▌ ▐▌▐▛▚▖  ▝▀▚▖ ##
## ▐▙▄▞▘▝▚▄▞▘▝▚▄▞▘▐▌ ▐▌▗▄▄▞▘ ##
###############################

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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/cm; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py cm > tmp/cm/book.tex; \
		cd tmp/cm/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/cm.pdf; \
	fi

.PHONY: alegreya
alegreya:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/alegreya; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py alegreya > tmp/alegreya/book.tex; \
		cd tmp/alegreya/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/alegreya.pdf; \
	fi

.PHONY: alegreya-sans
alegreya-sans:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/alegreya-sans; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py alegreya-sans > tmp/alegreya-sans/book.tex; \
		cd tmp/alegreya-sans/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/alegreya-sans.pdf; \
	fi

.PHONY: crimson-pro
crimson-pro:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/crimson-pro; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py crimson-pro > tmp/crimson-pro/book.tex; \
		cd tmp/crimson-pro/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/crimson-pro.pdf; \
	fi

.PHONY: eb-garamond
eb-garamond:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/eb-garamond; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py eb-garamond > tmp/eb-garamond/book.tex; \
		cd tmp/eb-garamond/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/eb-garamond.pdf; \
	fi

.PHONY: xcharter
xcharter:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/xcharter; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py xcharter > tmp/xcharter/book.tex; \
		cd tmp/xcharter/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/xcharter.pdf; \
	fi

.PHONY: alegreya-tcb
alegreya-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/alegreya-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py alegreya-tcb > tmp/alegreya-tcb/book.tex; \
		cd tmp/alegreya-tcb/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/alegreya-tcb.pdf; \
	fi

.PHONY: alegreya-sans-tcb
alegreya-sans-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/alegreya-sans-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py alegreya-sans-tcb > tmp/alegreya-sans-tcb/book.tex; \
		cd tmp/alegreya-sans-tcb/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/alegreya-sans-tcb.pdf; \
	fi

.PHONY: eb-garamond-tcb
eb-garamond-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/eb-garamond-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py eb-garamond-tcb > tmp/eb-garamond-tcb/book.tex; \
		cd tmp/eb-garamond-tcb/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/eb-garamond-tcb.pdf; \
	fi

.PHONY: crimson-pro-tcb
crimson-pro-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/crimson-pro-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py crimson-pro-tcb > tmp/crimson-pro-tcb/book.tex; \
		cd tmp/crimson-pro-tcb/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/crimson-pro-tcb.pdf; \
	fi

.PHONY: xcharter-tcb
xcharter-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/xcharter-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py xcharter-tcb > tmp/xcharter-tcb/book.tex; \
		cd tmp/xcharter-tcb/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/xcharter-tcb.pdf; \
	fi

.PHONY: cm-tcb
cm-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/cm-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py cm-tcb > tmp/cm-tcb/book.tex; \
		cd tmp/cm-tcb/; \
		cp ../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../scripts/process_parentheses.py book.tex; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/3...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../output/book/cm-tcb.pdf; \
	fi

########################################################
## ▗▄▄▄▖ ▗▄▖  ▗▄▄▖ ▗▄▄▖     ▗▄▄▖  ▗▄▖  ▗▄▖ ▗▖ ▗▖ ▗▄▄▖ ##
##   █  ▐▌ ▐▌▐▌   ▐▌        ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌▗▞▘▐▌    ##
##   █  ▐▛▀▜▌▐▌▝▜▌ ▝▀▚▖     ▐▛▀▚▖▐▌ ▐▌▐▌ ▐▌▐▛▚▖  ▝▀▚▖ ##
##   █  ▐▌ ▐▌▝▚▄▞▘▗▄▄▞▘     ▐▙▄▞▘▝▚▄▞▘▝▚▄▞▘▐▌ ▐▌▗▄▄▞▘ ##
########################################################

.PHONY: tags-cm
tags-cm:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/cm; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-cm > tmp/tags/cm/book.tex; \
		cd tmp/tags/cm/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/cm/ book; \
		cd tmp/tags/cm/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/cm.pdf; \
	fi

.PHONY: tags-alegreya
tags-alegreya:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/alegreya; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-alegreya > tmp/tags/alegreya/book.tex; \
		cd tmp/tags/alegreya/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya/ book; \
		cd tmp/tags/alegreya/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/alegreya.pdf; \
	fi

.PHONY: tags-alegreya-sans
tags-alegreya-sans:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/alegreya-sans; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-alegreya-sans > tmp/tags/alegreya-sans/book.tex; \
		cd tmp/tags/alegreya-sans/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya-sans/ book; \
		cd tmp/tags/alegreya-sans/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/alegreya-sans.pdf; \
	fi

.PHONY: tags-crimson-pro
tags-crimson-pro:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/crimson-pro; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-crimson-pro > tmp/tags/crimson-pro/book.tex; \
		cd tmp/tags/crimson-pro/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/crimson-pro/ book; \
		cd tmp/tags/crimson-pro/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/crimson-pro.pdf; \
	fi

.PHONY: tags-eb-garamond
tags-eb-garamond:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/eb-garamond; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-eb-garamond > tmp/tags/eb-garamond/book.tex; \
		cd tmp/tags/eb-garamond/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/eb-garamond/ book; \
		cd tmp/tags/eb-garamond/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/eb-garamond.pdf; \
	fi

.PHONY: tags-xcharter
tags-xcharter:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/xcharter; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-xcharter > tmp/tags/xcharter/book.tex; \
		cd tmp/tags/xcharter/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/xcharter/ book; \
		cd tmp/tags/xcharter/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/xcharter.pdf; \
	fi

.PHONY: tags-alegreya-tcb
tags-alegreya-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/alegreya-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-alegreya-tcb > tmp/tags/alegreya-tcb/book.tex; \
		cd tmp/tags/alegreya-tcb/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya-tcb/ book; \
		cd tmp/tags/alegreya-tcb/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/alegreya-tcb.pdf; \
	fi

.PHONY: tags-alegreya-sans-tcb
tags-alegreya-sans-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/alegreya-sans-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-alegreya-sans-tcb > tmp/tags/alegreya-sans-tcb/book.tex; \
		cd tmp/tags/alegreya-sans-tcb/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya-sans-tcb/ book; \
		cd tmp/tags/alegreya-sans-tcb/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/alegreya-sans-tcb.pdf; \
	fi

.PHONY: tags-cm-tcb
tags-cm-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/cm-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-cm-tcb > tmp/tags/cm-tcb/book.tex; \
		cd tmp/tags/cm-tcb/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/cm-tcb/ book; \
		cd tmp/tags/cm-tcb/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/cm-tcb.pdf; \
	fi

.PHONY: tags-crimson-pro-tcb
tags-crimson-pro-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/crimson-pro-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-crimson-pro-tcb > tmp/tags/crimson-pro-tcb/book.tex; \
		cd tmp/tags/crimson-pro-tcb/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/crimson-pro-tcb/ book; \
		cd tmp/tags/crimson-pro-tcb/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/crimson-pro-tcb.pdf; \
	fi

.PHONY: tags-eb-garamond-tcb
tags-eb-garamond-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/eb-garamond-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-eb-garamond-tcb > tmp/tags/eb-garamond-tcb/book.tex; \
		cd tmp/tags/eb-garamond-tcb/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/eb-garamond-tcb/ book; \
		cd tmp/tags/eb-garamond-tcb/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/eb-garamond-tcb.pdf; \
	fi

.PHONY: tags-xcharter-tcb
tags-xcharter-tcb:
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
		make titlepage; \
		mkdir -p output; \
		mkdir -p tmp/tags/xcharter-tcb; \
		printf "$(GREEN)Generating the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		python$(PYTHON_VERSION) scripts/make_book.py tags-xcharter-tcb > tmp/tags/xcharter-tcb/book.tex; \
		cd tmp/tags/xcharter-tcb/; \
		cp ../../../index_style.ist ./; \
		printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
		python$(PYTHON_VERSION) ../../../scripts/process_parentheses.py book.tex; \
		cd ../../../; \
		python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/xcharter-tcb/ book; \
		cd tmp/tags/xcharter-tcb/; \
		printf "$(GREEN)Compiling with LuaLaTeX 1/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling indices...$(NC)\n"; \
		splitindex book; \
		makeindex -s index_style.ist book-notation.idx; \
		makeindex -s index_style.ist book-set-theory.idx; \
		makeindex -s index_style.ist book-categories.idx; \
		makeindex -s index_style.ist book-higher-categories.idx; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 2/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Running Biber...$(NC)\n"; \
		biber book; \
		printf "$(GREEN)Compiling with LuaLaTeX 3/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Compiling with LuaLaTeX 4/4...$(NC)\n"; \
		$(LUALATEX_ARGS) $(LUALATEX) book; \
		printf "$(GREEN)Saving PDF...$(NC)\n"; \
		mv book.pdf ../../../output/tags-book/xcharter-tcb.pdf; \
	fi


############################################
## ▗▄▄▖▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▄▖▗▄▄▄▖▗▄▄▖  ▗▄▄▖##
##▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌  █  ▐▌   ▐▌ ▐▌▐▌   ##
##▐▌   ▐▛▀▜▌▐▛▀▜▌▐▛▀▘   █  ▐▛▀▀▘▐▛▀▚▖ ▝▀▚▖##
##▝▚▄▄▖▐▌ ▐▌▐▌ ▐▌▐▌     █  ▐▙▄▄▖▐▌ ▐▌▗▄▄▞▘##
############################################

.PHONY: chapters-cm
chapters-cm:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py cm "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/cm/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/cm/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/cm/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/cm/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/cm/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-alegreya
chapters-alegreya:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py alegreya "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/alegreya/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/alegreya/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/alegreya/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/alegreya/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/alegreya/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-alegreya-sans
chapters-alegreya-sans:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py alegreya-sans "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/alegreya-sans/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/alegreya-sans/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/alegreya-sans/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/alegreya-sans/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/alegreya-sans/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-crimson-pro
chapters-crimson-pro:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py crimson-pro "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/crimson-pro/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/crimson-pro/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/crimson-pro/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/crimson-pro/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/crimson-pro/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-eb-garamond
chapters-eb-garamond:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py eb-garamond "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/eb-garamond/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/eb-garamond/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/eb-garamond/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/eb-garamond/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/eb-garamond/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-xcharter
chapters-xcharter:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py xcharter "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/xcharter/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/xcharter/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/xcharter/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/xcharter/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/xcharter/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-alegreya-tcb
chapters-alegreya-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py alegreya-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/alegreya-tcb/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/alegreya-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/alegreya-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/alegreya-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/alegreya-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-alegreya-sans-tcb
chapters-alegreya-sans-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py alegreya-sans-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/alegreya-sans-tcb/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/alegreya-sans-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/alegreya-sans-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/alegreya-sans-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/alegreya-sans-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-cm-tcb
chapters-cm-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py cm-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/cm-tcb/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/cm-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/cm-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/cm-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/cm-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-crimson-pro-tcb
chapters-crimson-pro-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py crimson-pro-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/crimson-pro-tcb/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/crimson-pro-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/crimson-pro-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/crimson-pro-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/crimson-pro-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-eb-garamond-tcb
chapters-eb-garamond-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py eb-garamond-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/eb-garamond-tcb/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/eb-garamond-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/eb-garamond-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/eb-garamond-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/eb-garamond-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: chapters-xcharter-tcb
chapters-xcharter-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling chapters (1/4): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py xcharter-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/xcharter-tcb/$${item_basename}.tex"; \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
			i=$$((i+1)); \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (2/4): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/xcharter-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (3/4): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/xcharter-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling chapters (4/4): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/xcharter-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../output/chapters/xcharter-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

#####################################################################
##▗▄▄▄▖ ▗▄▖  ▗▄▄▖ ▗▄▄▖      ▗▄▄▖▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▄▖▗▄▄▄▖▗▄▄▖  ▗▄▄▖##
##  █  ▐▌ ▐▌▐▌   ▐▌        ▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌  █  ▐▌   ▐▌ ▐▌▐▌   ##
##  █  ▐▛▀▜▌▐▌▝▜▌ ▝▀▚▖     ▐▌   ▐▛▀▜▌▐▛▀▜▌▐▛▀▘   █  ▐▛▀▀▘▐▛▀▚▖ ▝▀▚▖##
##  █  ▐▌ ▐▌▝▚▄▞▘▗▄▄▞▘     ▝▚▄▄▖▐▌ ▐▌▐▌ ▐▌▐▌     █  ▐▙▄▄▖▐▌ ▐▌▗▄▄▞▘##
#####################################################################

.PHONY: tags-chapters-cm
tags-chapters-cm:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-cm "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/cm/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/cm/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/cm/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/cm/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/cm/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/cm/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/cm/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-alegreya
tags-chapters-alegreya:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-alegreya "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/alegreya/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/alegreya/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/alegreya/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/alegreya/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/alegreya/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/alegreya/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-alegreya-sans
tags-chapters-alegreya-sans:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-alegreya-sans "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/alegreya-sans/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya-sans/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/alegreya-sans/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-crimson-pro
tags-chapters-crimson-pro:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-crimson-pro "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/crimson-pro/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/crimson-pro/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/crimson-pro/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-eb-garamond
tags-chapters-eb-garamond:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-eb-garamond "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/eb-garamond/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/eb-garamond/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/eb-garamond/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-xcharter
tags-chapters-xcharter:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-xcharter "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/xcharter/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/xcharter/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/xcharter/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/xcharter/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/xcharter/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/xcharter/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/xcharter/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-alegreya-tcb
tags-chapters-alegreya-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-alegreya-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/alegreya-tcb/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya-tcb/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/alegreya-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-alegreya-sans-tcb
tags-chapters-alegreya-sans-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-alegreya-sans-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/alegreya-sans-tcb/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/alegreya-sans-tcb/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/alegreya-sans-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/alegreya-sans-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-cm-tcb
tags-chapters-cm-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-cm-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/cm-tcb/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/cm-tcb/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/cm-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/cm-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/cm-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/cm-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/cm-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-crimson-pro-tcb
tags-chapters-crimson-pro-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-crimson-pro-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/crimson-pro-tcb/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/crimson-pro-tcb/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/crimson-pro-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/crimson-pro-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-eb-garamond-tcb
tags-chapters-eb-garamond-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-eb-garamond-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/eb-garamond-tcb/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/eb-garamond-tcb/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/eb-garamond-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/eb-garamond-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: tags-chapters-xcharter-tcb
tags-chapters-xcharter-tcb:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active. Proceeding with chapter processing...$(NC)\n"; \
		printf "$(GREEN)Processing chapters from LIJST...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		printf "$(GREEN)Compiling tags-chapters (1/5): Processing$(NC)\n"; \
		i=1; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Processing chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Processing the .TeX...$(NC)\n"; \
			python$(PYTHON_VERSION) scripts/process_chapter.py tags-xcharter-tcb "$${i}" "$${item_basename}"; \
			python$(PYTHON_VERSION) scripts/process_parentheses.py "$${item_basename}P.tex"; \
			mv "$${item_basename}P.tex" "tmp/tags/xcharter-tcb/$${item_basename}.tex"; \
			python$(PYTHON_VERSION) scripts/tag_up.py "$(CURDIR)" tmp/tags/xcharter-tcb/ $${item_basename}; \
			i=$$((i+1)); \
			printf "$(GREEN)Finished processing $$item_basename.$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (2/5): First LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling chapter: $$item_basename$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (1/4)...$(NC)\n"; \
			cd tmp/tags/xcharter-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (1/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (3/5): Second LaTeX run + biber$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (2/4)...$(NC)\n"; \
			cd tmp/tags/xcharter-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Running Biber...$(NC)\n"; \
			biber $${item_basename}; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (2/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (4/5): Third LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (3/4)...$(NC)\n"; \
			cd tmp/tags/xcharter-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (3/4).$(NC)\n"; \
		done; \
		printf "--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)Compiling tags-chapters (5/5): Last LaTeX run$(NC)\n"; \
		for item_basename in $(LIJST); do \
			printf "--------------------------------------------------$(NC)\n"; \
			printf "$(GREEN)Compiling with LuaLaTeX (4/4)...$(NC)\n"; \
			cd tmp/tags/xcharter-tcb/; \
			$(LUALATEX_ARGS) $(LUALATEX) $${item_basename}.tex; \
			printf "$(GREEN)Saving PDF...$(NC)\n"; \
			mv $$item_basename.pdf ../../../output/tags-chapters/xcharter-tcb/$$item_basename.pdf; \
			cd -; \
			printf "$(GREEN)Finished compiling $$item_basename (4/4).$(NC)\n"; \
		done; \
		printf "$(GREEN)--------------------------------------------------$(NC)\n"; \
		printf "$(GREEN)All chapters compiled.$(NC)"; \
	fi

.PHONY: all
all:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		make pictures; \
		make alegreya-sans; \
		make alegreya; \
		make cm; \
		make crimson-pro; \
		make eb-garamond; \
		make xcharter; \
		make alegreya-sans-tcb; \
		make alegreya-tcb; \
		make cm-tcb; \
		make crimson-pro-tcb; \
		make eb-garamond-tcb; \
		make xcharter-tcb; \
		make chapters-alegreya-sans; \
		make chapters-alegreya; \
		make chapters-cm; \
		make chapters-crimson-pro; \
		make chapters-eb-garamond; \
		make chapters-xcharter; \
		make chapters-alegreya-sans-tcb; \
		make chapters-alegreya-tcb; \
		make chapters-cm-tcb; \
		make chapters-crimson-pro-tcb; \
		make chapters-eb-garamond-tcb; \
		make chapters-xcharter-tcb; \
		make tags-alegreya-sans; \
		make tags-alegreya; \
		make tags-cm; \
		make tags-crimson-pro; \
		make tags-eb-garamond; \
		make tags-xcharter; \
		make tags-alegreya-sans-tcb; \
		make tags-alegreya-tcb; \
		make tags-cm-tcb; \
		make tags-crimson-pro-tcb; \
		make tags-eb-garamond-tcb; \
		make tags-xcharter-tcb; \
		make tags-chapters-alegreya-sans; \
		make tags-chapters-alegreya; \
		make tags-chapters-cm; \
		make tags-chapters-crimson-pro; \
		make tags-chapters-eb-garamond; \
		make tags-chapters-xcharter; \
		make tags-chapters-alegreya-sans-tcb; \
		make tags-chapters-alegreya-tcb; \
		make tags-chapters-cm-tcb; \
		make tags-chapters-crimson-pro-tcb; \
		make tags-chapters-eb-garamond-tcb; \
		make tags-chapters-xcharter-tcb; \
	fi

.PHONY: all-books
all-books:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		make pictures; \
		make alegreya-sans; \
		make alegreya; \
		make cm; \
		make crimson-pro; \
		make eb-garamond; \
		make xcharter; \
		make alegreya-sans-tcb; \
		make alegreya-tcb; \
		make cm-tcb; \
		make crimson-pro-tcb; \
		make eb-garamond-tcb; \
		make xcharter-tcb; \
	fi

.PHONY: all-tags-books
all-tags-books:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		make pictures; \
		make tags-alegreya-sans; \
		make tags-alegreya; \
		make tags-cm; \
		make tags-crimson-pro; \
		make tags-eb-garamond; \
		make tags-xcharter; \
		make tags-alegreya-sans-tcb; \
		make tags-alegreya-tcb; \
		make tags-cm-tcb; \
		make tags-crimson-pro-tcb; \
		make tags-eb-garamond-tcb; \
		make tags-xcharter-tcb; \
	fi

.PHONY: all-chapters
all-chapters:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		make pictures; \
		make chapters-alegreya-sans; \
		make chapters-alegreya; \
		make chapters-cm; \
		make chapters-crimson-pro; \
		make chapters-eb-garamond; \
		make chapters-xcharter; \
		make chapters-alegreya-sans-tcb; \
		make chapters-alegreya-tcb; \
		make chapters-cm-tcb; \
		make chapters-crimson-pro-tcb; \
		make chapters-eb-garamond-tcb; \
		make chapters-xcharter-tcb; \
	fi

.PHONY: all-tags-chapters
all-tags-chapters:
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
		echo >&2 "!! Current $$CONDA_PREFIX='$$CONDA_PREFIX'"; \
		echo >&2 "!! Please activate it first by running:"; \
		echo >&2 "!!"; \
		echo >&2 "!!   conda activate $(CONDA_ENV_NAME)"; \
		echo >&2 "!!"; \
		echo >&2 "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
		echo >&2 ""; \
		exit 1; \
	else \
		make pictures; \
		make tags-chapters-alegreya-sans; \
		make tags-chapters-alegreya; \
		make tags-chapters-cm; \
		make tags-chapters-crimson-pro; \
		make tags-chapters-eb-garamond; \
		make tags-chapters-xcharter; \
		make tags-chapters-alegreya-sans-tcb; \
		make tags-chapters-alegreya-tcb; \
		make tags-chapters-cm-tcb; \
		make tags-chapters-crimson-pro-tcb; \
		make tags-chapters-eb-garamond-tcb; \
		make tags-chapters-xcharter-tcb; \
	fi

.PHONY: clean
clean:
	rm -f tmp/*; \
	rm -f tmp/tikz-cd/*; \
	rm -f tmp/tikz-cd/dark-mode/*; \
	rm -f tmp/webcompile/*; \
	rm -f tmp/webcompile/dark-mode/*; \
	rm -f tmp/scalemath/*; \
	rm -f tmp/scalemath/dark-mode/*; \
	rm -f tmp/cm/*; \
	rm -f tmp/alegreya/*; \
	rm -f tmp/alegreya-sans/*; \
	rm -f tmp/alegreya-sans-tcb/*; \
	rm -f tmp/crimson-pro/*; \
	rm -f tmp/eb-garamond/*; \
	rm -f tmp/xcharter/*; \
	rm -f tmp/tags/cm/*; \
	rm -f tmp/tags/alegreya/*; \
	rm -f tmp/tags/alegreya-sans/*; \
	rm -f tmp/tags/alegreya-sans-tcb/*; \
	rm -f tmp/tags/crimson-pro/*; \
	rm -f tmp/tags/eb-garamond/*; \
	rm -f tmp/tags/xcharter/*; \
	rm -f output/book/*; \
	rm -f output/tags-book/*; \
	rm -f output/chapters/cm/*; \
	rm -f output/chapters/alegreya/*; \
	rm -f output/chapters/alegreya-sans/*; \
	rm -f output/chapters/alegreya-sans-tcb/*; \
	rm -f output/chapters/crimson-pro/*; \
	rm -f output/chapters/eb-garamond/*; \
	rm -f output/chapters/xcharter/*; \
	rm -f output/tags-chapters/cm/*; \
	rm -f output/tags-chapters/alegreya/*; \
	rm -f output/tags-chapters/alegreya-sans/*; \
	rm -f output/tags-chapters/alegreya-sans-tcb/*; \
	rm -f output/tags-chapters/crimson-pro/*; \
	rm -f output/tags-chapters/eb-garamond/*; \
	rm -f output/tags-chapters/xcharter/*;

# Target which creates all pdf files of chapters
.PHONY: pdfs
pdfs: $(FOOS) $(BARS) $(PDFS)

.PHONY: pictures
pictures:
	@printf "$(GREEN)Checking if conda environment '$(CONDA_ENV_NAME)' is active\n$(NC)"
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
		cd pictures/trans-flag/; \
		$(LUALATEX) trans-flag.tex; \
		cd ../light-mode/; \
		cd  ./monoidal-left-unity-of-id-otimes-sets/       && ./make.sh; \
		cd ../monoidal-left-unity-of-id-otimes-sets-star/  && ./make.sh; \
		cd ../monoidal-right-unity-of-id-otimes-sets/      && ./make.sh; \
		cd ../monoidal-right-unity-of-id-otimes-sets-star/ && ./make.sh; \
		cd ../symmetric-difference/associativity/; \
		$(LUALATEX) A_sdiff_B_sdiff_C.tex; \
		$(LUALATEX) A_sdiff_B.tex; \
		$(LUALATEX) A.tex; \
		$(LUALATEX) B_sdiff_C.tex; \
		$(LUALATEX) C.tex; \
		cd ../definition/; \
		$(LUALATEX) AsdiffB.tex; \
		$(LUALATEX) AsetminusB.tex; \
		$(LUALATEX) BsetminusA.tex; \
		cd ../via-unions-and-intersections/; \
		$(LUALATEX) Venn0001.tex; \
		$(LUALATEX) Venn0110.tex; \
		$(LUALATEX) Venn0111.tex; \
		cd ../../../dark-mode/; \
		luaotfload-tool --cache=erase; \
		cd  ./monoidal-left-unity-of-id-otimes-sets/       && ./make.sh; \
		cd ../monoidal-left-unity-of-id-otimes-sets-star/  && ./make.sh; \
		cd ../monoidal-right-unity-of-id-otimes-sets/      && ./make.sh; \
		cd ../monoidal-right-unity-of-id-otimes-sets-star/ && ./make.sh; \
		cd ../symmetric-difference/associativity/; \
		$(LUALATEX) A_sdiff_B_sdiff_C.tex; \
		$(LUALATEX) A_sdiff_B.tex; \
		$(LUALATEX) A.tex; \
		$(LUALATEX) B_sdiff_C.tex; \
		$(LUALATEX) C.tex; \
		cd ../definition/; \
		$(LUALATEX) AsdiffB.tex; \
		$(LUALATEX) AsetminusB.tex; \
		$(LUALATEX) BsetminusA.tex; \
		cd ../via-unions-and-intersections/; \
		$(LUALATEX) Venn0001.tex; \
		$(LUALATEX) Venn0110.tex; \
		$(LUALATEX) Venn0111.tex; \
	fi

.PHONY: tikzcd
tikzcd:
	@printf "$(GREEN)Checking if conda environment '$(CONDA_ENV_NAME)' is active\n$(NC)"
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
		python$(PYTHON_VERSION) ./scripts/make_book.py tikzcd > $(WEBDIR)/tikz.tex; \
		cd $(WEBDIR); \
		python$(PYTHON_VERSION) ../scripts/process_parentheses.py tikz.tex; \
		python$(PYTHON_VERSION) ../scripts/process_separation.py tikz.tex; \
		mv book.tex book.tex.bak; \
		mv tikz.tex book.tex; \
		python ../scripts/make_tikzcd.py book.tex; \
		mv book.tex.bak book.tex; \
		python ../scripts/make_tikzcd_regex_only.py book.tex; \
		cd -; \
		mkdir -p ./gerby-website/gerby/static/scalemath-images/dark-mode/; \
		mkdir -p ./gerby-website/gerby/static/webcompile-images/dark-mode/; \
		mkdir -p ./gerby-website/gerby/static/tikzcd-images/dark-mode/; \
		cp ./tmp/tikz-cd/*.svg              ./gerby-website/gerby/static/tikzcd-images/; \
		cp ./tmp/tikz-cd/dark-mode/*.svg    ./gerby-website/gerby/static/tikzcd-images/dark-mode/; \
		cp ./tmp/webcompile/*.svg           ./gerby-website/gerby/static/webcompile-images/; \
		cp ./tmp/webcompile/dark-mode/*.svg ./gerby-website/gerby/static/webcompile-images/dark-mode/; \
		cp ./tmp/scalemath/*.svg            ./gerby-website/gerby/static/scalemath-images/; \
		cp ./tmp/scalemath/dark-mode/*.svg  ./gerby-website/gerby/static/scalemath-images/dark-mode/; \
		cd -; \
	fi

# Define ANSI color codes
GREEN   := \033[1;32m# Bold Green
NC      := \033[0m    # No Color / Reset

# Target which clones a static version of the flask server running on 127.0.0.1:5000
.PHONY: wget-clone
wget-clone:
	rm -rf web-clone; \
	wget -k -p -E -m --no-host-directories -e robots=off http://127.0.0.1:5000/ -P web-clone || true;
	mkdir -p web-clone/static/tikzcd-images/dark-mode/; \
	mkdir -p web-clone/static/webcompile-images/dark-mode/; \
	mkdir -p web-clone/static/scalemath-images/; \
	mkdir -p web-clone/static/scalemath-images/dark-mode/; \
	cp tmp/tikz-cd/dark-mode/*.svg    web-clone/static/tikzcd-images/dark-mode; \
	cp tmp/webcompile/dark-mode/*.svg web-clone/static/webcompile-images/dark-mode; \
	cp tmp/scalemath/*.svg 			  web-clone/static/scalemath-images; \
	cp tmp/scalemath/dark-mode/*.svg  web-clone/static/scalemath-images/dark-mode;
	cp -r ./gerby-website/gerby/static/gifs/dark-mode  web-clone/static/gifs/;

# Target which compiles the website and serves it on 127.0.0.1:5000; ensures book PDF statistics work
.PHONY: web-and-serve-with-pdf-statistics
web-and-serve-with-pdf-statistics:
	@printf "$(GREEN)Checking if conda environment '$(CONDA_ENV_NAME)' is active\n$(NC)"
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
		make pictures; \
		make tags-alegreya-sans-tcb; \
		make web-and-serve; \
	fi

# Target which compiles the website and serves it on 127.0.0.1:5000
.PHONY: web-and-serve
web-and-serve:
	@printf "$(GREEN)Checking if conda environment '$(CONDA_ENV_NAME)' is active\n$(NC)"
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
		export LC_NUMERIC=C; \
		start=$$(date +%s.%2N); \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active ($$CONDA_PREFIX).$(NC)\n"; \
		printf "$(GREEN)Compiling preambles...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		printf "$(GREEN)Compiling and processing .TeX book...$(NC)\n"; \
		tex_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) scripts/make_book.py web > book.tex \
		python$(PYTHON_VERSION) scripts/process_parentheses.py book.tex; \
		cp book.tex tmp/; \
		tex_end=$$(date +%s.%2N); \
		tex_duration=$$(echo "$$tex_end - $$tex_start" | bc); \
		printf "$(GREEN)Compiling tags...$(NC)\n"; \
		tags_start=$$(date +%s.%2N); \
		rm tags/tags; \
		cp tags/tags.old tags/tags; \
		cd tags; \
		python$(PYTHON_VERSION) tagger.py >> tags; \
		cd ../; \
		rm -rf $(WEBDIR); \
		mkdir $(WEBDIR); \
		echo yes | python$(PYTHON_VERSION) scripts/add_tags.py; \
		make web; \
		tags_end=$$(date +%s.%2N); \
		tags_duration=$$(echo "$$tags_end - $$tags_start" | bc); \
		printf "$(GREEN)Compiling TikZ-CD diagrams$(NC)\n"; \
		tikzcd_start=$$(date +%s.%2N); \
		make tikzcd; \
		tikzcd_end=$$(date +%s.%2N); \
		tikzcd_duration=$$(echo "$$tikzcd_end - $$tikzcd_start" | bc); \
		printf "$(GREEN)Preprocessing plasTeX$(NC)\n"; \
		cd $(WEBDIR); \
		plastex_preprocess_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) ../scripts/process_parentheses_web.py book.tex; \
		python$(PYTHON_VERSION) ../scripts/process_separation.py book.tex; \
		python$(PYTHON_VERSION) ../scripts/process_multichapter_cref.py book.tex; \
		plastex_preprocess_end=$$(date +%s.%2N); \
		plastex_duration=$$(echo "$$plastex_preprocess_end - $$plastex_preprocess_start" | bc); \
		printf "$(GREEN)Running plasTeX$(NC)\n"; \
		plastex_start=$$(date +%s.%2N); \
		plastex --renderer=Gerby --sec-num-depth 3 book.tex; \
		plastex_end=$$(date +%s.%2N); \
		plastex_duration=$$(echo "$$plastex_end - $$plastex_start" | bc); \
		printf "$(GREEN)Postprocessing plasTeX$(NC)\n"; \
		plastex_postprocess_start=$$(date +%s.%2N); \
		cp -r book book.bak; \
		python$(PYTHON_VERSION) ../scripts/postprocess_tags.py; \
		rm -rf book.bak; \
		plastex_postprocess_end=$$(date +%s.%2N); \
		plastex_postprocess_duration=$$(echo "$$plastex_postprocess_end - $$plastex_postprocess_start" | bc); \
		printf "$(GREEN)Running Gerby$(NC)\n"; \
		cd ../gerby-website/gerby/tools/; \
		rm stacks.sqlite; \
		gerby_start=$$(date +%s.%2N); \
		cp ../../../output/tags-book/alegreya-sans-tcb.pdf stacks.pdf; \
		cp ../../../WEB/book.paux stacks.paux ; \
		cp ../../../WEB/tags stacks.tags ; \
		cp ../../../WEB/book/tag_ancestors_2.json ../tag_ancestors_2.json ; \
		python$(PYTHON_VERSION) update.py; \
		cd ../; \
		gerby_end=$$(date +%s.%2N); \
		gerby_duration=$$(echo "$$gerby_end - $$gerby_start" | bc); \
		printf "$(GREEN)Serving at localhost$(NC)\n"; \
		end=$$(date +%s.%2N); \
		duration=$$(echo "$$end - $$start" | bc); \
	    if [ -n "$$GITHUB_ENV" ]; then \
	    	printf "$(GREEN)Saving build statistics for GitHub Actions...$(NC)\n"; \
	    	{ \
	    		echo "TOTAL_DURATION=$$(printf '%.2f' $$duration)"; \
	    		echo "TEX_DURATION=$$(printf '%.2f' $$tex_duration)"; \
	    		echo "TAGS_DURATION=$$(printf '%.2f' $$tags_duration)"; \
	    		echo "TIKZCD_DURATION=$$(printf '%.2f' $$tikzcd_duration)"; \
				echo "PLASTEX_PREPROCESS=$$(printf '%.2f' $$plastex_preprocess_duration)"; \
	    		echo "PLASTEX_DURATION=$$(printf '%.2f' $$plastex_duration)"; \
	    		echo "PLASTEX_POSTPROCESS=$$(printf '%.2f' $$plastex_postprocess_duration)"; \
	    		echo "GERBY_DURATION=$$(printf '%.2f' $$gerby_duration)"; \
	    		echo "BUILD_SUCCESS=true"; \
	    	} >> $$GITHUB_ENV; \
	    else \
	    	printf "$(GREEN)Run target finished successfully.$(NC)\n"; \
	    	printf "$(GREEN)Total runtime: %6.2f seconds.$(NC)\n" "$$duration"; \
	    	printf "$(GREEN)-->          TeX: %6.2f seconds.$(NC)\n" "$$tex_duration"; \
	    	printf "$(GREEN)-->         Tags: %6.2f seconds.$(NC)\n" "$$tags_duration"; \
	    	printf "$(GREEN)-->      TikZ-CD: %6.2f seconds.$(NC)\n" "$$tikzcd_duration"; \
	    	printf "$(GREEN)-->  plasTeX-pre: %6.2f seconds.$(NC)\n" "$$plastex_preprocess_duration"; \
	    	printf "$(GREEN)-->      plasTeX: %6.2f seconds.$(NC)\n" "$$plastex_duration"; \
	    	printf "$(GREEN)--> plasTeX-post: %6.2f seconds.$(NC)\n" "$$plastex_postprocess_duration"; \
	    	printf "$(GREEN)-->        Gerby: %6.2f seconds.$(NC)\n" "$$gerby_duration"; \
	    fi; \
		FLASK_APP=application.py flask run; \
	fi

# Target which compiles the website and serves it on the computer's current IPv6 address
.PHONY: web-and-serve-on-ipv6
web-and-serve-on-ipv6:
	@printf "$(GREEN)Checking if conda environment '$(CONDA_ENV_NAME)' is active\n$(NC)"
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
		export LC_NUMERIC=C; \
		start=$$(date +%s.%2N); \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active ($$CONDA_PREFIX).$(NC)\n"; \
		printf "$(GREEN)Compiling preambles...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		printf "$(GREEN)Compiling and processing .TeX book...$(NC)\n"; \
		tex_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) scripts/make_book.py web > book.tex \
		python$(PYTHON_VERSION) scripts/process_parentheses.py book.tex; \
		cp book.tex tmp/; \
		tex_end=$$(date +%s.%2N); \
		tex_duration=$$(echo "$$tex_end - $$tex_start" | bc); \
		printf "$(GREEN)Compiling tags...$(NC)\n"; \
		tags_start=$$(date +%s.%2N); \
		rm tags/tags; \
		cp tags/tags.old tags/tags; \
		cd tags; \
		python$(PYTHON_VERSION) tagger.py >> tags; \
		cd ../; \
		rm -rf $(WEBDIR); \
		mkdir $(WEBDIR); \
		echo yes | python$(PYTHON_VERSION) scripts/add_tags.py; \
		make web; \
		tags_end=$$(date +%s.%2N); \
		tags_duration=$$(echo "$$tags_end - $$tags_start" | bc); \
		printf "$(GREEN)Compiling TikZ-CD diagrams$(NC)\n"; \
		tikzcd_start=$$(date +%s.%2N); \
		make tikzcd; \
		tikzcd_end=$$(date +%s.%2N); \
		tikzcd_duration=$$(echo "$$tikzcd_end - $$tikzcd_start" | bc); \
		printf "$(GREEN)Preprocessing plasTeX$(NC)\n"; \
		cd $(WEBDIR); \
		plastex_preprocess_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) ../scripts/process_parentheses_web.py book.tex; \
		python$(PYTHON_VERSION) ../scripts/process_separation.py book.tex; \
		python$(PYTHON_VERSION) ../scripts/process_multichapter_cref.py book.tex; \
		plastex_preprocess_end=$$(date +%s.%2N); \
		plastex_duration=$$(echo "$$plastex_preprocess_end - $$plastex_preprocess_start" | bc); \
		printf "$(GREEN)Running plasTeX$(NC)\n"; \
		plastex_start=$$(date +%s.%2N); \
		plastex --renderer=Gerby --sec-num-depth 3 book.tex; \
		plastex_end=$$(date +%s.%2N); \
		plastex_duration=$$(echo "$$plastex_end - $$plastex_start" | bc); \
		printf "$(GREEN)Postprocessing plasTeX$(NC)\n"; \
		plastex_postprocess_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) ../scripts/postprocess_tags.py; \
		plastex_postprocess_end=$$(date +%s.%2N); \
		plastex_postprocess_duration=$$(echo "$$plastex_postprocess_end - $$plastex_postprocess_start" | bc); \
		printf "$(GREEN)Running Gerby$(NC)\n"; \
		cd ../gerby-website/gerby/tools/; \
		rm stacks.sqlite; \
		gerby_start=$$(date +%s.%2N); \
		cp ../../../output/tags-book/alegreya-sans-tcb.pdf stacks.pdf; \
		cp ../../../WEB/book.paux stacks.paux ; \
		cp ../../../WEB/tags stacks.tags ; \
		cp ../../../WEB/book/tag_ancestors_2.json ../tag_ancestors_2.json ; \
		python$(PYTHON_VERSION) update.py; \
		cd ../; \
		gerby_end=$$(date +%s.%2N); \
		gerby_duration=$$(echo "$$gerby_end - $$gerby_start" | bc); \
		printf "$(GREEN)Serving at localhost$(NC)\n"; \
		end=$$(date +%s.%2N); \
		duration=$$(echo "$$end - $$start" | bc); \
	    if [ -n "$$GITHUB_ENV" ]; then \
	    	printf "$(GREEN)Saving build statistics for GitHub Actions...$(NC)\n"; \
	    	{ \
	    		echo "TOTAL_DURATION=$$(printf '%.2f' $$duration)"; \
	    		echo "TEX_DURATION=$$(printf '%.2f' $$tex_duration)"; \
	    		echo "TAGS_DURATION=$$(printf '%.2f' $$tags_duration)"; \
	    		echo "TIKZCD_DURATION=$$(printf '%.2f' $$tikzcd_duration)"; \
	    		echo "PLASTEX_PREPROCESS_DURATION=$$(printf '%.2f' $$plastex_preprocess_duration)"; \
	    		echo "PLASTEX_DURATION=$$(printf '%.2f' $$plastex_duration)"; \
	    		echo "PLASTEX_POSTPROCESS_DURATION=$$(printf '%.2f' $$plastex_postprocess_duration)"; \
	    		echo "GERBY_DURATION=$$(printf '%.2f' $$gerby_duration)"; \
	    		echo "BUILD_SUCCESS=true"; \
	    	} >> $$GITHUB_ENV; \
	    else \
	    	printf "$(GREEN)Run target finished successfully.$(NC)\n"; \
	    	printf "$(GREEN)Total runtime: %6.2f seconds.$(NC)\n" "$$duration"; \
	    	printf "$(GREEN)-->          TeX: %6.2f seconds.$(NC)\n" "$$tex_duration"; \
	    	printf "$(GREEN)-->         Tags: %6.2f seconds.$(NC)\n" "$$tags_duration"; \
	    	printf "$(GREEN)-->      TikZ-CD: %6.2f seconds.$(NC)\n" "$$tikzcd_duration"; \
	    	printf "$(GREEN)-->  plasTeX-pre: %6.2f seconds.$(NC)\n" "$$plastex_preprocess_duration"; \
	    	printf "$(GREEN)-->      plasTeX: %6.2f seconds.$(NC)\n" "$$plastex_duration"; \
	    	printf "$(GREEN)--> plasTeX-post: %6.2f seconds.$(NC)\n" "$$plastex_postprocess_duration"; \
	    	printf "$(GREEN)-->        Gerby: %6.2f seconds.$(NC)\n" "$$gerby_duration"; \
	    fi; \
		FLASK_APP=application.py flask run --host=::; \
	fi

# Target which compiles the website and records given variable to log.log
.PHONY: web-and-record
web-and-record:
	@printf "$(GREEN)Checking if conda environment '$(CONDA_ENV_NAME)' is active\n$(NC)"
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
		export LC_NUMERIC=C; \
		start=$$(date +%s.%2N); \
		printf "$(GREEN)Conda environment '$(CONDA_ENV_NAME)' is active ($$CONDA_PREFIX).$(NC)\n"; \
		printf "$(GREEN)Compiling preambles...$(NC)\n"; \
		python$(PYTHON_VERSION) scripts/make_preamble.py; \
		python$(PYTHON_VERSION) scripts/make_chapters_tex.py chapters.tex chapters2.tex; \
		printf "$(GREEN)Compiling and processing .TeX book...$(NC)\n"; \
		tex_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) scripts/make_book.py web > book.tex \
		python$(PYTHON_VERSION) scripts/process_parentheses.py book.tex; \
		cp book.tex tmp/; \
		tex_end=$$(date +%s.%2N); \
		tex_duration=$$(echo "$$tex_end - $$tex_start" | bc); \
		printf "$(GREEN)Compiling tags...$(NC)\n"; \
		tags_start=$$(date +%s.%2N); \
		rm tags/tags; \
		cp tags/tags.old tags/tags; \
		cd tags; \
		python$(PYTHON_VERSION) tagger.py >> tags; \
		cd ../; \
		rm -rf $(WEBDIR); \
		mkdir $(WEBDIR); \
		echo yes | python$(PYTHON_VERSION) scripts/add_tags.py; \
		make web; \
		tags_end=$$(date +%s.%2N); \
		tags_duration=$$(echo "$$tags_end - $$tags_start" | bc); \
		printf "$(GREEN)Compiling TikZ-CD diagrams$(NC)\n"; \
		tikzcd_start=$$(date +%s.%2N); \
		make tikzcd; \
		tikzcd_end=$$(date +%s.%2N); \
		tikzcd_duration=$$(echo "$$tikzcd_end - $$tikzcd_start" | bc); \
		printf "$(GREEN)Preprocessing plasTeX$(NC)\n"; \
		cd $(WEBDIR); \
		plastex_preprocess_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) ../scripts/process_parentheses_web.py book.tex; \
		python$(PYTHON_VERSION) ../scripts/process_separation.py book.tex; \
		python$(PYTHON_VERSION) ../scripts/process_multichapter_cref.py book.tex; \
		plastex_preprocess_end=$$(date +%s.%2N); \
		plastex_duration=$$(echo "$$plastex_preprocess_end - $$plastex_preprocess_start" | bc); \
		printf "$(GREEN)Running plasTeX$(NC)\n"; \
		plastex_start=$$(date +%s.%2N); \
		plastex --renderer=Gerby --sec-num-depth 3 book.tex; \
		plastex_end=$$(date +%s.%2N); \
		plastex_duration=$$(echo "$$plastex_end - $$plastex_start" | bc); \
		printf "$(GREEN)Postprocessing plasTeX$(NC)\n"; \
		plastex_postprocess_start=$$(date +%s.%2N); \
		python$(PYTHON_VERSION) ../scripts/postprocess_tags.py; \
		plastex_postprocess_end=$$(date +%s.%2N); \
		plastex_postprocess_duration=$$(echo "$$plastex_postprocess_end - $$plastex_postprocess_start" | bc); \
		printf "$(GREEN)Running Gerby$(NC)\n"; \
		cd ../gerby-website/gerby/tools/; \
		rm stacks.sqlite; \
		gerby_start=$$(date +%s.%2N); \
		cp ../../../output/tags-book/alegreya-sans-tcb.pdf stacks.pdf; \
		cp ../../../WEB/book.paux stacks.paux ; \
		cp ../../../WEB/tags stacks.tags ; \
		cp ../../../WEB/book/tag_ancestors_2.json ../tag_ancestors_2.json ; \
		python$(PYTHON_VERSION) update.py; \
		cd ../; \
		gerby_end=$$(date +%s.%2N); \
		gerby_duration=$$(echo "$$gerby_end - $$gerby_start" | bc); \
		printf "$(GREEN)Serving at localhost$(NC)\n"; \
		end=$$(date +%s.%2N); \
		duration=$$(echo "$$end - $$start" | bc); \
	    if [ -n "$$GITHUB_ENV" ]; then \
	    	printf "$(GREEN)Saving build statistics for GitHub Actions...$(NC)\n"; \
	    	{ \
	    		echo "TOTAL_DURATION=$$(printf '%.2f' $$duration)"; \
	    		echo "TEX_DURATION=$$(printf '%.2f' $$tex_duration)"; \
	    		echo "TAGS_DURATION=$$(printf '%.2f' $$tags_duration)"; \
	    		echo "TIKZCD_DURATION=$$(printf '%.2f' $$tikzcd_duration)"; \
				echo "PLASTEX_PREPROCESS_DURATION=$$(printf '%.2f' $$plastex_preprocess_duration)"; \
	    		echo "PLASTEX_DURATION=$$(printf '%.2f' $$plastex_duration)"; \
	    		echo "PLASTEX_POSTPROCESS_DURATION=$$(printf '%.2f' $$plastex_postprocess_duration)"; \
	    		echo "GERBY_DURATION=$$(printf '%.2f' $$gerby_duration)"; \
	    		echo "BUILD_SUCCESS=true"; \
	    	} >> $$GITHUB_ENV; \
	    else \
	    	printf "$(GREEN)Run target finished successfully.$(NC)\n"; \
	    	printf "$(GREEN)Total runtime: %6.2f seconds.$(NC)\n" "$$duration"; \
	    	printf "$(GREEN)-->          TeX: %6.2f seconds.$(NC)\n" "$$tex_duration"; \
	    	printf "$(GREEN)-->         Tags: %6.2f seconds.$(NC)\n" "$$tags_duration"; \
	    	printf "$(GREEN)-->      TikZ-CD: %6.2f seconds.$(NC)\n" "$$tikzcd_duration"; \
	    	printf "$(GREEN)-->  plasTeX-pre: %6.2f seconds.$(NC)\n" "$$plastex_preprocess_duration"; \
	    	printf "$(GREEN)-->      plasTeX: %6.2f seconds.$(NC)\n" "$$plastex_duration"; \
	    	printf "$(GREEN)--> plasTeX-post: %6.2f seconds.$(NC)\n" "$$plastex_postprocess_duration"; \
	    	printf "$(GREEN)-->        Gerby: %6.2f seconds.$(NC)\n" "$$gerby_duration"; \
	    fi; \
		{ \
	    	echo -n "$$(printf '%.2f' $$plastex_duration)"; \
	    	echo -n ","; \
		} >> ../../log.log; \
	fi
