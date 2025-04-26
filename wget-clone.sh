#/bin/bash
mkdir ../web-clone
cd ../web-clone
wget  -k -p -E -m -e robots=off http://127.0.0.1:5000/
mkdir ../web-clone/127.0.0.1/static/tikzcd-images/dark-mode
mkdir ../web-clone/127.0.0.1/static/webcompile-images/dark-mode
cp tmp/tikz-cd/dark-mode/*.svg ../web-clone/127.0.0.1/static/tikzcd-images/dark-mode
cp tmp/webcompile/dark-mode/*.svg ../web-clone/127.0.0.1/static/webcompile-images/dark-mode
