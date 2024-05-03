import re, os, io, sys, time, preprocess

def replacement(line):
    # CM exclusive
    line = preprocess.amsthm(line)
    line = preprocess.proof(line)
    line = preprocess.proofbox_cm(line)
    # Everyone
    line = preprocess.proofbox_two(line)
    line = preprocess.leftright_square_brackets_and_curly_brackets(line)
    line = preprocess.expand_adjunctions(line)
    line = preprocess.textdbend(line)
    if line.find("%\\item") >= 0:
        line = ""
    if line.find(r"\par\vspace") >= 0:
        line = ""
    if line.find("\\item\\label") >= 0:
        line = re.sub(r'(\\SloganFont{[^}]+})',r'\1%\n',line)
    if line.find(r"ABSOLUTEPATH") >= 0:
        absolute_path = preprocess.absolute_path()
        line = line.replace("ABSOLUTEPATH",absolute_path)
    return line

file_with_relative_path = sys.argv[1]

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
           #line = line.replace("preamble","../preamble-alegreya-sans.tex")
           with open('./preamble-chapter-alegreya-sans.tex','r') as preamble:
               for line2 in preamble:
                   if line2.find(r"IfFileExists") >= 0:
                       line2 = r"\documentclass[oneside,11pt]{article}"
                   if line2.find(r"minitoc") >= 0:
                       continue
                   if line2.find(r"ABSOLUTEPATH") >= 0:
                       absolute_path = preprocess.absolute_path()
                       line2 = line2.replace("ABSOLUTEPATH",absolute_path)
                   f.write(line2)
           line = fp.readline()
           cnt += 1
           continue
       if line.find(r"\input{chapter_modifications.tex}") >= 0:
           line = ""
           with open('preamble/chapter_modifications.tex','r') as modifications:
               for line2 in modifications:
                   f.write(line2)
           line = fp.readline()
           cnt += 1
           continue
       line = replacement(line)
       if line.find(r"\end{appendices}") >= 0:
           line = r"\printbibliography\end{appendices}"
       f.write(line)
       line = fp.readline()
       cnt += 1
f.close()
