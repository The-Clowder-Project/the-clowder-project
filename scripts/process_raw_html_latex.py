import re
import sys

def regex(content: str) -> str:
    # Define state
    inside_raw_html = 0  # 0: outside, 1: inside raw html, 2: inside latex html
    # Processed lines
    processed_lines = []
    # Split the content into lines and process
    for line in content.splitlines(keepends=True):
        # Check for BEGIN RAW HTML
        if re.match(r'\s*% BEGIN RAW HTML', line):
            inside_raw_html += 1
            continue  # Skip this line
        # If inside raw html block, check for BEGIN LATEX HTML
        elif inside_raw_html == 1 and re.match(r'\s*% BEGIN LATEX HTML', line):
            inside_raw_html += 1
            continue  # Skip this line
        # If inside the latex html part, check for END RAW HTML
        elif inside_raw_html == 2 and re.match(r'\s*% END RAW HTML', line):
            inside_raw_html -= 1
            inside_raw_html -= 1
            continue  # Skip this line
        # Only add lines that are outside the block or inside the latex html part
        if inside_raw_html != 1:
            processed_lines.append(line)
    # Return the processed content
    return ''.join(processed_lines)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    content = regex(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
