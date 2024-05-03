# Author: GPT4 \o/
import re
import os
import preprocess

def expand_input(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    return content

def main():
    input_pattern = re.compile(r'\\input\{(.+?)\}')
    
    with open('tikzcd-prepreamble.tex', 'r') as prepreamble, open('tikzcd-preamble-tmp.tex', 'w') as preamble:
        for line in prepreamble:
            match = input_pattern.search(line)
            if match:
                input_file = match.group(1)
                if os.path.exists(input_file):
                    content = expand_input(input_file)
                    preamble.write(content)
                else:
                    print(f"Warning: {input_file} does not exist, writing the line as is.")
                    preamble.write(line)
            else:
                preamble.write(line)
    with open('tikzcd-preamble-tmp.tex', 'r') as prepreamble, open('tikzcd-preamble.tex', 'w') as preamble:
        for line in prepreamble:
            if line.find("\\SetTracking") >= 0:
                continue
            if line.find("ABSOLUTEPATH") >= 0:
                absolute_path = preprocess.absolute_path()
                line = line.replace("ABSOLUTEPATH", absolute_path)
                preamble.write(line)
            else:
                if line.find("widebar") >= 0:
                    continue
                else:
                    preamble.write(line)

if __name__ == "__main__":
    main()
