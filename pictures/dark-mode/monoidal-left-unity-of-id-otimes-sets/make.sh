#!/bin/bash

for n in {01..06}; do lualatex $n.tex; done
for n in {01..06}; do pdf2svg $n.pdf $n.svg; done
for n in {01..06}; do inkscape "$n.svg" --export-type=png --export-dpi=1200 --export-filename="$n.png"; done
convert -delay 100 -loop 0 -dispose Background 01.png 02.png 03.png 04.png 05.png 06.png 06.png 06.png animated.gif
cp animated.gif ../../../gerby-website/gerby/static/gifs/dark-mode/monoidal-left-unity-of-id-otimes-sets.gif
