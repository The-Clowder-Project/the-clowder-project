import re, os, sys, time, preprocess

def replacement(line):
    # WEB exclusive
    line = preprocess.expand_cref(line)
    line = preprocess.remove_index(line)
    line = preprocess.parbox(line)
    line = preprocess.proofbox_cm(line)
    line = preprocess.itemize(line)
    # CM exclusive
    line = preprocess.amsthm(line)
    line = preprocess.proof(line)
    # Everyone
    line = preprocess.leftright_square_brackets_and_curly_brackets(line)
    line = preprocess.expand_adjunctions(line)
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
       line = replacement(line)
       f.write(line)
       line = fp.readline()
       cnt += 1
f.close()
