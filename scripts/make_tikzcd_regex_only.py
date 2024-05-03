# Author: GPT4 \o/
import os, re, sys, subprocess

import concurrent.futures

def regex(filename):
    with open(filename, 'r') as file:
        content = file.read()
    content = re.sub(r'<div class="scriptsize">',r'\\begingroup\\scriptsize',content)
    content = re.sub(r'</div',r'\\endgroup',content)
    with open(filename, 'w') as file:
        file.write(content)

def main(input_file):
    output_dir_webcompile           = '../the-clowder-project/tmp/webcompile'
    output_dir_webcompile_dark_mode = '../the-clowder-project/tmp/webcompile/dark-mode'

    # Regular expression pattern to find webcompile environments
    pattern = re.compile(r'\\begin\{webcompile\}(.*?)\\end\{webcompile\}', re.DOTALL)

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # Extract webcompile environments and store them in a list
    webcompile_environments = pattern.findall(content)

    # Replace webcompile environments in the content
    for i, environment in enumerate(webcompile_environments):
        img_tag = f'<div class="webcompile"><img src="/static/webcompile-images/webcompile-{i:06d}.svg"></div>'
        content = pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    with open(input_file, 'w') as file:
        file.write(content)

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()
    # Regular expression pattern to find tikzcd environments
    pattern = re.compile(r'\\begin\{tikzcd\}(.*?)\\end\{tikzcd\}', re.DOTALL)

    # Extract tikzcd environments and store them in a list
    tikzcd_environments = pattern.findall(content)

    # Replace tikzcd environments in the content
    for i, environment in enumerate(tikzcd_environments):
        img_tag = f'<div class="tikz-cd"><img src="/static/tikzcd-images/tikzcd-{i:06d}.svg"></div>'
        content = pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)

    print(f"Processed {len(tikzcd_environments)} tikzcd environments.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)
    main(sys.argv[1])
