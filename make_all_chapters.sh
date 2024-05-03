#/bin/bash

python scripts/make_preamble.py
while IFS= read -r line || [[ -n "$line" ]]; do
    ./make_chapter.sh cm $line
    ./make_chapter.sh alegreya-sans $line
    ./make_chapter.sh alegreya-sans-tcb $line
    ./make_chapter.sh arno $line
    ./make_chapter.sh darwin $line
done < "chapters.tmf"
