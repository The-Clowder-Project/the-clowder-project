#/bin/bash
mkdir tags/tmp
filename="${2%.*}"
if [ "$1" == "cm" ]; then
    python scripts/preprocess_chapter_cm.py ${filename}
elif [ "$1" == "alegreya-sans" ]; then
    python scripts/preprocess_chapter_alegreya_sans.py ${filename}
elif [ "$1" == "alegreya-sans-tcb" ]; then
    python scripts/preprocess_chapter_alegreya_sans_tcb.py ${filename}
elif [ "$1" == "arno" ]; then
    python scripts/preprocess_chapter_arno.py ${filename}
elif [ "$1" == "darwin" ]; then
    python scripts/preprocess_chapter_darwin.py ${filename}
fi
##############################################################################################
cp ${filename}.tex ${filename}.tex.bak
mv ${filename}P.tex ${filename}.tex
mkdir tags/tmp/$1
if [ "$1" == "alegreya-sans-tcb" ]; then
    python2 ./scripts/tag_up_chapters_tcb.py ./ ${filename} > tags/tmp/$1/${filename}.tex
else
    python2 ./scripts/tag_up_chapters.py ./ ${filename} > tags/tmp/$1/${filename}.tex
fi
mv ${filename}.tex.bak ${filename}.tex
cd tags/tmp/$1
python ../../../scripts/process_raw_html_latex.py ${filename}.tex
python ../../../scripts/process_parentheses.py ${filename}.tex
lualatex -interaction=errorstopmode ${filename}.tex
biber ${filename}
##############################################################################################
if [ "$1" == "cm" ]; then
    mv ${filename}.pdf ../../../output/tags-chapters/cm/${filename}.pdf
elif [ "$1" == "alegreya-sans" ]; then
    mv ${filename}.pdf ../../../output/tags-chapters/alegreya-sans/${filename}.pdf
elif [ "$1" == "alegreya-sans-tcb" ]; then
    mv ${filename}.pdf ../../../output/tags-chapters/alegreya-sans-tcb/${filename}.pdf
elif [ "$1" == "arno" ]; then
    mv ${filename}.pdf ../../../output/tags-chapters/arno/${filename}.pdf
elif [ "$1" == "darwin" ]; then
    mv ${filename}.pdf ../../../output/tags-chapters/darwin/${filename}.pdf
fi
