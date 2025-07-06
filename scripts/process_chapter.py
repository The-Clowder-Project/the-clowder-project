import re, os, io, sys, time, preprocess

def replacement(line,style):
    if ("tcb" in style):
        line = preprocess.tcbthm(line)
        line = preprocess.leftright_square_brackets_and_curly_braces(line)
        line = preprocess.expand_adjunctions(line)
    else:
        line = preprocess.amsthm(line)
        line = preprocess.Proof_to_proof(line)
        line = preprocess.proofbox_to_proof(line)
        line = preprocess.leftright_square_brackets_and_curly_braces(line)
        line = preprocess.expand_adjunctions(line)

    if line.find("%\\item") >= 0:
        line = ""
    if line.find("\\item\\label") >= 0:
        line = re.sub(r'(\\SloganFont{[^}]+})',r'\1%\n',line)
    if line.find(r"ABSOLUTEPATH") >= 0:
        absolute_path = preprocess.absolute_path()
        line = line.replace("ABSOLUTEPATH",absolute_path)
    if not ("tcb" in style):
        if line.find(r"\par\vspace") >= 0:
            line = ""
    return line


style = sys.argv[1]

chapter_number = sys.argv[2]

file_with_relative_path = sys.argv[3]

tex_file = "./" + file_with_relative_path + ".tex"

processed_file = "./" + file_with_relative_path + "P.tex"

# Delete previous processed LaTeX
if os.path.exists(processed_file):
    os.remove(processed_file)

f = open(processed_file, "a")

with open(tex_file) as fp:
   line = fp.readline()
   cnt = 1
   while line:
       if line.find(r"\input{preamble}") >= 0:
           line = ""
           preamble_path = ""
           if style == "cm" or style == "tags-cm":
               preamble_path = "./preamble/compiled/preamble-cm.tex"
           elif style == "alegreya" or style == "tags-alegreya":
               preamble_path = "./preamble/compiled/preamble-alegreya.tex"
           elif style == "alegreya-sans" or style == "tags-alegreya-sans":
               preamble_path = "./preamble/compiled/preamble-alegreya-sans.tex"
           elif style == "crimson-pro" or style == "tags-crimson-pro":
               preamble_path = "./preamble/compiled/preamble-crimson-pro.tex"
           elif style == "eb-garamond" or style == "tags-eb-garamond":
               preamble_path = "./preamble/compiled/preamble-eb-garamond.tex"
           elif style == "xcharter" or style == "tags-xcharter":
               preamble_path = "./preamble/compiled/preamble-xcharter.tex"
           elif style == "cm-tcb" or style == "tags-cm-tcb":
               preamble_path = "./preamble/compiled/preamble-cm-tcb.tex"
           elif style == "alegreya-tcb" or style == "tags-alegreya-tcb":
               preamble_path = "./preamble/compiled/preamble-alegreya-tcb.tex"
           elif style == "alegreya-sans-tcb" or style == "tags-alegreya-sans-tcb":
               preamble_path = "./preamble/compiled/preamble-alegreya-sans-tcb.tex"
           elif style == "crimson-pro-tcb" or style == "tags-crimson-pro-tcb":
               preamble_path = "./preamble/compiled/preamble-crimson-pro-tcb.tex"
           elif style == "eb-garamond-tcb" or style == "tags-eb-garamond-tcb":
               preamble_path = "./preamble/compiled/preamble-eb-garamond-tcb.tex"
           elif style == "xcharter-tcb" or style == "tags-xcharter-tcb":
               preamble_path = "./preamble/compiled/preamble-xcharter-tcb.tex"
           with open(preamble_path,'r') as preamble:
               for line2 in preamble:
                   if line2.find("\documentclass") >= 0:
                       if style == "xcharter" or style == "tags-xcharter":
                           line2 = r"\documentclass[oneside,11pt]{article}"
                       else:
                           line2 = r"\documentclass[oneside,12pt]{article}"
                   if line2.find(r"minitoc") >= 0:
                       continue
                   if line2.find(r"ABSOLUTEPATH") >= 0:
                       absolute_path = preprocess.absolute_path()
                       line2 = line2.replace("ABSOLUTEPATH",absolute_path)
                   if ("tcb" in style and "tags" in style):
                       line2 = preprocess.trans_flag_tcb_fix(line2)
                   if ("tcb" in style):
                       if line2.find("\\setlength{\\TCBBoxCorrection") >= 0:
                           line2 = "\\setlength{\\TCBBoxCorrection}{-0.5\\baselineskip}\n"
                   if line2.find("\\renewcommand{\\thesection}") >= 0:
                       line2 = r"\renewcommand{\thesection}{"+chapter_number+r".\oldthesection}"+"\n"
                   f.write(line2)
           line = fp.readline()
           cnt += 1
           continue
       if line.find(r"\input{chapter_modifications.tex}") >= 0:
           line = ""
           with open('preamble/chapter_modifications.tex','r') as modifications:
               for line2 in modifications:
                   if line2.find(r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{1.35em}}") >= 0:
                       line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{1.65em}}"+"\n"
                   if line2.find(r"{\hspace*{1.35em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{2.1em}}") >= 0:
                       line2 = r"{\hspace*{1.65em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{2.8em}}"+"\n"
                   f.write(line2)
           line = fp.readline()
           cnt += 1
           continue
       line = replacement(line,style)
       if line.find(r"\end{appendices}") >= 0:
           line = r"\printbibliography\end{appendices}"
       f.write(line)
       line = fp.readline()
       cnt += 1
f.close()
