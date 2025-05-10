from functions import *
import sys
import datetime
import preprocess

def print_tex_file(tex_file,name,style):
    for line in tex_file:
        if (style == "web"):
            line = preprocess.amsthm(line)
            line = preprocess.proofbox_two(line)
        elif (style == "cm"):
            line = preprocess.amsthm(line)
            line = preprocess.Proof_to_proof(line)
            line = preprocess.proofbox_to_proof(line)
            line = preprocess.remove_START_END_proofbox(line)
            line = preprocess.leftright_square_brackets_and_curly_braces(line)
            line = preprocess.expand_adjunctions(line)
        elif (style == "alegreya"):
            line = preprocess.amsthm(line)
            line = preprocess.Proof_to_proof(line)
            line = preprocess.proofbox_to_proof(line)
            line = preprocess.remove_START_END_proofbox(line)
            line = preprocess.leftright_square_brackets_and_curly_braces(line)
            line = preprocess.expand_adjunctions(line)
        elif (style == "alegreya-sans"):
            line = preprocess.amsthm(line)
            line = preprocess.Proof_to_proof(line)
            line = preprocess.proofbox_to_proof(line)
            line = preprocess.remove_START_END_proofbox(line)
            line = preprocess.leftright_square_brackets_and_curly_braces(line)
            line = preprocess.expand_adjunctions(line)
        elif (style == "crimson-pro"):
            line = preprocess.amsthm(line)
            line = preprocess.Proof_to_proof(line)
            line = preprocess.proofbox_to_proof(line)
            line = preprocess.remove_START_END_proofbox(line)
            line = preprocess.leftright_square_brackets_and_curly_braces(line)
            line = preprocess.expand_adjunctions(line)
        elif (style == "eb-garamond"):
            line = preprocess.amsthm(line)
            line = preprocess.Proof_to_proof(line)
            line = preprocess.proofbox_to_proof(line)
            line = preprocess.remove_START_END_proofbox(line)
            line = preprocess.leftright_square_brackets_and_curly_braces(line)
            line = preprocess.expand_adjunctions(line)

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
        if style == "alegreya-sans-tcb":
            line = line # Do nothing
        else:
            if line.find("\\par\\vspace") >= 0:
                continue
        #if line.find("\\item\\label") >= 0:
        #    line = re.sub(r'(\\SloganFont{[^}]+})',r'\1%\n',line)
        #    #if line.find("\\item\\label{(.*?)}\\SloganFont{(.*?)}") >= 0:
        #    #line = line.replace("\\item\\label{.*?}\\SloganFont{.*?}", "\\item\\label{\1}\\SloganFont{\2}%\n")
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
        print(line,end="")
    tex_file.close()

def print_preamble(path,stacks=False):
    preamble = open(path, 'r')
    for line in preamble:
        if line.find("%") == 0:
            continue
        if line.find("externaldocument") >= 0:
            continue
        if line.find("xr-hyper") >= 0:
            line = line.replace("xr-hyper", "CJKutf8")
        if (stacks == True):
            if line.find("\\IfFileExists{") == 0:
                line = line.replace("stacks-project", "stacks-project-book")
            if line.find("\\documentclass") == 0:
                line = line.replace("amsart", "amsbook")
                line = line.replace("stacks-project", "stacks-project-book")
        else:
            if line.find("\\documentclass") >= 0:
                line = "\\documentclass[oneside,12pt,a4paper]{book}\n"
        if line.find("ABSOLUTEPATH") >= 0:
            absolute_path = preprocess.absolute_path()
            line = line.replace("ABSOLUTEPATH", absolute_path)
        print(line,end="")
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
    print(contributors)

