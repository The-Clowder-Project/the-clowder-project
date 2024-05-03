# Author: GPT4 \o/
import re
import sys

def modify_article(match):
    article_content = match.group(1)
    
    # Replace <p> and </p> tags as per new requirements.
    article_content = re.sub(r'<p>\s*<br /><em><a href="(/tag/\w+)" data-tag="(\w+)">(Itemv|Enumi|Enumiv) (\d+)</a>,([^<]+)</em>:(.*?)</p>', r'<div class="p-proof">\n      <a href="\1" data-tag="\2" style="color: white;">Item \4</a>:\5</div>\6', article_content, flags=re.DOTALL)
    #
    article_content = re.sub(r'<p>\s*<em><a href="(/tag/\w+)" data-tag="(\w+)">(Itemv|Enumi|Enumiv) (\d+)</a>,([^<]+)</em>:', r'<div class="p-proof">\n      <a href="\1" data-tag="\2" style="color: white;">Item \4</a>:\5</div>', article_content, flags=re.DOTALL)
    
    return f'<article class="env-proof">{article_content}</article>'

def apply_transformations(content):
    return re.sub(r'<article class="env-proof">(.*?)</article>', modify_article, content, flags=re.DOTALL)

def main(file):
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    content = apply_transformations(content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)
    main(sys.argv[1])
