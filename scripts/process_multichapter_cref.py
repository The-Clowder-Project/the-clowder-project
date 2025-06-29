import re
import os
import sys

def regex_one(text):
    def transform(subtext):
        def repl(match):
            return '-' + match.group(0).lower()

        stripped_text = re.sub(r'^\\Chapter', '', subtext)
        hyphenated_text = re.sub(r'(?<=[a-z])([A-Z])', repl, stripped_text)
        return hyphenated_text.lower() + ':section-phantom'

    def cref_transform(crefs, chapter_ref):
        cref_parts = []
        for cref in crefs:
            cref_texts = cref.split(',')
            for cref_text in cref_texts:
                cref_text = cref_text.strip()
                if ':' not in cref_text:  # Apply chapter transformation if no ':' found
                    cref_text = f'{chapter_ref}:{cref_text}'
                cref_parts.append(f'\\cref{{{cref_text}}}')
        return ' and '.join(cref_parts)

    def replacement(match):
        chapter_ref = transform(match.group(1))
        crefs = match.group(2).split(' and ')
        cref_parts = cref_transform(crefs, chapter_ref)
        return f'\\cref{{{chapter_ref}}}, {cref_parts} of {match.group(3)}'

    def single_replacement(match):
        chapter_ref = transform(match.group(1))
        crefs = match.group(2).split(' and ')
        cref_parts = cref_transform(crefs, chapter_ref)
        return f'\\cref{{{chapter_ref}}}, {cref_parts}'

    text = re.sub(r"\\ChapterRef{(\\Chapter[^}]+), ((?:\\cref{[^}]+}(?: and )?)+)}{(\\cref{[^}]+})}", single_replacement, text)
    text = re.sub(r"\\ChapterRef{(\\Chapter[^}]+), ((?:\\cref{[^}]+}(?: and )?)+) of (\\cref{[^}]+})}{((?:\\cref{[^}]+}(?: and )?)+) of (\\cref{[^}]+})}", replacement, text)

    # Revised regex to specifically target \cref references with more than one colon
    # This regex looks for a \cref followed by a sequence that has at least two colons and captures the parts after the first colon
    #text = re.sub(r'\\cref{[^:]+:([^:]+:[^}]+)}', r'\\cref{\1}', text)

    def replace_inside_cref(match):
        inner_text = match.group(1)
        # This adjustment is to ensure no redundant \cref{} wrapping and correct handling of inner content
        if "\\cref" not in inner_text:
            return "\\cref{" + re.sub(r'([^:]+):([^:]+:[^}]+)', r'\2', inner_text) + "}"
        else:
            return inner_text

    text = re.sub(r'\\cref\{(.*?)\}', replace_inside_cref, text)
    #text = re.sub(r"\\ChapterRef{\\Chapter.*?,", r"", text)
    text = re.sub(r"\\ChapterRef{\\Chapter.*?, \\cref{(.*?):(.*?)} and \\cref{(.*?):(.*?)}}{\\cref{(.*?):(.*?)} and \\cref{(.*?):(.*?)}}", r"\\cref{\1:section-phantom}, \\cref{\1:\2} and \\cref{\3:\4}", text)
    return text

def regex_two(text):
    def modify_cref_line(line):
        pattern = r'(\\cref{)([^:}]*:)([^:}]*:[^:}]*)(})'
        def repl(match):
            return f'{match.group(1)}{match.group(3)}{match.group(4)}'
        return re.sub(pattern, repl, line)
    lines = text.splitlines()  # Split the text into lines
    modified_lines = [modify_cref_line(line) for line in lines]  # Apply modification to each line
    return "\n".join(modified_lines)  # Join the modified lines back together

def line_regex(line):
    """Replaces a complex ChapterRef pattern with a simplified version.

    Handles partial regex testing or full replacement based on test_partials.
    Converts chapter label to hyphenated lowercase in the replacement string,
    and removes 'chapter-' prefix.
    """

    def camel_case_to_hyphenated_lowercase(line):
        """Converts a CamelCase string to hyphenated lowercase."""
        s1 = re.sub('(.)([A-Z][a-z]+)', r'\1-\2', line)
        return re.sub('([a-z0-9])([A-Z])', r'\1-\2', s1).lower()

    def remove_chapter_prefix(line):
        """Removes 'chapter-' prefix and any leading hyphens."""
        return re.sub(r'\\-chapter-', '', line)

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
    line = line.replace(" ", " ")

    line = re.sub(full_pattern, replacement, line, flags=re.DOTALL)
    line = re.sub('','', line, flags=re.DOTALL)

    return line

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    modified_content = regex_one(content)
    modified_content = regex_two(modified_content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(modified_content)  # Write the modified content back to the file

    with open(filepath, 'r', encoding='utf-8') as f_in, open("temp_modified_book.tex", 'w', encoding='utf-8') as f_out:
        for line_num, line in enumerate(f_in, 1):
            modified_line = line_regex(line)  # Apply full regex
            f_out.write(modified_line)
        os.replace("temp_modified_book.tex", filepath)
