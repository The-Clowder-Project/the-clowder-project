from functions import *
import preprocess

# Preamble for the web-book to be parsed by plastex
# All refs are internal in canonical form
# documentclass book
# load amsmath package for plastex
# Ignore reference, slogan, history environments
# Do not bother with multicol and xr-hyper pacakges
def print_preamble(path):
    preamble = open(path + "webpreamble.tex", 'r')
    next(preamble)
    next(preamble)
    next(preamble)
    next(preamble)
    next(preamble)
    next(preamble)
    next(preamble)
    next(preamble)
    print("\\documentclass{book}")
    print("\\usepackage{amsmath}")
    for line in preamble:
        if line.find("%") == 0:
            continue
        if line.find("externaldocument") >= 0:
            continue
        if line.find("\\newenvironment{reference}") >= 0:
            continue
        if line.find("\\newenvironment{slogan}") >= 0:
            continue
        if line.find("\\newenvironment{history}") >= 0:
            continue
        if line.find("multicol")>= 0:
            continue
        if line.find("xr-hyper") >= 0:
            continue
        #if line.find("defeq") >= 0:
        #    print(r"\newcommand{\defeq}{\mathrel{\overset{\mspace{-14mu}\rlap{\scriptscriptstyle\text{def}}}{=}}}")
            continue
        if line.find("\\usepackage{xurl}") >= 0:
            continue
        if line.find("biber") >= 0:
            continue
        if line.find("bibresource") >= 0:
            continue
        if line.find("\\usepackage{centernot}") >= 0:
            continue
        if line.find("\\usepackage{fontspec}") >= 0:
            continue
        if line.find("imakeidx") >= 0:
            continue
        if line.find("lettrine") >= 0:
            continue
        if line.find("makeindex") >= 0:
            continue
        if line.find("\\nin") >= 0:
            print(r"\newcommand{\nin}{\not\in}")
            continue
        if line.find("webcompile") >= 0:
            continue
        if line.find("bigfoot") >= 0:
            continue
        if line.find("\\usepackage{amsthm}") >= 0:
            continue
        if line.find("DeclareNewFootnote") >= 0:
            continue
        if line.find("mathtools") >= 0:
            continue
        if line.find("adjustbox") >= 0:
            line = ""
        if line.find("newenvironment{scalemath") >= 0:
            line = ""
        print(line),
    preamble.close()
    return

path = get_path()

print_preamble(path)

print("\\newcommand{\\dutchcal}[1]{\\mathcal{#1}}")
print("\\newcommand{\\CatFont}[1]{\\mathcal{#1}}")
print("\\let\\JapaneseFont\\relax")
print("\\newcommand{\\JapaneseFont}[1]{#1}")
print("\\begin{document}")
print("\\begin{titlepage}")
print("\\pagestyle{empty}")
print("\\setcounter{page}{1}")
print("\\centerline{\\LARGE\\bfseries Stacks Project}")
print("\\vskip1in")
print("\\noindent")
print("\\centerline{")
print_version(path)
print("}")
print("\\end{titlepage}")
#print_license_blurp(path)

lijstje = list_text_files(path)

parts = get_parts(path)

ext = ".tex"
for name in lijstje:
    if name in parts:
        print("\\part{" + parts[name][0] + "}")
        print("\\label{" + parts[name][1] + "}")
    
    filename = path + name + ext
    tex_file = open(filename, 'r')
    verbatim = 0
    for line in tex_file:
        line = preprocess.missing_chapters(line)
        line = preprocess.pdf_only(line)
        line = preprocess.expand_cref(line)
        line = preprocess.remove_index(line)
        line = preprocess.parbox(line)
        line = preprocess.proofbox_cm(line)
        line = preprocess.textdbend_2(line)
        line = preprocess.rmIendproofbox(line)
        # CM exclusive
        line = preprocess.amsthm_web(line)
        line = preprocess.proof(line)
        # Everyone
        line = preprocess.leftright_square_brackets_and_curly_brackets(line)
        line = preprocess.expand_adjunctions(line)
        verbatim = verbatim + beginning_of_verbatim(line)
        if verbatim:
            if end_of_verbatim(line):
                verbatim = 0
            if name != 'introduction':
                print(line),
            continue
        if line.find("\\input{chapter_modifications.tex}") == 0:
            continue
        if line.find("\\input{preamble}") == 0:
            continue
        if line.find("\\begin{document}") == 0:
            continue
        if line.find("\\title{") == 0:
            line = line.replace("\\title{", "\\chapter{")
        if line.find("\\SloganFont") == 0:
            line = line.replace("\\SloganFont", "\\textit")
        if line.find("\\maketitle") == 0:
            continue
        if line.find("\\tableofcontents") == 0:
            continue
        if line.find("\\footnote{%") >= 0:
            line = line.replace("\\footnote{", "\\footnote{\\textit{}%")
        if line.find("\\begin{appendices}") >= 0:
            continue
        if line.find("chapters2.tex}") >= 0:
            continue
        if line.find("\\end{appendices}") >= 0:
            continue
        if line.find("%\\item") >= 0:
            continue
        if line.find("\\par\\vspace") >= 0:
            continue
        if line.find("\\begingroup\\tiny") >= 0:
            print(r'<div class="tinysize">')
            continue
        if line.find("\\begingroup\\scriptsize") >= 0:
            print(r'<div class="scriptsize">')
            continue
        if line.find("\\begingroup\\small") >= 0:
            print(r'<div class="smallsize">')
            continue
        if line.find("\\begingroup\\footnotesize") >= 0:
            print(r'<div class="footnotesize">')
            continue
        if line.find("\\endgroup") >= 0:
            print(r"</div>")
            continue
        if line.find("\\opsup") >= 0:
            line = line.replace("\\opsup", "\\mkern-0.0mu\\opsup")
        if line.find("ABSOLUTEPATH") >= 0:
            absolute_path = preprocess.absolute_path()
            line = line.replace("ABSOLUTEPATH", absolute_path)
        if line.find("\\ChapterTableOfContents") == 0:
            continue
        if line.find("\\input{chapters}") == 0:
            continue
        if line.find("\\bibliography") == 0:
            continue
        if line.find("\\end{document}") == 0:
            continue
        if is_label(line):
            text = "\\label{" + name + ":"
            line = line.replace("\\label{", text)
        if contains_cref(line):
            line = replace_crefs(line, name)
        print(line),

    tex_file.close()

print("\\bibliography{bibliography}")
print("\\bibliographystyle{amsalpha}")
print("\\end{document}")
