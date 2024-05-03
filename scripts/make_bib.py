# Author: GPT4
import re
import sys

def regex(content):
    pattern = re.compile(r'(AUTHOR\s*=\s*{)\\href{[^}]+}{([^}]+)}(},)')
    # Substitute the matched pattern with the captured author name.
    return re.sub(pattern, r'\1\2\3', content)

def main(input_file,output_file):
    with open(input_file, 'r') as f:
        content = f.read()

    transformed_content = regex(content)

    with open(output_file, 'w') as o:
        o.write(transformed_content)

if __name__ == "__main__":
    main(sys.argv[1],sys.argv[2])
