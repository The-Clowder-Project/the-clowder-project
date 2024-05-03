#/bin/bash

# Define a function
compile() {
  parallel -j 12 lualatex ::: *.tex
  #for file in *.tex;do lualatex $file;done
}

# Need to do this since for some god forsaken reason lualatex crashes when the current cache is not cleared
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
