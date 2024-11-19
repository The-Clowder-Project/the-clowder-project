from functions import *
import preprocess

# Preamble for the book does not have external references
# Use the CJKutf8
# Use stacks-project-book if available
# Use amsbook otherwise
def print_preamble(path):
    preamble = open(path + "preamble-darwin.tex", 'r')
    for line in preamble:
        if line.find("%") == 0:
            continue
        if line.find("externaldocument") >= 0:
            continue
        if line.find("xr-hyper") >= 0:
            line = line.replace("xr-hyper", "CJKutf8")
        if line.find("\\documentclass") >= 0:
            #line = line.replace("{amsart", "]{amsbook")
            #line = line.replace("{stacks-project", "]{stacks-project-book")
            #line = line.replace("documentclass", "documentclass[oneside,11pt")
            line = "\\documentclass[oneside,11pt,a4paper]{book}\n"
        if line.find("\\IfFileExists]{") == 0:
            line = line.replace("IfFileExists]", "IfFileExists")
        if line.find("ABSOLUTEPATH") >= 0:
            absolute_path = preprocess.absolute_path()
            line = line.replace("ABSOLUTEPATH", absolute_path)
        print line,
    preamble.close()
    return

# Print names contributors
def print_list_contrib(path):
    filename = path + 'CONTRIBUTORS'
    CONTRIBUTORS = open(filename, 'r')
    first = 1
    for line in CONTRIBUTORS:
        if line.find("%") == 0:
            continue
        if len(line.rstrip()) == 0:
            continue
        contributor = line.rstrip()
        contributor = contributor.replace("(", "(\\begin{CJK}{UTF8}{min}")
        contributor = contributor.replace(")", "\\end{CJK})")
        if first:
            contributors = contributor
            first = 0
            continue
        contributors = contributors + ", " + contributor
    CONTRIBUTORS.close()
    contributors = contributors + "."
    print contributors

path = get_path()

print_preamble(path)

print "\\begin{document}"
print "\\frontmatter"
absolute_path = preprocess.absolute_path()
print "\\includepdf[pages={1}, scale=1.0, pagecommand={\\thispagestyle{empty}}]{"+absolute_path+"/titlepage/titlepage.pdf}"
#print "\\begingroup"
#print "\\topskip0pt"
#print "\\thispagestyle{empty}"
#print "\\vspace*{\\fill}"
#print "\\begin{center}"
#print "{\\LARGE\\bfseries The Clowder Project}"
#print "\\end{center}"
#print "\\vskip3.0cm"
#print "\\begin{center}"
#print "{\\LARGE\\bfseries 2017--2023}"
#print "\\end{center}"
#print "\\vskip10.5cm"
#print "\\begin{center}"
#print "{\\LARGE Emily}"
#print "\\end{center}"
#print "\\vskip1.5cm"
#print "\\begin{center}"
#print_version(path)
#print "\\end{center}"
#print "\\vspace*{\\fill}"
#print "\\endgroup"
print_list_contrib(path)
print "\\dominitoc"
print "{\\ShortTableOfContents}"
print "\\clearpage"
print "\\setcounter{tocdepth}{2}"
print "{\\TableOfContents}"
print "\\mainmatter"
#print_license_blurp(path)

lijstje = list_text_files(path)
#lijstje.append("index")

parts = get_parts(path)

ext = ".tex"
for name in lijstje:
    if name in parts:
        print "\\part{" + parts[name][0] + "}"
    if name == "index":
        filename = path + "tmp/index.tex"
    else:
        filename = path + name + ext
    tex_file = open(filename, 'r')
    verbatim = 0
    for line in tex_file:
        line = preprocess.amsthm(line)
        line = preprocess.proof(line)
        line = preprocess.proofbox_cm(line)
        # Everyone
        line = preprocess.proofbox_two(line)
        line = preprocess.leftright_square_brackets_and_curly_brackets(line)
        line = preprocess.expand_adjunctions(line)
        verbatim = verbatim + beginning_of_verbatim(line)
        if verbatim:
            if end_of_verbatim(line):
                verbatim = 0
            if name != 'introduction':
                print line,
            continue
        if line.find("\\input{preamble}") == 0:
            continue
        if line.find("\\begin{Introduction}") == 0:
            continue
        if line.find("\\end{Introduction}") == 0:
            continue
        if line.find("\\begin{document}") == 0:
            continue
        if line.find("\\title{") == 0:
            line = line.replace("\\title{", "\\chapter{")
        if line.find("\\maketitle") == 0:
            continue
        if line.find("\\tableofcontents") == 0:
            continue
        if line.find("chapter_modifications") >= 0:
            continue
        if line.find("\\ChapterTableOfContents") == 0:
            line = line.replace("\\ChapterTableOfContents", "\\Minitoc")
        if line.find("ABSOLUTEPATH") >= 0:
            absolute_path = preprocess.absolute_path()
            line = line.replace("ABSOLUTEPATH", absolute_path)
        if line.find("%\\item") >= 0:
            continue
        if line.find("\\par\\vspace") >= 0:
            continue
        if line.find("\\item\\label") >= 0:
            line = re.sub(r'(\\SloganFont{[^}]+})',r'\1%\n',line)
            #if line.find("\\item\\label{(.*?)}\\SloganFont{(.*?)}") >= 0:
            #line = line.replace("\\item\\label{.*?}\\SloganFont{.*?}", "\\item\\label{\1}\\SloganFont{\2}%\n")
        if line.find("\\input{chapters}") == 0:
            continue
        if line.find("\\bibliography") == 0:
            continue
        if line.find("\\begin{appendices}") == 0:
            line = line.replace("\\begin{appendices}", "\\begin{subappendices}")
        if line.find("\\end{appendices}") == 0:
            line = line.replace("\\end{appendices}", "\\end{subappendices}")
        if line.find("\\end{document}") == 0:
            continue
        if is_label(line):
            text = "\\label{" + name + ":"
            line = line.replace("\\label{", text)
        if contains_cref(line):
            line = replace_crefs(line, name)
        print line,

    tex_file.close()
    #print_chapters(path)

print "\\printbibliography"
# START INDICES
print "\\pagestyle{plain}"
# Notation
print "\\printindex[notation]"
# Foundations
print "\\printindex[set-theory]"
print "\\printindex[categories]"
print "\\printindex[higher-categories]"
print "\\printindex[representation-theory]"
#print "\\printindex[algebra]"
#print "\\printindex[algebraic-geometry]"
#print "\\printindex[analysis]"
#print "\\printindex[cellular-stuff]"
#print "\\printindex[cubical-stuff]"
#print "\\printindex[cyclic-stuff]"
#print "\\printindex[differential-geometry]"
#print "\\printindex[functional-analysis]"
#print "\\printindex[globular-stuff]"
#print "\\printindex[homological-algebra]"
#print "\\printindex[homotopical-algebra]"
#print "\\printindex[homotopy-theory]"
#print "\\printindex[infty-categories]"
#print "\\printindex[measure-theory]"
#print "\\printindex[monoids]"
#print "\\printindex[number-theory]"
#print "\\printindex[probability-theory]"
#print "\\printindex[p-adic-geometry]"
#print "\\printindex[physics]"
#print "\\printindex[simplicial-stuff]"
#print "\\printindex[stochastic-analysis]"
#print "\\printindex[supersymmetry]"
#print "\\printindex[topology]"
#print "\\printindex[type-theory]"
print "\\end{document}"
