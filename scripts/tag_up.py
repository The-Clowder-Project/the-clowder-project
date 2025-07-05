from functions import *
import preprocess
import re
import time

from sys import argv
if not len(argv) == 4:
    print("")
    print("This script needs exactly two arguments")
    print("namely the path to the stacks project")
    print("and the stem of the tex file")
    print("")
    raise Exception('Wrong arguments')

path = preprocess.absolute_path()+"/"

path_name = argv[2]
name = argv[3]

def replace_newtheorem(line):
    #if line.find("\\newtheorem{definition}{Definition}[subsection]") == 0:
    #    line = line.replace("\\newtheorem{definition}{Definition}[subsection]", "\\newtheorem{definition}{\\href{https://stacks.math.columbia.edu/tag/\\TAG}{Definition}}[subsection]",1)
    #    line = line.rstrip()
    #    return line + "\n"
    #if line.find("\\newtheorem{(?!definition)") == 0:
    #    line = line.replace("]{", "]{\\href{https://stacks.math.columbia.edu/tag/\\TAG}{",1)
    #    line = line.rstrip()
    #    return line + "}\n"
    #if line.find("\\documentclass") == 0:
    #    line = line.replace("\\documentclass", "\\documentclass[oneside]")
    #    return line
    return line



# File preamble.tex is a special case and we do it separately
if name == "preamble":
    tex_file = open(path + name + ".tex", 'r')
    for line in tex_file:
        print(replace_newtheorem(line))

    version = git_version(path)

    from datetime import date
    now = date.today()

    print("\\usepackage{marginnote}")
    print("\\renewcommand*{\\marginfont}{\\normalfont}")

    print("\\date{This is a chapter of the Stacks Project, version " + version + ", compiled on " + now.strftime('%h %d, %Y.}'))

    tex_file.close()

    from sys import exit
    exit()




if name == "book":
    tags = get_tags_without_colons(path)
else:
    tags = get_tags(path)

label_tags = dict((tags[n][1], tags[n][0]) for n in range(0, len(tags)))

tex_file = open(path + path_name+name + ".tex", 'r')

