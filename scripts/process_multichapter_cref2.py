import re
import sys

def modify_cref_line(line):
    pattern = r'(\\cref{)([^:}]*:)([^:}]*:[^:}]*)(})'
    def repl(match):
        return f'{match.group(1)}{match.group(3)}{match.group(4)}'
    return re.sub(pattern, repl, line)

def regex(text):
    lines = text.splitlines()  # Split the text into lines
    modified_lines = [modify_cref_line(line) for line in lines]  # Apply modification to each line
    return "\n".join(modified_lines)  # Join the modified lines back together

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    modified_content = regex(content)  # Apply the line-by-line modifications

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(modified_content)  # Write the modified content back to the file
