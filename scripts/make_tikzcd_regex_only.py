import os, re, sys, subprocess
import concurrent.futures

def main(input_file):
    output_dir_webcompile           = '../the-clowder-project/tmp/webcompile'
    output_dir_webcompile_dark_mode = '../the-clowder-project/tmp/webcompile/dark-mode'

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # First, identify and temporarily replace verbatim environments
    verbatim_pattern = re.compile(r'\\begin\{verbatim\}(.*?)\\end\{verbatim\}', re.DOTALL)
    verbatim_blocks = verbatim_pattern.findall(content)
    for i, block in enumerate(verbatim_blocks):
        placeholder = f"VERBATIM_PLACEHOLDER_{i}_END"
        content = content.replace(f"\\begin{{verbatim}}{block}\\end{{verbatim}}", placeholder)

    # Identify and temporarily replace RAW HTML blocks
    raw_html_pattern = re.compile(r'% BEGIN RAW HTML %(.*?)% END RAW HTML %', re.DOTALL)
    raw_html_blocks = raw_html_pattern.findall(content)
    for i, block in enumerate(raw_html_blocks):
        placeholder = f"RAW_HTML_PLACEHOLDER_{i}_END"
        content = content.replace(f"% BEGIN RAW HTML %{block}% END RAW HTML %", placeholder)

    # Process scalemath environments
    scalemath_pattern = re.compile(r'\\begin\{scalemath\}(.*?)\\end\{scalemath\}', re.DOTALL)
    scalemath_environments = scalemath_pattern.findall(content)
    for i, environment in enumerate(scalemath_environments):
        img_tag = f'\\scalemath{{{i:06d}}}'
        content = scalemath_pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Process webcompile environments
    webcompile_pattern = re.compile(r'\\begin\{webcompile\}(.*?)\\end\{webcompile\}', re.DOTALL)
    webcompile_environments = webcompile_pattern.findall(content)
    for i, environment in enumerate(webcompile_environments):
        img_tag = f'\\webcompile{{{i:06d}}}'
        content = webcompile_pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Process tikzcd environments
    tikzcd_pattern = re.compile(r'\\begin\{tikzcd\}(.*?)\\end\{tikzcd\}', re.DOTALL)
    tikzcd_environments = tikzcd_pattern.findall(content)
    for i, environment in enumerate(tikzcd_environments):
        img_tag = r'\\'+f'tikzcdid{{{i:06d}}}'
        content = tikzcd_pattern.sub(img_tag, content, 1)  # Replace only the first occurrence
    content = re.sub(r"\\\[\s*\\tikzcdid\{(\d+)\}\s*\\\]%", r"\\tikzcdid{\1}", content)

    # Restore RAW HTML blocks
    for i, block in enumerate(raw_html_blocks):
        placeholder = f"RAW_HTML_PLACEHOLDER_{i}_END"
        content = content.replace(placeholder, f"% BEGIN RAW HTML %{block}% END RAW HTML %")

    # Restore verbatim environments
    for i, block in enumerate(verbatim_blocks):
        placeholder = f"VERBATIM_PLACEHOLDER_{i}_END"
        content = content.replace(placeholder, f"\\begin{{verbatim}}{block}\\end{{verbatim}}")

    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)

    print(f"Processed {len(webcompile_environments)} webcompile environments.")
    print(f"Processed {len(tikzcd_environments)} tikzcd environments.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)
    main(sys.argv[1])
