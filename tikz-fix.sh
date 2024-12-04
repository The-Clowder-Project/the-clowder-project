#/bin/bash

# Need to do this since for some god forsaken reason lualatex crashes when the current cache is not cleared
luaotfload-tool --cache=erase

#
mkdir gerby-website/gerby/static/tikzcd-images
mkdir gerby-website/gerby/static/tikzcd-images/dark-mode
mkdir gerby-website/gerby/static/webcompile-images
mkdir gerby-website/gerby/static/webcompile-images/dark-mode
mkdir tmp/tikz-cd
mkdir tmp/tikz-cd/dark-mode
mkdir tmp/webcompile
mkdir tmp/webcompile/dark-mode
cd tmp/tikz-cd
for file in *.tex;do lualatex $file;done
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../gerby-website/gerby/static/tikzcd-images/;done
cd dark-mode
luaotfload-tool --cache=erase
for file in *.tex;do lualatex $file;done
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../../gerby-website/gerby/static/tikzcd-images/dark-mode/;done
mkdir ../../webcompile
cd ../../webcompile
luaotfload-tool --cache=erase
for file in *.tex;do lualatex $file;done
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../gerby-website/gerby/static/webcompile-images/;done
cd dark-mode
luaotfload-tool --cache=erase
for file in *.tex;do lualatex $file;done
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../../gerby-website/gerby/static/webcompile-images/dark-mode/;done
mkdir ../../scalemath
cd ../../scalemath
luaotfload-tool --cache=erase
for file in *.tex;do lualatex $file;done
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../gerby-website/gerby/static/scalemath-images/;done
cd dark-mode
luaotfload-tool --cache=erase
for file in *.tex;do lualatex $file;done
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../../gerby-website/gerby/static/scalemath-images/dark-mode/;done
