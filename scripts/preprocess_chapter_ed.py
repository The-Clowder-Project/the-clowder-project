import re, os, sys, time, preprocess

def replacement(line):
    line = preprocess.leftright_square_brackets_and_curly_brackets(line)
    line = preprocess.leftright_parentheses(line)
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
# Processs parentheses separately as it is a multi-line regex
def process_math_expr(match):
    expr = match.group()
    # Transformation for "("
    expr = re.sub(r'(?<!\\left)(?<!\\big)(?<!\\bigg)(?<!\\Big)(?<!\\Bigg)(?<!\\pig)(?<!\\pigg)(?<!\\Pig)(?<!\\Pigg)\(', '\\\\left(', expr)
    # Transformation for ")"
    expr = re.sub(r'(?<!\\left)(?<!\\right)(?<!\\big)(?<!\\bigg)(?<!\\Big)(?<!\\Bigg)(?<!\\pig)(?<!\\pigg)(?<!\\Pig)(?<!\\Pigg)\)', '\\\\right)', expr)
    return expr
# Regular expression to match inline and block math expressions
math_expr_pattern = r'\$[^$]*\$|\\\[[^\]]*\\\]'

pprocessed_file = "./" + file_with_relative_path + "PP.tex"

with open(processed_file, 'r') as f:
    content = f.read()

modified_content = process_math_expr(content)

with open(pprocessed_file, 'w') as f:
    f.write(modified_content)
