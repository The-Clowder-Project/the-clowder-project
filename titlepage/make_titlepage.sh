#/bin/bash
python2 make_version.py ../ > text/version.tex
cd text;
lualatex title.tex
lualatex year.tex
lualatex author.tex
lualatex version.tex
cd ../
lualatex titlepage.tex
