# Author: GPT4 \o/
import sys
import re

def regex(html_str):
    list_classes = ["main-list", "sub-list", "subsub-list", "subsubsub-list"]
    
    # Keep track of the current depth
    depth = 0
    
    # Resultant HTML will be stored in this list
    result_html = []
    
    # Split the input HTML into lines
    lines = html_str.split('\n')
    
    # Process each line
    for line in lines:
        # Check if line contains an opening <ol> tag
        if re.search(r'<ol[^>]*>', line):
            # Add class to <ol> tag based on the current depth
            class_name = list_classes[min(depth, len(list_classes) - 1)]
            line = re.sub(r'(<ol[^>]*)>', r'\1 class="{}">'.format(class_name), line)
            depth += 1
        
        # Check if line contains a closing </ol> tag
        if re.search(r'</ol>', line):
            depth = max(0, depth - 1)
        
        # Append the modified line to the result
        result_html.append(line)
    
    # Return the updated HTML as a string
    return '\n'.join(result_html)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    modified_content = regex(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(modified_content)
