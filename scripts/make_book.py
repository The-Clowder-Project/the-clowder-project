from functions import *
import sys
import datetime
import preprocess
import re

def common_changes(style,line,name):
    if line.find("\\input{preamble}")          == 0 or \
            line.find("\\begin{Introduction}") == 0 or \
            line.find("\\end{Introduction}")   == 0 or \
            line.find("\\begin{document}")     == 0 or \
            line.find("\\maketitle")           == 0 or \
            line.find("\\tableofcontents")     == 0 or \
            line.find("chapter_modifications") >= 0 or \
            line.find("%\\item")               >= 0 or \
            line.find("\\input{chapters}")     == 0 or \
            line.find("\\bibliography")        == 0 or \
            line.find("\\end{document}")       == 0:
        line = ""

    if (style == "web"):
        if is_label(line):
            text = "\\label{" + name + ":"
            line = line.replace("\\label{", text)
        if contains_cref(line):
            line = replace_crefs(line, name)

    if line.find("\\title{") == 0:
        line = line.replace("\\title{", "\\chapter{")

    if line.find("ABSOLUTEPATH") >= 0:
        absolute_path = preprocess.absolute_path()
        line = line.replace("ABSOLUTEPATH", absolute_path)

    return line

def print_tex_file(tex_file,name,style):
    for line in tex_file:
        if (style == "tikzcd"):
            line = preprocess.expand_cref(line)
            line = preprocess.remove_index(line)
            line = preprocess.Proof_to_proof(line)
            line = preprocess.amsthm_web(line)
            line = preprocess.proofbox_to_proof(line)
        if (style == "web"):
            line = preprocess.amsthm_web(line)
            line = preprocess.expand_cref(line)
            line = preprocess.remove_index(line)
        elif ("tcb" in style):
            line = preprocess.tcbthm(line)
        else:
            line = preprocess.amsthm(line)
            line = preprocess.Proof_to_proof(line)
            line = preprocess.proofbox_to_proof(line)
        line = preprocess.leftright_square_brackets_and_curly_braces(line)
        line = preprocess.expand_adjunctions(line)

        # Apply common changes
        line = common_changes(style,line,name)
        if (line == ""):
            continue

        # Apply non-TCB specific changes
        if (not "tcb" in style):
            if line.find("\\par\\vspace") >= 0:
                continue
        #if ("tcb" in style):
        #    line = re.sub(r'^(\\begin\{[a-zA-Z\*]+\})\{(.*?)\}\{.*?\}%\\label\{(.*?)\}%$', r'\1{\2}{\3}%', line)
        #else:
        #    if line.find("\\par\\vspace") >= 0:
        #        continue

        # WEB specific fixes
        if (style == "web"):
            if line.find("\\SloganFont") == 0:
                line = line.replace("\\SloganFont", "\\textit")
            if line.find("\\begin{appendices}") >= 0:
                continue
            if line.find("chapters2.tex}") >= 0:
                continue
            if line.find("\\end{appendices}") >= 0:
                continue
            if line.find("\\opsup") >= 0:
                line = line.replace("\\opsup", "\\mkern-0.0mu\\opsup")
            if line.find("ABSOLUTEPATH") >= 0:
                absolute_path = preprocess.absolute_path()
                line = line.replace("ABSOLUTEPATH", absolute_path)
            if line.find("\\ChapterTableOfContents") == 0:
                continue
        else:
            if line.find("\\begin{appendices}") == 0:
                line = line.replace("\\begin{appendices}", "\\begin{subappendices}")
            if line.find("\\end{appendices}") == 0:
                line = line.replace("\\end{appendices}", "\\end{subappendices}")
            if line.find("\\ChapterTableOfContents") == 0:
                line = line.replace("\\ChapterTableOfContents", "\\Minitoc")
        print(line,end="")
    tex_file.close()

def print_preamble(path,style,stacks=False):
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
                if "xcharter" in style:
                    line = "\\documentclass[oneside,11pt,a4paper]{book}\n"
                elif style == "web":
                    line = "\\documentclass[oneside,12pt,a4paper]{book}\n\\usepackage{amsmath}"
                else:
                    line = "\\documentclass[oneside,12pt,a4paper]{book}\n"
        if line.find("ABSOLUTEPATH") >= 0:
            absolute_path = preprocess.absolute_path()
            line = line.replace("ABSOLUTEPATH", absolute_path)
        if ("tcb" in style and "tags" in style):
            line = preprocess.trans_flag_tcb_fix(line)
        if (style == "web" or style=="tikzcd"):
            if line.find("\\IfFileExists{") == 0:
                line = "\\documentclass{book}\n\\usepackage{amsmath}"
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
            if (style == "web"):
                if line.find("adjustbox") >= 0:
                    line = ""
                if line.find("newenvironment{scalemath") >= 0:
                    line = ""
        if ("tcb" in style):
            if line.find("\setlength{\TCBBoxCorrection}{-0.0\\baselineskip}") >= 0:
                line = "\setlength{\TCBBoxCorrection}{-0.5\\baselineskip}\n"
        if (style == "web"):
            line = preprocess.chaptermacros(line)
        print(line,end="")
    preamble.close()
    return

# Prints the current supporters
def print_list_supporters(path):
    # Read supporters
    filename = path + 'SUPPORTERS'
    SUPPORTERS = open(filename, 'r')
    supporters = []
    for line in SUPPORTERS:
        if line.find("%") == 0:
            continue
        if len(line.rstrip()) == 0:
            continue
        supporter = line.rstrip()
        supporter = supporter.replace("(", "(\\begin{CJK}{UTF8}{min}")
        supporter = supporter.replace(")", "\\end{CJK})")
        supporters.append(supporter)
    SUPPORTERS.close()
    # Print supporters
    print("\\begin{enumerate}")
    for supporter in supporters:
        print("    \\item " + supporter)
    print("\\end{enumerate}")

