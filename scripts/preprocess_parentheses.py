# Author: GPT4
import re
import sys

def transform_math_mode(content):
    # Pattern to find math mode expressions including inline math mode with single $
    # and extended to include various LaTeX math environments
    math_mode_pattern = re.compile(
        r'\$\$.*?\$\$|\\\\\[.*?\\\\\]|\\$.*?\\$|\\\\begin\{(?:align\*?|equation\*?|gather\*?|multline\*?)\}.*?\\\\end\{(?:align\*?|equation\*?|gather\*?|multline\*?)\}',
        re.DOTALL
    )

    def replace_parentheses(match):
        # Replace ( and ) with \\left( and \\right) inside math mode expressions
        expression = match.group(0)
        expression = expression.replace('[', '\\\\left[')
        expression = expression.replace(']', '\\\\right]')
        expression = expression.replace('(', '\\\\left(')
        expression = expression.replace(')', '\\\\right)')
        return expression

    # Replace parentheses in all math mode expressions found
    return math_mode_pattern.sub(replace_parentheses, content)

def main(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    transformed_content = transform_math_mode(content)

    with open(input_file, 'w') as f:
        f.write(transformed_content)

if __name__ == "__main__":
    main(sys.argv[1])
