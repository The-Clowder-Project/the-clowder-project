import re, sys

def extract_content_parts(content):
    # Regex pattern with 3 capturing groups
    pattern = r"(.*?)\\begin{document}(.*?)\\end{document}(.*)"
    match = re.search(pattern, content, re.DOTALL)  # DOTALL makes '.' match newlines
    if match:
        return [match.group(1), match.group(2)]
    else:
        return None

def segment_latex_math(input_text):
    math_mode_pattern = re.compile(
        r'(\$\$?.*?\$\$?|\\\[.*?\\\]|\\begin\{equation\}.*?\\end\{equation\}|'
        r'\\begin\{align\}.*?\\end\{align\}|\\begin\{align\*\}.*?\\end\{align\*\}|'
        r'\\begin\{aligned\}.*?\\end\{aligned\}|'
        r'\\begin\{gather\}.*?\\end\{gather\}|\\begin\{gather\*\}.*?\\end\{gather\*\}|'
        r'\\begin\{webcompile\}.*?\\end\{webcompile\}|'
        r'\\begin\{gathered\}.*?\\end\{gathered\})',
        re.DOTALL)
    return segment_generic(input_text, math_mode_pattern, True)

def segment_latex_text(input_text):
    #text_pattern = re.compile(r'(\\text\{.*?(?:\{.*?\}.*?)*?\}|\\begin\{tikzcd\}.*?\\end\{tikzcd\})',re.DOTALL)
    text_pattern = re.compile(r'(\\text\{.*?(?:\{.*?\}.*?)*?\})',re.DOTALL)
    return segment_generic(input_text, text_pattern, False)

def segment_generic(input_text, pattern, is_math):
    segments = []
    last_end = 0
    for match in pattern.finditer(input_text):
        start, end = match.span()
        if start > last_end:
            segments.append((input_text[last_end:start], not is_math))
        segments.append((match.group(0) if is_math else match.group(1), is_math))
        last_end = end
    if last_end < len(input_text):
        segments.append((input_text[last_end:], not is_math))
    return segments

def segment_recursively(segments, segment_function):
    new_segments = []
    for segment, is_math in segments:
        # Apply segmentation only to non-math/text segments
        if not is_math and segment_function == segment_latex_math or is_math and segment_function == segment_latex_text:
            new_segments.extend(segment_function(segment))
        else:
            new_segments.append((segment, is_math))
    # Check if new segmentation occurred
    if new_segments != segments:
        # Alternate between math and text segmentation
        next_function = segment_latex_text if segment_function == segment_latex_math else segment_latex_math
        return segment_recursively(new_segments, next_function)
    else:
        return new_segments

def regex_parentheses(content):
    # Pattern to match the specified keywords followed by '(' or ')' or just '(' or ')' not preceded by '\'
    pattern = r'(\\big|\\Big|\\bigg|\\Bigg|\\left|\\right|\\pig|\\Pig|\\pigg|\\Pigg|\\noregex)?(?<!\\)([\(\)])'
    def replacement(match):
        # If the match includes a keyword, return the entire match (no replacement needed)
        if match.group(1):
            return match.group(0)
        # Otherwise, replace '(' with '\left(' and ')' with '\right)'
        elif match.group(2) == '(':
            return r'\left('
        else:
            return r'\right)'
    # Use the replacement function to conditionally replace the matches
    return re.sub(pattern, replacement, content)