def main(style):
    absolute_path = preprocess.absolute_path()
    # Choose preamble based on style
    if (style == "web"):
        path = absolute_path + "/preamble/compiled/preamble-web.tex"
    elif (style == "cm"):
        path = absolute_path + "/preamble/compiled/preamble-cm.tex"
    elif (style == "alegreya"):
        path = absolute_path + "/preamble/compiled/preamble-alegreya.tex"
    elif (style == "alegreya-sans"):
        path = absolute_path + "/preamble/compiled/preamble-alegreya-sans.tex"
    elif (style == "alegreya-sans-tcb"):
        path = absolute_path + "/preamble/compiled/preamble-alegreya-sans-tcb.tex"
    elif (style == "crimson-pro"):
        path = absolute_path + "/preamble/compiled/preamble-crimson-pro.tex"
    elif (style == "eb-garamond"):
        path = absolute_path + "/preamble/compiled/preamble-eb-garamond.tex"
    elif (style == "xcharter"):
        path = absolute_path + "/preamble/compiled/preamble-xcharter.tex"

    print_preamble(path)
    print("\\begin{document}")
    print("\\frontmatter")
    print("\\includepdf[pages={1}, scale=1.0, pagecommand={\\thispagestyle{empty}}]{"+absolute_path+"/titlepage/titlepage.pdf}")
    print("\\newpage")
    print("\\thispagestyle{empty}")
    print("\\begin{center}")
    print("\\end{center}")
    print("\\vspace{3cm}")
    print("\\begin{center}")
    print("{\LARGE\\textbf{The Clowder Project Contributors}}")
    print("\\end{center}")
    print("\\vspace{1cm}")
    print("\\begin{center}")
    print(version(absolute_path+"/"))
    print("\\end{center}")
    print("\\vspace{3cm}")
    print("\\begin{center}")
    print("The following people have contributed to this project: ")
    print_list_contrib(absolute_path+"/")
    print("\\end{center}")
    print("\\dominitoc")
    if style in ["alegreya", "alegreya-sans", "alegreya-sans-tcb", "cm", "crimson-pro", "eb-garamond", "xcharter"]:
        print("{\\ShortTableOfContents}")
        print("\\clearpage")
        print("\\setcounter{tocdepth}{2}")
        print("{\\TableOfContents}")
    else:
        print("\\tableofcontents")
    print("\\mainmatter")

    lijstje = list_text_files(absolute_path+"/")

    parts = get_parts(absolute_path+"/")

    ext = ".tex"
    for name in lijstje:
        if name in parts:
            print("\\part{" + parts[name][0] + "}")
        if name == "index":
            filename = absolute_path + "/tmp/index.tex"
        else:
            filename = absolute_path + "/" + name + ext
        tex_file = open(filename, 'r')
        verbatim = 0
        print_tex_file(tex_file,name,style)
        tex_file.close()
        print_chapters(absolute_path+"/")

    print("\\printbibliography")
    # START INDICES
    print("\\pagestyle{plain}")
    # Notation
    print("\\printindex[notation]")
    # Foundations
    print("\\printindex[set-theory]")
    print("\\printindex[categories]")
    print("\\printindex[higher-categories]")
    #print("\\printindex[representation-theory]")
    #print("\\printindex[algebra]")
    #print("\\printindex[algebraic-geometry]")
    #print("\\printindex[analysis]")
    #print("\\printindex[cellular-stuff]")
    #print("\\printindex[cubical-stuff]")
    #print("\\printindex[cyclic-stuff]")
    #print("\\printindex[differential-geometry]")
    #print("\\printindex[functional-analysis]")
    #print("\\printindex[globular-stuff]")
    #print("\\printindex[homological-algebra]")
    #print("\\printindex[homotopical-algebra]")
    #print("\\printindex[homotopy-theory]")
    #print("\\printindex[infty-categories]")
    #print("\\printindex[measure-theory]")
    #print("\\printindex[monoids]")
    #print("\\printindex[number-theory]")
    #print("\\printindex[probability-theory]")
    #print("\\printindex[p-adic-geometry]")
    #print("\\printindex[physics]")
    #print("\\printindex[simplicial-stuff]"
    #print("\\printindex[stochastic-analysis]")
    #print("\\printindex[supersymmetry]")
    #print("\\printindex[topology]")
    #print("\\printindex[type-theory]")
    print("\\end{document}")

if __name__ == "__main__":
    main(sys.argv[1])
