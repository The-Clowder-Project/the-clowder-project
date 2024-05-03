# Compile WEB
start=$(date +%s.%2N)
#./make_web.sh
cp -r pictures tags/
python scripts/make_preamble.py
python scripts/make_chapters_tex.py chapters.tex chapters2.tex
python scripts/make_chapters_tmf.py chapters.tex chapters.tmf
cd titlepage
./make_titlepage.sh
cd ../
./make_all_chapters.sh &
./make_all_tags_chapters.sh &
./make_all_books.sh &
./make_all_tags_books.sh &
wait
./make_all_chapters.sh &
./make_all_tags_chapters.sh &
./make_all_books.sh &
./make_all_tags_books.sh &
cp -r output/* ../clowder-project-output/
cd ../clowder-project-output/
rm book/darwin.pdf
rm tags-book/darwin.pdf
rm -rf chapters/darwin
rm -rf tags-chapters/darwin
./commit.sh
end=$(date +%s.%2N)
duration=$(echo "$end - $start" | bc)
echo "Compilation finished in $duration seconds."
