from functions import *

from sys import argv
if not len(argv) == 3:
    print
    print "This script needs exactly two arguments"
    print "namely the path to the stacks project"
    print "and the stem of the tex file"
    print
    raise Exception('Wrong arguments')

path = argv[1]
path.rstrip("/")
path = path + "/"

name = argv[2]

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
        print replace_newtheorem(line),

    version = git_version(path)

    from datetime import date
    now = date.today()

    print "\\usepackage{marginnote}"
    print "\\renewcommand*{\\marginfont}{\\normalfont}"

    print "\\date{This is a chapter of the Stacks Project, version " + version + ", compiled on " + now.strftime('%h %d, %Y.}')

    tex_file.close()

    from sys import exit
    exit()




tags = get_tags(path)

label_tags = dict((tags[n][1], tags[n][0]) for n in range(0, len(tags)))

if name == "book":
    tex_file = open(path + "tmp/" + name + ".tex", 'r')
else:
    tex_file = open(path + name + ".tex", 'r')

document = 0
verbatim = 0
for line in tex_file:
    
    # Check for verbatim
    verbatim = verbatim + beginning_of_verbatim(line)
    if verbatim:
        if end_of_verbatim(line):
            verbatim = 0
        print line,
        continue

    # Do stuff in preamble or just after \begin{document}
    if not document:
        if name == "book":
            line = replace_newtheorem(line)
            if line.find("\\begin{document}") == 0:
                print "\\usepackage{marginnote}"
                print "\\renewcommand*{\\marginfont}{\\normalfont}"
        print line,
        if line.find("\\begin{document}") == 0:
            print "\\newcommand{\\TAG}{ZZZZ}"
            document = 1
        continue

    # labels all get hypertargets
    if is_label(line):
        short = find_label(line)
        if name == "book":
            label = short
        else:
            label = name + ":" + short
        if (line.find("\\begin{warning}") >= 1):
            print "\\hypertarget{" + label_tags[label] + "}{}"
            print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}[0.0625\\baselineskip]\\par\\vspace{-0.5625\\baselineskip}"
            print line,
        else:
            print line,
        # don't put in hypertarget if label does not have a tag
        if label in label_tags:
            if not (line.find("\\begin{warning}") >= 1):
                print "\\hypertarget{" + label_tags[label] + "}{}"
                # there is a bug in marginnotes that eats subsection titles...
                #if short.find("subsection") >= 0:
                #    line = tex_file.next()
                #    print line,
                #    line = tex_file.next()
                #    print line,
                #    print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}"
                #    print "yay - " + label
                #else:
                if line.find("section-") >= 0 and short.find("phantom") == -1:
                    if line.find(r":section-") >= 0 and short.find("phantom") == -1:
                        print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}[-1.925\\baselineskip]\\par\\vspace{-0.0\\baselineskip}"
                    if line.find(r':subsection-') >= 0 and short.find("phantom") == -1:
                        print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}[-1.55\\baselineskip]\\par\\vspace{-0.0\\baselineskip}"
                    if line.find(":subsubsection-") >= 0 and short.find("phantom") == -1:
                        print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}[-1.55\\baselineskip]\\par\\vspace{-0.0\\baselineskip}"
                else:
                    if line.find("section-") >= 0 and short.find("phantom") >= 0:
                        print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}"
                    else:
                        if line.find("\\item") >= 0:
                            print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}"
                        else:
                            print "\\reversemarginpar\\marginnote{\\texttt{\\href{https://topological-modular-forms.github.io/the-clowder-project/tag/" + label_tags[label] + "}{" + label_tags[label] + "}}}[-1.7\\baselineskip]"
        continue

    # Lines with labeled environments
    if labeled_env(line):
        oldline = line
        line = tex_file.next()
        short = find_label(line)
        if name == "book":
            label = short
        else:
            label = name + ":" + short
        if not label in label_tags:
            # ZZZZ is used as pointer to nonexistent tags
            print "\\renewcommand{\\TAG}{ZZZZ}"
            print oldline,
            print line,
            continue
        print "\\renewcommand{\\TAG}{" + label_tags[label] + "}"
        print oldline,
        print line,
        print "\\reversemarginpar\\marginnote{" + label_tags[label] + "}\\hypertarget{" + label_tags[label] + "}{}"
        continue

    if line.find("\\begin{reference}") == 0:
        print "\\normalmarginpar\\marginnote{"
        continue

    if line.find("\\end{reference}") == 0:
        print "}"
        continue

    print line,

tex_file.close()
