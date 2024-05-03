import re
import sys

def replace_multichapter_cref_further_revised(text):
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

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    content = replace_multichapter_cref_further_revised(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