# Prints the project contributors
def print_list_contributors(path):
    # Read contributors
    filename = path + 'CONTRIBUTORS'
    CONTRIBUTORS = open(filename, 'r')
    contributors = []
    for line in CONTRIBUTORS:
        if line.find("%") == 0:
            continue
        if len(line.rstrip()) == 0:
            continue
        contributor = line.rstrip()
        contributor = contributor.replace("(", "(\\begin{CJK}{UTF8}{min}")
        contributor = contributor.replace(")", "\\end{CJK})")
        contributors.append(contributor)
    CONTRIBUTORS.close()
    # Print contributors
    print("\\begin{enumerate}")
    for contributor in contributors:
        print("    \\item " + contributor)
    print("\\end{enumerate}")

def main(style):
    absolute_path = preprocess.absolute_path()
    # Choose preamble based on style
    if (style == "web"):
        path = absolute_path + "/preamble/compiled/preamble-web.tex"
    if (style == "tikzcd"):
        path = absolute_path + "/preamble/compiled/preamble-tikzcd.tex"
    elif (style == "cm" or style == "tags-cm"):
        path = absolute_path + "/preamble/compiled/preamble-cm.tex"
    elif (style == "alegreya" or style == "tags-alegreya"):
        path = absolute_path + "/preamble/compiled/preamble-alegreya.tex"
    elif (style == "alegreya-sans" or style == "tags-alegreya-sans"):
        path = absolute_path + "/preamble/compiled/preamble-alegreya-sans.tex"
    elif (style == "crimson-pro" or style == "tags-crimson-pro"):
        path = absolute_path + "/preamble/compiled/preamble-crimson-pro.tex"
    elif (style == "eb-garamond" or style == "tags-eb-garamond"):
        path = absolute_path + "/preamble/compiled/preamble-eb-garamond.tex"
    elif (style == "xcharter" or style == "tags-xcharter"):
        path = absolute_path + "/preamble/compiled/preamble-xcharter.tex"
    elif (style == "cm-tcb" or style == "tags-cm-tcb"):
        path = absolute_path + "/preamble/compiled/preamble-cm-tcb.tex"
    elif (style == "alegreya-tcb" or style == "tags-alegreya-tcb"):
        path = absolute_path + "/preamble/compiled/preamble-alegreya-tcb.tex"
    elif (style == "alegreya-sans-tcb" or style == "tags-alegreya-sans-tcb"):
        path = absolute_path + "/preamble/compiled/preamble-alegreya-sans-tcb.tex"
    elif (style == "crimson-pro-tcb" or style == "tags-crimson-pro-tcb"):
        path = absolute_path + "/preamble/compiled/preamble-crimson-pro-tcb.tex"
    elif (style == "eb-garamond-tcb" or style == "tags-eb-garamond-tcb"):
        path = absolute_path + "/preamble/compiled/preamble-eb-garamond-tcb.tex"
    elif (style == "xcharter-tcb" or style == "tags-xcharter-tcb"):
        path = absolute_path + "/preamble/compiled/preamble-xcharter-tcb.tex"

    print_preamble(path,style)
    print("\\begin{document}")
    print("\\frontmatter")
    print("\\includepdf[pages={1}, scale=1.0, pagecommand={\\thispagestyle{empty}}]{"+absolute_path+"/titlepage/titlepage.pdf}")
    # Clowder Contributors
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
    print(version_no_kern(absolute_path+"/"))
    print("\\end{center}")
    print("\\vspace{3cm}")
    print("\\begin{center}")
    print("The following people have contributed to this project: ")
    print("\\end{center}")
    print_list_contributors(absolute_path+"/")
    # Clowder Supporters
    print("\\newpage")
    print("\\thispagestyle{empty}")
    print("\\begin{center}")
    print("\\end{center}")
    print("\\vspace{3cm}")
    print("\\begin{center}")
    print("{\LARGE\\textbf{The Clowder Project Supporters}}")
    print("\\end{center}")
    print("\\vspace{1cm}")
    print("\\begin{center}")
    print(version_no_kern(absolute_path+"/"))
    print("\\end{center}")
    print("\\vspace{3cm}")
    print("\\begin{center}")
    print("The following people currently support this project: ")
    print("\\end{center}")
    print_list_supporters(absolute_path+"/")
    # ToC
    print("\\dominitoc")
    print("\\begingroup")
    print("\\hypersetup{hidelinks}")
    if not style in ["web","tikzcd"]:
        print("{\\ShortTableOfContents}")
        print("\\clearpage")
        print("\\setcounter{tocdepth}{3}")
        print("\\newgeometry{margin=2.5cm}")
        print("{\\TableOfContents}")
        print("\\clearpage")
        print("\\restoregeometry")
    else:
        print("\\tableofcontents")
    print("\\endgroup")
    print("\\mainmatter")

    lijstje = list_text_files(absolute_path+"/")

    parts = get_parts(absolute_path+"/")

    ext = ".tex"
    for name in lijstje:
        if name in parts:
            print("\\part{" + parts[name][0] + "}")
            print("\\label{" + parts[name][1] + "}")
        if name == "index":
            filename = absolute_path + "/tmp/index.tex"
        else:
            filename = absolute_path + "/" + name + ext
        tex_file = open(filename, 'r')
        verbatim = 0
        print_tex_file(tex_file,name,style)
        tex_file.close()
        #if (style != "web"):
        #    print_chapters(absolute_path+"/")

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
    if (style == "web"):
        print("\\bibliography{bibliography}")
        print("\\bibliographystyle{amsalpha}")
    print("\\end{document}")

if __name__ == "__main__":
    main(sys.argv[1])
