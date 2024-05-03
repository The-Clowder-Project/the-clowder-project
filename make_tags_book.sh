#/bin/bash
python scripts/make_preamble.py
python scripts/make_tikzcd_preamble.py
if [ "$1" == "cm" ]; then
    python2 ./scripts/make_book_cm.py ./ > book.tex
elif [ "$1" == "alegreya-sans" ]; then
    python2 ./scripts/make_book_alegreya_sans.py ./ > book.tex
elif [ "$1" == "alegreya-sans-tcb" ]; then
    python2 ./scripts/make_book_alegreya_sans_tcb.py ./ > book.tex
elif [ "$1" == "arno" ]; then
    python2 ./scripts/make_book_arno.py ./ > book.tex
elif [ "$1" == "darwin" ]; then
    python2 ./scripts/make_book_darwin.py ./ > book.tex
fi
python3 ./scripts/process_parentheses.py book.tex
cp book.tex tmp/book.tex
mkdir tags/tmp/$1
mv book.tex tags/tmp/$1/book.tex
if [ "$1" == "alegreya-sans-tcb" ]; then
    python2 ./scripts/tag_up_tcb.py ./ book > tags/tmp/$1/book.tex
else
    python2 ./scripts/tag_up.py ./ book > tags/tmp/$1/book.tex
fi
python ./scripts/process_labels_tags.py tags/tmp/$1/book.tex
cp index_style.ist tags/tmp/$1/index_style.ist
cp stacks-project.cls tags/tmp/$1/
cp stacks-project-book.cls tags/tmp/$1/
cd tags/tmp/$1/
python ../../../scripts/process_raw_html_latex.py book.tex
max_strings=80000000 hash_extra=10000000 pool_size=4250000 main_memory=12000000 lualatex book
splitindex book
makeindex -s index_style.ist book-notation.idx
makeindex -s index_style.ist book-set-theory.idx
makeindex -s index_style.ist book-categories.idx
makeindex -s index_style.ist book-higher-categories.idx
#makeindex -s index_style.ist book-algebra.idx
#makeindex -s index_style.ist book-algebraic-geometry.idx
#makeindex -s index_style.ist book-analysis.idx
#makeindex -s index_style.ist book-differential-geometry.idx
#makeindex -s index_style.ist book-functional-analysis.idx
#makeindex -s index_style.ist book-infty-categories.idx
#makeindex -s index_style.ist book-homological-algebra.idx
#makeindex -s index_style.ist book-homotopical-algebra.idx
#makeindex -s index_style.ist book-homotopy-theory.idx
#makeindex -s index_style.ist book-monoids.idx
#makeindex -s index_style.ist book-number-theory.idx
#makeindex -s index_style.ist book-p-adic-geometry.idx
#makeindex -s index_style.ist book-physics.idx
#makeindex -s index_style.ist book-simplicial-stuff.idx
#makeindex -s index_style.ist book-supersymmetry.idx
#makeindex -s index_style.ist book-topology.idx
#makeindex -s index_style.ist book-type-theory.idx
biber book
cd ../../../
mv tags/tmp/$1/book.pdf output/tags-book/$1.pdf
