import re
import os
import sys

def modify_cref_line(line):
    pattern = r'(\\cref{)([^:}]*:)([^:}]*:[^:}]*)(})'
    def repl(match):
        return f'{match.group(1)}{match.group(3)}{match.group(4)}'
    return re.sub(pattern, repl, line)

def regex(text):
    lines = text.splitlines()  # Split the text into lines
    modified_lines = [modify_cref_line(line) for line in lines]  # Apply modification to each line
    return "\n".join(modified_lines)  # Join the modified lines back together

def line_regex(text):
    """Replaces a complex ChapterRef pattern with a simplified version.

    Handles partial regex testing or full replacement based on test_partials.
    Converts chapter label to hyphenated lowercase in the replacement string,
    and removes 'chapter-' prefix.
    """

    def camel_case_to_hyphenated_lowercase(text):
        """Converts a CamelCase string to hyphenated lowercase."""
        s1 = re.sub('(.)([A-Z][a-z]+)', r'\1-\2', text)
        return re.sub('([a-z0-9])([A-Z])', r'\1-\2', s1).lower()

    def remove_chapter_prefix(text):
        """Removes 'chapter-' prefix and any leading hyphens."""
        return re.sub(r'\\-chapter-', '', text)

    # Full regex pattern
    full_pattern = r"\\ChapterRef\{(?P<chapter_label>[^,]+),\s+\\cref\{(?P<label1>[^}]+)\}\s+of\s+\\cref\{(?P<label2>[^}]+)\}\s+of\s+\\cref\{(?P<label3>[^}]+)\}\s*\}\s*\{\s*\\cref\{(?P<label4>[^}]+)\}\s+of\s+\\cref\{(?P<label5>[^}]+)\}\s+of\s+\\cref\{(?P<label6>[^}]+)\}\}"

    def replacement(match):
        chapter_label = match.group('chapter_label')
        label1 = match.group('label1')
        label2 = match.group('label2')
        label3 = match.group('label3')
        # Convert chapter label to hyphenated lowercase and remove 'chapter-' prefix
        hyphenated_chapter_label = remove_chapter_prefix(camel_case_to_hyphenated_lowercase(chapter_label))
        return rf"\cref{{{hyphenated_chapter_label}:section-phantom}}, \cref{{{label1}}} of \cref{{{label2}}} of \cref{{{label3}}}"

    # Handle non-breaking spaces
    text = text.replace(" ", " ")

    return re.sub(full_pattern, replacement, text, flags=re.DOTALL)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    modified_content = regex(content)  # Apply the line-by-line modifications

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(modified_content)  # Write the modified content back to the file

    with open(filepath, 'r', encoding='utf-8') as f_in, open("temp_modified_book.tex", 'w', encoding='utf-8') as f_out:
        for line_num, line in enumerate(f_in, 1):
            modified_line = line_regex(line)  # Apply full regex
            f_out.write(modified_line)
        os.replace("temp_modified_book.tex", filepath)
