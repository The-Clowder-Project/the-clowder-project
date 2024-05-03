# Author: GPT4 \o/
import sys
import re
import preprocess

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()
    
    content = preprocess.itemize(content)
    
    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
