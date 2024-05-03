import sys
import re

def regex(content):
    # Regex pattern to find lines that start with a character in [A-Za-z]
    pattern = re.compile(r"^([A-Za-z].*)$", re.MULTILINE)
    # Replacement function to wrap the matched text with \textbf{}
    def replace(match):
        return r"\textbf{" + match.group(1) + "}"
    # Use re.sub() to replace occurrences of the pattern
    return re.sub(pattern, replace, content)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath_one = sys.argv[1]
    filepath_two = sys.argv[2]
    
    with open(filepath_one, 'r', encoding='utf-8') as file:
        content = file.read()

    content = regex(content)

    with open(filepath_two, 'w', encoding='utf-8') as file:
        file.write(content)
