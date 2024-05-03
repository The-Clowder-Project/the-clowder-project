# Author: GPT4 \o/
import re
import sys

def regex(content):
    pattern = re.compile(r'</li><li class="custom-item" id="(\w+)"><span class="counter"><a class="counter-link" href="/tag/\1"><span class="counter-inner"></span></a></span>\s*\n\n<em>([^<]+)</em>')
    replacement = r'</li><li class="custom-item" id="\1"><span class="counter"><a class="counter-link" href="/tag/\1"><span class="counter-inner"></span></a></span><a class="environment-identifier" href="/tag/\1"><em>\2</em></a>'
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
