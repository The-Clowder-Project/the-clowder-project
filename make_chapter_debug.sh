#/bin/bash
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
mv ${filename}P.tex tmp/$1/${filename}.tex
# Check if the directory exists
if [ ! -d "tmp/$1" ]; then
  mkdir -p "tmp/$1"
fi
cd tmp/$1
python ../../scripts/process_raw_html_latex.py ${filename}.tex
#python ../../scripts/process_parentheses.py ${filename}.tex
lualatex -interaction=errorstopmode ${filename}.tex
biber ${filename}
##############################################################################################
if [ "$1" == "cm" ]; then
    mv ${filename}.pdf ../../output/chapters/cm/${filename}.pdf
elif [ "$1" == "alegreya-sans" ]; then
    mv ${filename}.pdf ../../output/chapters/alegreya-sans/${filename}.pdf
elif [ "$1" == "alegreya-sans-tcb" ]; then
    mv ${filename}.pdf ../../output/chapters/alegreya-sans-tcb/${filename}.pdf
elif [ "$1" == "arno" ]; then
    mv ${filename}.pdf ../../output/chapters/arno/${filename}.pdf
elif [ "$1" == "darwin" ]; then
    mv ${filename}.pdf ../../output/chapters/darwin/${filename}.pdf
fi
