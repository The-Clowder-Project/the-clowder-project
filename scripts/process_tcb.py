import sys
import re

def regex(content):
    return re.sub(r"\\subsection\{([^\}]*)\}\\label\{([^\}]*)\}\n\\begin",r"\\subsection{\1}\\label{\2}\n$\\phantom{a}$\n\\begin",content,re.DOTALL)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)
    filepath = sys.argv[1]
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()
    content = regex(content)
    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
