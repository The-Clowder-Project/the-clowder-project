# Author: GPT4 \o/
import re, sys

def main(input_file):
    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # Define the regex pattern to search for and the replacement string
    pattern = r'\\end\{(definition|example|question|proposition|theorem|corollary|lemma|remark|notation)\}\n\\begin\{(definition|example|question|proposition|theorem|corollary|lemma|remark|notation)\}'
    replacement = r'\\end{\1}\n\n\\begin{\2}'
    # Perform the regex substitution
    content = re.sub(pattern, replacement, content)

    # Write the changed content to the output file
    with open(input_file, 'w') as file:
        file.write(content)

if __name__ == "__main__":
    main(sys.argv[1])
