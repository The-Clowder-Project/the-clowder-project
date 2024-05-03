import sys
import re

def regex(input_text):
    # Define the regular expression pattern to match the desired text
    pattern = r'\\item \\hyperref\[(.*?)\]'

    # Find all matches using the pattern
    matches = re.findall(pattern, input_text)

    # Extract the desired text from the matches
    desired_text = [match.split(':')[0] for match in matches]

    # Print the extracted text
    content = ''
    for text in desired_text:
        content += text + '\n'
    return content[:-1]

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py chapters.tex chapters.tmf")
        sys.exit(1)

    filepath_one = sys.argv[1]
    filepath_two = sys.argv[2]
    
    with open(filepath_one, 'r', encoding='utf-8') as file:
        content = file.read()

    content = regex(content)

    with open(filepath_two, 'w', encoding='utf-8') as file:
        file.write(content)
