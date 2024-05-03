# Compile WEB
#./make_web.sh
python scripts/make_preamble.py
python scripts/make_chapters_tex.py chapters.tex chapters2.tex
python scripts/make_chapters_tmf.py chapters.tex chapters.tmf
cd titlepage
./make_titlepage.sh
cd ../
while IFS= read -r line; do
    ./make_tags_chapter_debug.sh alegreya-sans-tcb $line
done < "chapters.tmf"
