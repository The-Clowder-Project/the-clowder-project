# Author: GPT4 \o/
import sys
from bs4 import BeautifulSoup

def clean(html):
    return BeautifulSoup(html, 'html.parser').prettify()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    modified_content = clean(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(modified_content)
