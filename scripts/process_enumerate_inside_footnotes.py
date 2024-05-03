# Author: GPT4 \o/
import sys
import re

def replace_latex_footnote_enumerate(latex_text):
    """
    Replace LaTeX enumerate and item tags with HTML list tags within footnotes.

    Parameters:
    - latex_text (str): The LaTeX text string to modify.
    Returns:
    - str: The modified LaTeX text string with HTML list tags within footnotes.
    """
    # Regular expression to match LaTeX footnotes
    footnote_pattern = r'%--- Begin Footnote ---%(.*?)%---  End Footnote  ---%'
    # Function to replace LaTeX tags with HTML tags within a footnote
    def replace_enumerate(match):
        footnote_content = match.group(1)
        # Replace LaTeX enumerate and item tags with HTML list tags
        footnote_content = footnote_content.replace(r'\begin{enumerate}', '<ol class="main-list">')
        #footnote_content = footnote_content.replace(r'\item', '<li class="custom-item" id="NONE"><span class="counter"><a class="counter-link" href="/tag/NONE"><span class="counter-inner"></span></a></span>')
        footnote_content = footnote_content.replace(r'\item', '<li class="custom-item" id="NONE"><span class="counter-inner-no-pointer"></span>')
        footnote_content = footnote_content.replace(r'\end{enumerate}', '</ol>')
        return f'%--- Begin Footnote ---%{footnote_content}%---  End Footnote  ---%'
    # Replace each LaTeX footnote with its modified version
    modified_latex_text = re.sub(footnote_pattern, replace_enumerate, latex_text, flags=re.DOTALL)
    return modified_latex_text

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    content = replace_latex_footnote_enumerate(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
