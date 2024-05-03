#/bin/bash

python scripts/make_preamble.py
while IFS= read -r line || [[ -n "$line" ]]; do
    ./make_tags_chapter_debug.sh cm $line
    ./make_tags_chapter_debug.sh alegreya-sans $line
    ./make_tags_chapter_debug.sh alegreya-sans-tcb $line
    ./make_tags_chapter_debug.sh arno $line
    ./make_tags_chapter_debug.sh darwin $line
done < "chapters.tmf"
