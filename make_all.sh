#!/bin/bash

start=$(date +%s.%2N)

cp -r pictures tags/
python scripts/make_preamble.py
python ./scripts/make_tikzcd_preamble.py
python scripts/make_chapters_tex.py chapters.tex chapters2.tex
python scripts/make_chapters_tmf.py chapters.tex chapters.tmf
./make_pictures.sh
cd titlepage
./make_titlepage.sh
cd ../

chapters=(
  "sets"
  "constructions-with-sets"
  "monoidal-structures-on-the-category-of-sets"
  "pointed-sets"
  "tensor-products-of-pointed-sets"
  "relations"
  "constructions-with-relations"
  "equivalence-relations-and-apartness-relations"
  "categories"
  "constructions-with-monoidal-categories"
  "types-of-morphisms-in-bicategories"
)

# Make chapters
rm -rf tmp/cm/*
rm -rf tmp/alegreya-sans/*
rm -rf tmp/alegreya-sans-tcb/*
rm -rf tmp/arno/*
rm -rf tmp/darwin/*

# CM
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh cm $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh cm $chapter
done

# Alegreya Sans
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh alegreya-sans $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh alegreya-sans $chapter
done

# Alegreya Sans TCB
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh alegreya-sans-tcb $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh alegreya-sans-tcb $chapter
done

# Arno
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh arno $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_chapter.sh arno $chapter
done

## Darwin
#luaotfload-tool --cache=erase
#for chapter in "${chapters[@]}"; do
#  ./make_chapter.sh darwin $chapter
#  biber $chapter
#done
#for chapter in "${chapters[@]}"; do
#  ./make_chapter.sh darwin $chapter
#done

# Make tags chapters
rm -rf tags/tmp/cm/*
rm -rf tags/tmp/alegreya-sans/*
rm -rf tags/tmp/alegreya-sans-tcb/*
rm -rf tags/tmp/arno/*
rm -rf tags/tmp/darwin/*

# CM
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh cm $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh cm $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh cm $chapter
done

# Alegreya Sans
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh alegreya-sans $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh alegreya-sans $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh alegreya-sans $chapter
done

# Alegreya Sans TCB
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh alegreya-sans-tcb $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh alegreya-sans-tcb $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh alegreya-sans-tcb $chapter
done

# Arno
luaotfload-tool --cache=erase
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh arno $chapter
  biber $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh arno $chapter
done
for chapter in "${chapters[@]}"; do
  ./make_tags_chapter.sh arno $chapter
done

## Darwin
#luaotfload-tool --cache=erase
#for chapter in "${chapters[@]}"; do
#  ./make_tags_chapter.sh darwin $chapter
#  biber $chapter
#done
#for chapter in "${chapters[@]}"; do
#  ./make_tags_chapter.sh darwin $chapter
#done
#for chapter in "${chapters[@]}"; do
#  ./make_tags_chapter.sh darwin $chapter
#done

# Make books
./make_book.sh cm
./make_book.sh alegreya-sans
./make_book.sh alegreya-sans-tcb
./make_book.sh arno
./make_book.sh darwin

# Make tags books
./make_tags_book.sh cm
./make_tags_book.sh cm
./make_tags_book.sh alegreya-sans
./make_tags_book.sh alegreya-sans
./make_tags_book.sh alegreya-sans-tcb
./make_tags_book.sh alegreya-sans-tcb
./make_tags_book.sh arno
./make_tags_book.sh arno
./make_tags_book.sh darwin
./make_tags_book.sh darwin

cp -r output/* ../clowder-project-output/
cd ../clowder-project-output/
rm book/darwin.pdf
rm tags-book/darwin.pdf
rm -rf chapters/darwin
rm -rf tags-chapters/darwin
#./commit.sh

end=$(date +%s.%2N)
duration=$(echo "$end - $start" | bc)
echo "Compilation finished in $duration seconds."