def regex_square_brackets(content):
    # Step 1: Replace '[' and ']' not preceded by '\' with '\left[' and '\right]'
    content = re.sub(r'(?<!includegraphics)(?<!clowder-project\/tag\/....}{....}}})(?<!\\&)(?<!index)(?<!\\)\[', r'\\left[', content)
    content = re.sub(r'(?<!CmPlusOneEighth)(?<!CmPlusThreeQuarters)(?<!CmPlusAQuarter)(?<!CmPlusHalf)(?<!Cm)(?<!algebra)(?<!notation)(?<!representation-theory)(?<!higher-categories)(?<!categories)(?<!set-theory)(?<!baselineskip)(?<!\\)\]', r'\\right]', content)

    # Step 2: Revert replacements for specific keywords
    keywords = ['big', 'bigg', 'Big', 'pig', 'pigg', 'Pig', 'Pigg', 'noregex', 'left', 'right']
    for keyword in keywords:
        content = re.sub(r'\\' + keyword + r'\\left\[', r'\\' + keyword + r'[', content)
        content = re.sub(r'\\' + keyword + r'\\right\]', r'\\' + keyword + r']', content)
    return content

def regex_curly_braces(content):
    # Match either the keywords followed by \{ or \}, or standalone \{ or \}
    pattern = r'(\\(?:big|bigg|Big|left|right|pig|pigg|Pig|Pigg|noregex)\s*\\[{}])|\\([{}])'

    def repl(match):
        # If the first group is matched, it means we have a keyword followed by \{ or \}
        # In this case, we return the match unchanged
        if match.group(1):
            return match.group(1)
        # If the second group is matched, it means we have a standalone \{ or \}
        # In this case, we replace \{ with \left\{ and \} with \right\}
        else:
            char = match.group(2)
            if char == '{':
                return r'\\left\{'
            elif char == '}':
                return r'\\right\}'
    return re.sub(pattern, repl, content)

def regex_exceptions(content):
    # includegraphics replacement
    content = re.sub(r"\\includegraphics\\left\[(.*?)\\right\]", r"\\includegraphics[\1]", content)

    # \begin{tikzcd} replacement
    content = re.sub(r"\\begin\{tikzcd\}\\left\[(.*?)\\right\]", r"\\begin{tikzcd}[\1]", content)
    # \arrow[] replacement
    content = re.sub(r'\\arrow\\left\[(.*?)\\right\]\n', r'\\arrow[\1]\n', content)
    content = re.sub(r'\\arrow\\left\[(.*?)\\right\]%\n', r'\\arrow[\1]%\n', content)
    content = re.sub(r'\\arrow\\left\[(.*?)\\right\]\\&', r'\\arrow[\1]\\&', content)
    content = re.sub(r'\\arrow\\left\[(.*?)\\right\]\\end{tikzcd}', r'\\arrow[\1]\\end{tikzcd}', content)
    content = re.sub(r'\\arrow\\left\[(.*?)\]\\end{tikzcd}', r'\\arrow[\1]\\end{tikzcd}', content)
    content = re.sub(r'\\arrow\\left\[(.*?)\\right\]\\arrow', r'\\arrow[\1]\\arrow', content)
    content = re.sub(r'\\arrow\[(.*?)\\right\]\\arrow', r'\\arrow[\1]\\arrow', content)
    content = re.sub(r'\\arrow\[(.*?)\\right\]\\arrow', r'\\arrow[\1]\\arrow', content)
    # Step 2: \\[length]
    content = re.sub(r'\\\\\\left\[(.*?)\\right\]\n', r'\\\\[\1]\n', content)
    content = re.sub(r'\\\\\[(.*?)\\right\]\n', r'\\\\[\1]\n', content)
    content = re.sub(r'\\&\\left\[(.*?)\\right\]\n', r'\\&[\1]\n', content)
    content = re.sub(r'\[(.*?)Cm\\right\]', r'[\1Cm]', content)
    content = re.sub(r'\[(.*?)Quarter\\right\]', r'[\1Quarter]', content)
    content = re.sub(r'\[(.*?)DL\\right\]', r'[\1DL]', content)
    content = re.sub(r'\\left\[(.*?)DL\]', r'[\1DL]', content)
    content = re.sub(r'([0-9])pt\\right\]', r'\1pt]', content)
    content = re.sub(r'([0-9])em\\right\]', r'\1em]', content)
    content = re.sub(r'\\left\[xshift', r'[xshift', content)
    # Should be applied last
    content = re.sub(r'\\arrow\\left\[', r'\\arrow[', content)
    return content

