# Author: GPT4
import re
import sys

def regex(content):
    # Step 1: Remove content between LATEX tags but keep the END RAW HTML tag
    latex_pattern = re.compile(r'% BEGIN LATEX HTML %.*?(% END RAW HTML %)', re.DOTALL | re.IGNORECASE)
    step1_output = re.sub(latex_pattern, r'\1', content)

    # Step 2: Replace RAW HTML tags
    raw_html_begin_pattern = re.compile(r'% BEGIN RAW HTML %', re.IGNORECASE)
    raw_html_end_pattern = re.compile(r'% END RAW HTML %', re.IGNORECASE)
    
    step2_output = re.sub(raw_html_begin_pattern, '\nBEGIN RAW HTML', step1_output)
    final_output = re.sub(raw_html_end_pattern, 'END RAW HTML\n', step2_output)
    return final_output

def main(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    transformed_content = regex(content)

    with open(input_file, 'w') as f:
        f.write(transformed_content)

if __name__ == "__main__":
    main(sys.argv[1])
