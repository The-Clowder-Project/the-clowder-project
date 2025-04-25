#/bin/bash

# Define a function
compile() {
  parallel -j 1 lualatex ::: *.tex
  #for file in *.tex;do lualatex $file;done
}

# Need to do this since for some god forsaken reason lualatex crashes when the current cache is not cleared
mkdir gerby-website/gerby/static/tikzcd-images
mkdir gerby-website/gerby/static/tikzcd-images/dark-mode
mkdir gerby-website/gerby/static/webcompile-images
mkdir gerby-website/gerby/static/webcompile-images/dark-mode
mkdir tmp/tikz-cd
mkdir tmp/tikz-cd/dark-mode
mkdir tmp/webcompile
mkdir tmp/webcompile/dark-mode
cd tmp/tikz-cd
luaotfload-tool --cache=erase
compile
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../gerby-website/gerby/static/tikzcd-images/;done
cd dark-mode
luaotfload-tool --cache=erase
compile
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../../gerby-website/gerby/static/tikzcd-images/dark-mode/;done
mkdir ../../webcompile
cd ../../webcompile
luaotfload-tool --cache=erase
compile
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../gerby-website/gerby/static/webcompile-images/;done
cd dark-mode
luaotfload-tool --cache=erase
compile
for file in *.pdf;do pdf2svg $file ${file%.pdf}.svg;done
for file in *.svg;do cp $file ../../../gerby-website/gerby/static/webcompile-images/dark-mode/;done
