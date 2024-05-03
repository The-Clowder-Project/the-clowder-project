import sys
import re

def replace_enumi(input_str):
    return re.sub('</li>', '<p></p></li>', input_str)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    content = replace_enumi(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
