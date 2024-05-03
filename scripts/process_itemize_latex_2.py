import sys
import re

def replace_enumerate(latex_text):
    """
    Converts LaTeX enumerate environments with '% PROCESS %' label to HTML ordered lists recursively.
    Parameters:
        latex_text (str): The LaTeX text to convert.
    Returns:
        str: The LaTeX text with converted enumerate environments.
    """
    # Regular expression to match LaTeX enumerate environments with '% PROCESS %' label
    enumerate_pattern = r'(\\begin{enumerate}% PROCESS %)(.+?)(\\end{enumerate}% PROCESS %)'
    # Function to convert a matched LaTeX enumerate environment to HTML
    def convert_to_html(match):
        before, latex_enum, after = match.groups()
        # Replace LaTeX \item with HTML <li>
        html_enum = re.sub(r'\\item', '<li class="custom-item"><span class="counter-inner-no-pointer"></span>', latex_enum)
        # Wrap the list items with HTML <ol class="main-list">
        return '<ol class="main-list">' + html_enum + '</ol>'
    # Replace LaTeX enumerate environments with HTML
    modified_text = re.sub(enumerate_pattern, convert_to_html, latex_text, flags=re.DOTALL)
    # Check if we need to process nested enumerates
    while re.search(enumerate_pattern, modified_text, flags=re.DOTALL):
        modified_text = re.sub(enumerate_pattern, convert_to_html, modified_text, flags=re.DOTALL)
    return modified_text

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    content = replace_enumerate(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
