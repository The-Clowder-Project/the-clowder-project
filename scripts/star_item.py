import re
import sys

def regex(content):
    pattern = re.compile(r'<ul>\s*<li class="custom-item" data-marker="\$\\webleft \(\\star \\webright \)\$">')
    replacement = '<ul class="star"><li>'
    return pattern.sub(replacement, content)

def main(file):
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    content = regex(content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)
    main(sys.argv[1])