document = 0
verbatim = 0
content = ""
for line in tex_file:
    
    # Check for verbatim
    verbatim = verbatim + beginning_of_verbatim(line)
    if verbatim:
        if end_of_verbatim(line):
            verbatim = 0
        content += line
        continue

    # Do stuff in preamble or just after \begin{document}
    if not document:
        if name == "book":
            line = replace_newtheorem(line)
            if line.find("\\begin{document}") == 0:
                content += "\\usepackage{marginnote}"
                content += "\\renewcommand*{\\marginfont}{\\normalfont}"
        content += line
        if line.find("\\begin{document}") == 0:
            content += "\\newcommand{\\TAG}{ZZZZ}"
            document = 1
        continue

    # labels all get hypertargets
    if is_label(line):
        short = find_label(line)
        if name == "book":
            label = short
        else:
            label = name + ":" + short
        if "tcb" in path_name:
            if (re.search(r"\\begin{warning}",line)):
                content += "\\hypertarget{" + label_tags[label] + "}{}"
                content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}\\vspace{-1.625\\baselineskip}"
                content += line
            else:
                if label in label_tags and line.find("\\item\\label") >= 0:
                    content += "\\item"
                    content += "\\hypertarget{" + label_tags[label] + "}{}"
                    content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}"
                    content += re.sub(r"\\item","",line)
                # don't put in hypertarget if label does not have a tag
                if label in label_tags and not line.find("\\item\\label") >= 0:
                    if (line.find("section{") >= 0 and not (short.find("section-phantom") >= 0)):
                        content += "\\hypertarget{" + label_tags[label] + "}{}"
                        if (line.find("section-") >= 0 and not (short.find("section-phantom") >= 0)):
                            if ((line.find(r"\section{") >= 0) and not (short.find("section-phantom") >= 0)):
                                content += re.sub(r"\\section{(.*?)}\\label",r"\\section[\1]{\\reversemarginpar\\marginnote{\\normalsize\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + r"}}}\1}\\label",line)
                            if ((line.find(r"\subsection{") >= 0) and not (short.find("section-phantom") >= 0)):
                                content += re.sub(r"\\subsection{(.*?)}\\label",r"\\subsection[\1]{\\reversemarginpar\\marginnote{\\normalsize\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + r"}}}\1}\\label",line)
                            if ((line.find(r"\subsubsection{") >= 0) and not (short.find("section-phantom") >= 0)):
                                content += re.sub(r"\\subsubsection{(.*?)}\\label",r"\\subsubsection[\1]{\\reversemarginpar\\marginnote{\\normalsize\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + r"}}}\1}\\label",line)
                    else:
                        content += line
                        if label in label_tags:
                            if short.find("section-phantom") >= 0:
                                content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}"
                            else:
                                content += "\\hypertarget{" + label_tags[label] + "}{}"
                                content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}[-1.625\\baselineskip]"
                        #if label in label_tags and line.find("section-") >= 0 and short.find("section-phantom") >= 0:
                        #    content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}"
                        #else:
                        #    content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}[-1.7\\baselineskip]"
            continue
        else:
            if label in label_tags and line.find("\\item\\label") >= 0:
                content += "\\item"
                content += "\\hypertarget{" + label_tags[label] + "}{}"
                content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}"
                content += re.sub(r"\\item","",line)
            if label in label_tags and not line.find("\\item\\label") >= 0:
                if (line.find("section{") >= 0 and not (short.find("section-phantom") >= 0)):
                    content += "\\hypertarget{" + label_tags[label] + "}{}"
                    if ((line.find(r"\section{") >= 0) and not (short.find("section-phantom") >= 0)):
                        content += re.sub(r"\\section{(.*?)}\\label",r"\\section[\1]{\\reversemarginpar\\marginnote{\\normalsize\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + r"}}}\1}\\label",line)
                    if ((line.find(r"\subsection{") >= 0) and not (short.find("section-phantom") >= 0)):
                        content += re.sub(r"\\subsection{(.*?)}\\label",r"\\subsection[\1]{\\reversemarginpar\\marginnote{\\normalsize\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + r"}}}\1}\\label",line)
                    if ((line.find(r"\subsubsection{") >= 0) and not (short.find("section-phantom") >= 0)):
                        content += re.sub(r"\\subsubsection{(.*?)}\\label",r"\\subsubsection[\1]{\\reversemarginpar\\marginnote{\\normalsize\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + r"}}}\1}\\label",line)
                else:
                    content += line
                    if label in label_tags:
                        content += "\\hypertarget{" + label_tags[label] + "}{}"
                        content += "\\reversemarginpar\\marginnote{\\texttt{\\href{https://www.clowderproject.com/tag/" + label_tags[label] + ".html}{" + label_tags[label] + "}}}"
            continue

    # Lines with labeled environments
    if labeled_env(line):
        oldline = line
        line = next(tex_file)
        short = find_label(line)
        if name == "book":
            label = short
        else:
            label = name + ":" + short
        if not label in label_tags:
            # ZZZZ is used as pointer to nonexistent tags
            content += "\\renewcommand{\\TAG}{ZZZZ}"
            content += oldline
            content += line
            continue
        content += "\\renewcommand{\\TAG}{" + label_tags[label] + "}"
        content += oldline
        content += line
        content += "\\reversemarginpar\\marginnote{" + label_tags[label] + "}\\hypertarget{" + label_tags[label] + "}{}"
        continue

    if line.find("\\begin{reference}") == 0:
        content += "\\normalmarginpar\\marginnote{"
        continue

    if line.find("\\end{reference}") == 0:
        content += "}"
        continue

    content += line

tex_file.close()
with open(path + path_name+name + ".tex", 'w') as f:
    f.write(content)
f.close()
