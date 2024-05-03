# Author: GPT4
import re
import sys

def regex(content):
    pattern = r'\\cite\[([^\]]+)\]\{([^}]+)\}'
    # Define the replacement format
    replacement = r'\1 of \\cite{\2}'
    # Perform the substitution
    return re.sub(pattern, replacement, content)

def main(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    transformed_content = regex(content)

    with open(input_file, 'w') as f:
        f.write(transformed_content)

if __name__ == "__main__":
    main(sys.argv[1])
