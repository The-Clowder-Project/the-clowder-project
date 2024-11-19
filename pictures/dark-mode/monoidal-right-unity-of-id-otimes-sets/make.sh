for n in {01..06}; do lualatex $n.tex; done
for n in {01..06}; do pdf2svg $n.pdf $n.svg; done
for n in {01..06}; do inkscape "$n.svg" --export-type=png --export-dpi=1200 --export-filename="$n.png"; done
convert -delay 100 -loop 1 *.png animated.gif
cp animated.gif ../../../gerby-website/gerby/static/gifs/dark-mode/monoidal-right-unity-of-id-otimes-sets.gif
cp *.svg ../../../gerby-website/gerby/static/slides/monoidal-right-unity-of-id-otimes-sets/dark-mode/
