#/bin/bash
export CLOWDER_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
total_start=$(date +%s.%2N)
# Define a function
regex() {
  start=$(date +%s.%2N)
  find . -name "*.tag" | xargs -I {} -P 12 python ../../the-clowder-project/scripts/$1 {}
  find . -name "*.proof" | xargs -I {} -P 12 python ../../the-clowder-project/scripts/$1 {}
  find . -name "*.footnote" | xargs -I {} -P 12 python ../../the-clowder-project/scripts/$1 {}
  end=$(date +%s.%2N)
  duration=$(echo "$end - $start" | bc)
  echo "Regex $1 finished in $duration seconds."
}

mkdir tmp
mkdir output
python scripts/make_bib.py bibliography.bib my.bib
python scripts/make_preamble.py
python scripts/make_tikzcd_preamble.py
start=$(date +%s.%2N)
python scripts/make_chapters_tex.py chapters.tex chapters2.tex
./make_web_book_silent.sh cm
./make_web_book_silent.sh cm
end=$(date +%s.%2N)
duration_cm=$(echo "$end - $start" | bc)
cp tmp/cm/book.tex tmp/book.tex
rm tags/tags
cp tags/tags.old tags/tags
cd tags
python3.6 tagger.py >> tags
cd ../
rm -rf WEB
mkdir ../WEB
echo yes | python scripts/add_tags.py
start_web=$(date +%s.%2N)
make web
end_web=$(date +%s.%2N)
duration_web=$(echo "$end - $start" | bc)
python ./scripts/web_tikzcd.py ./ > ../WEB/tikz.tex
cd ../WEB
start=$(date +%s.%2N)
python3.6 ../the-clowder-project/scripts/process_enumerate_inside_footnotes.py book.tex
python3.6 ../the-clowder-project/scripts/process_footnotes.py book.tex
python3.6 ../the-clowder-project/scripts/process_raw_html.py book.tex
python3.6 ../the-clowder-project/scripts/process_cite.py book.tex
python3.6 ../the-clowder-project/scripts/process_parentheses_web.py book.tex
python3.6 ../the-clowder-project/scripts/preprocess_separation.py book.tex
python3.6 ../the-clowder-project/scripts/process_itemize_latex.py book.tex
python3.6 ../the-clowder-project/scripts/process_itemize_latex_2.py book.tex
python3.6 ../the-clowder-project/scripts/process_multichapter_cref.py book.tex
python3.6 ../the-clowder-project/scripts/process_multichapter_cref2.py book.tex
python3.6 ../the-clowder-project/scripts/remove_empty_lines.py book.tex
python3.6 ../the-clowder-project/scripts/process_enumerate_inside_footnotes.py tikz.tex
python3.6 ../the-clowder-project/scripts/process_raw_html.py tikz.tex
python3.6 ../the-clowder-project/scripts/process_cite.py tikz.tex
python3.6 ../the-clowder-project/scripts/process_parentheses_web.py tikz.tex
python3.6 ../the-clowder-project/scripts/preprocess_separation.py tikz.tex
python3.6 ../the-clowder-project/scripts/process_itemize_latex.py tikz.tex
python3.6 ../the-clowder-project/scripts/process_itemize_latex_2.py tikz.tex
python3.6 ../the-clowder-project/scripts/process_multichapter_cref.py tikz.tex
python3.6 ../the-clowder-project/scripts/process_multichapter_cref2.py tikz.tex
python3.6 ../the-clowder-project/scripts/remove_empty_lines.py tikz.tex
#
end=$(date +%s.%2N)
duration_book=$(echo "$end - $start" | bc)
start=$(date +%s.%2N)
mv book.tex book.tex.bak
mv tikz.tex book.tex
python ../the-clowder-project/scripts/make_tikzcd.py book.tex
mv book.tex.bak book.tex
python ../the-clowder-project/scripts/make_tikzcd_regex_only.py book.tex
end=$(date +%s.%2N)
duration_tikz=$(echo "$end - $start" | bc)
echo "tikzcd and webcompile images compiled in $duration_tikz seconds."
# tikz-cd
cp ../the-clowder-project/tmp/tikz-cd/*.svg              ../the-clowder-project/gerby-website/gerby/static/tikzcd-images/
cp ../the-clowder-project/tmp/tikz-cd/dark-mode/*.svg    ../the-clowder-project/gerby-website/gerby/static/tikzcd-images/dark-mode/
# webcompile
cp ../the-clowder-project/tmp/webcompile/*.svg           ../the-clowder-project/gerby-website/gerby/static/webcompile-images/
cp ../the-clowder-project/tmp/webcompile/dark-mode/*.svg ../the-clowder-project/gerby-website/gerby/static/webcompile-images/dark-mode/
# scalemath
cp ../the-clowder-project/tmp/scalemath/*.svg            ../the-clowder-project/gerby-website/gerby/static/scalemath-images/
cp ../the-clowder-project/tmp/scalemath/dark-mode/*.svg  ../the-clowder-project/gerby-website/gerby/static/scalemath-images/dark-mode/
plastex --renderer=Gerby --sec-num-depth 3 book.tex
cd book/
start_regex=$(date +%s.%2N)
regex process.py
end_regex=$(date +%s.%2N)
duration_regex=$(echo "$end_regex - $start_regex" | bc)
echo "Regexes finished in $duration_regex seconds"
cd ../../the-clowder-project
mv ../WEB ./
cd gerby-website/gerby/tools/
rm stacks.sqlite ../stacks.sqlite
start=$(date +%s.%2N)
python3.6 update.py
end=$(date +%s.%2N)
duration_gerby=$(echo "$end - $start" | bc)
cd ../
ln -s tools/stacks.sqlite stacks.sqlite
total_end=$(date +%s.%2N)
total_duration=$(echo "$total_end - $total_start" | bc)
echo Total time taken to run: $total_duration seconds
echo Compile CM: $duration_cm seconds
echo Make WEB: $duration_web seconds
echo Regex book: $duration_book seconds
echo Compile TikZ+webcompile: $duration_tikz seconds
echo Regex webpages: $duration_regex seconds
echo Run Gerby update.py: $duration_gerby seconds
FLASK_APP=application.py flask run
