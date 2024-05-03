# Compile WEB
#./make_web.sh
python scripts/make_chapters_tex.py chapters.tex chapters2.tex
python scripts/make_chapters_tmf.py chapters.tex chapters.tmf
cd titlepage
./make_titlepage.sh
cd ../
./make_all_chapters_debug.sh
./make_all_tags_chapters_debug.sh
./make_all_books_debug.sh
./make_all_tags_books_debug.sh
./make_all_chapters_debug.sh
./make_all_tags_chapters_debug.sh
./make_all_books_debug.sh
./make_all_tags_books_debug.sh
cp -r output/* ../clowder-project-output/
cd ../clowder-project-output/
rm book/darwin.pdf
rm tags-book/darwin.pdf
rm -rf chapters/darwin
rm -rf tags-chapters/darwin
./commit.sh