def regex_tikzcd_arrow(content):
    return content

def main(input_file):
    # Step 1: Read file
    with open(input_file, 'r') as f:
        content = f.read()
    # Step 2: Extract preamble and document parts
    parts = extract_content_parts(content)
    preamble = parts[0] + r"\begin{document}"
    # Step 3: Segment math and text
    document = parts[1] + r"\end{document}"
    initial_segments = [(document, False)]
    final_segments = segment_recursively(initial_segments, segment_latex_math)
    # Step 4: Regex math
    regexed = []
    for segment in final_segments:
        regexed.append(list(segment))
    for segment in regexed:
        if segment[1] == True:
            segment[0] = regex_parentheses(segment[0])
            segment[0] = regex_square_brackets(segment[0])
            segment[0] = regex_exceptions(segment[0])
            segment[0] = regex_curly_braces(segment[0])
    # Step 5: Put things together again
    content = preamble
    for segment in regexed:
        content += segment[0]
    # Step 6: Write back
    with open(input_file, 'w') as f:
        f.write(content)
if __name__ == "__main__":
    main(sys.argv[1])
## Author: GPT4 \o/
#import re, sys
#
#def transform_parentheses_v37(text):
#    # Patterns to check before open and close parentheses
#    preceding_patterns = ["\\left", "\\right", "\\big", "\\bigg", "\\Big", "\\Bigg", "\\pig", "\\pigg", "\\Pig", "\\Pigg", "\\norg", ]
#    
#    # Helper function to transform a segment in math mode
#    def transform_math_mode_segment(segment):
#        i = 0
#        transformed_segment = []
#        while i < len(segment):
#            char = segment[i]
#            if char == "(":
#                # Check if the preceding sequence matches any of the patterns
#                preceding = segment[max(i-6, 0):i]
#                if not any(pattern in preceding for pattern in preceding_patterns):
#                    transformed_segment.append("\\left(")
#                else:
#                    transformed_segment.append(char)
#            elif char == ")":
#                # Check if the preceding sequence matches any of the patterns
#                preceding = segment[max(i-6, 0):i]
#                if not any(pattern in preceding for pattern in preceding_patterns):
#                    transformed_segment.append("\\right)")
#                else:
#                    transformed_segment.append(char)
#            else:
#                transformed_segment.append(char)
#            i += 1
#        return ''.join(transformed_segment)
#    
#    # Split the content into segments based on math mode demarcations
#    # Added patterns to match \begin{align*}...\end{align*} and \begin{gather*}...\end{gather*}
#    segments = re.split(r'(\$[^\$]*\$|\\\[[^\]]*\\\]|\\\([^\)]*\\\)|\\begin{align\*}.*?\\end{align\*}|\\begin{gather\*}.*?\\end{gather\*})', text, flags=re.DOTALL)
#    
#    # Transform only the math mode segments
#    for i, segment in enumerate(segments):
#        if (segment.startswith("$") or segment.startswith("\\[") or segment.startswith("\\(") or 
#            segment.startswith("\\begin{align*}") or segment.startswith("\\begin{gather*}")):
#            segments[i] = transform_math_mode_segment(segment)
#    
#    # Reassemble the transformed text
#    transformed_text = ''.join(segments)
#    return transformed_text
#
## Sample usage:
## input_text = "..."  # Your LaTeX content
## transformed_text = transform_parentheses_v37(input_text)
## print(transformed_text)
#def main(input_file):
#    with open(input_file, 'r') as f:
#        content = f.read()
#
#    transformed_content = transform_parentheses_v37(content)
#
#    with open(input_file, 'w') as f:
#        f.write(transformed_content)
#
#if __name__ == "__main__":
#    main(sys.argv[1])
