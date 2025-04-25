# Author: GPT4 \o/
import os, re, sys, subprocess, hashlib, concurrent.futures, shutil

# Function to compare file with its backup
def has_file_changed(output_dir, filename, content):
    backup_filename = f"{filename}.bak"
    file = os.path.join(output_dir, backup_filename)
    path = output_dir + "/" + backup_filename
    # Check if backup file exists
    if os.path.exists(path):
        # Read the backup file content
        with open(file, 'r') as f:
            backup_content = f.read()
        # Compare current content with backup content
        return content != backup_content
    else:
        # No backup file means the file is considered changed
        return True

# The modified scalemath function using checksums for persistence
def scalemath(output_dir, scalemath_environments):
    with concurrent.futures.ThreadPoolExecutor(max_workers=12) as executor:
        futures = []
        for i in range(len(scalemath_environments)):
            filename = f'scalemath-{i:06d}.tex'
            file = os.path.join(output_dir, f'scalemath-{i:06d}.tex')
            with open(file, 'r') as f:
                content = f.read()
            if has_file_changed(output_dir, filename, content):
                future = executor.submit(compile_tex, output_dir, filename)
                futures.append(future)
        concurrent.futures.wait(futures)

# The modified webcompile function using checksums for persistence
def webcompile(output_dir, webcompile_environments):
    with concurrent.futures.ThreadPoolExecutor(max_workers=12) as executor:
        futures = []
        for i in range(len(webcompile_environments)):
            filename = f'webcompile-{i:06d}.tex'
            file = os.path.join(output_dir, f'webcompile-{i:06d}.tex')
            with open(file, 'r') as f:
                content = f.read()
            if has_file_changed(output_dir, filename, content):
                future = executor.submit(compile_tex, output_dir, filename)
                futures.append(future)
        concurrent.futures.wait(futures)

# The modified compile_tikzcd function using direct file content comparison
def compile_tikzcd(output_dir, tikzcd_environments):
    with concurrent.futures.ThreadPoolExecutor(max_workers=12) as executor:
        futures = []
        for i in range(len(tikzcd_environments)):
            filename = f'tikzcd-{i:06d}.tex'
            file = os.path.join(output_dir, f'tikzcd-{i:06d}.tex')
            with open(file, 'r') as f:
                content = f.read()
            if has_file_changed(output_dir, filename, content):
                future = executor.submit(compile_tex, output_dir, filename)
                futures.append(future)
        concurrent.futures.wait(futures)

def regex(filename):
    with open(filename, 'r') as file:
        content = file.read()
    content = re.sub(r'<div class="scriptsize">',r'\\begingroup\\scriptsize',content)
    content = re.sub(r'</div',r'\\endgroup',content)
    with open(filename, 'w') as file:
        file.write(content)

def compile_tex(output_dir, filename):
    print(f"Compiling {filename} with lualatex...")

    result = subprocess.run(['lualatex', filename], cwd=output_dir, capture_output=True, text=True)
    print("filename:"+str(filename))
    print("RESULT STDOUT:")
    print(result.stdout)
    print("RESULT STDERR:")
    print(result.stderr)
    if result.returncode != 0:
        print(f"Error compiling {filename}.")
        return
    
    base_name = os.path.splitext(filename)[0]
    filename_pdf = base_name + '.pdf'
    filename_svg = base_name + '.svg'
    
    result = subprocess.run(['pdf2svg', filename_pdf, filename_svg], cwd=output_dir)
    if result.returncode != 0:
        print(f"Error running pdf2svg for {filename}.")
    return filename

def main(input_file):
    # SCALEMATH
    output_dir_scalemath           = '../the-clowder-project/tmp/scalemath'
    output_dir_scalemath_dark_mode = '../the-clowder-project/tmp/scalemath/dark-mode'

    # Regular expression pattern to find scalemath environments
    pattern = re.compile(r'\\begin\{scalemath\}(.*?)\\end\{scalemath\}', re.DOTALL)

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # Extract scalemath environments and store them in a list
    scalemath_environments = pattern.findall(content)

    # Replace scalemath environments in the content
    for i, environment in enumerate(scalemath_environments):
        img_tag = f'<div class="scalemath"><img src="/static/scalemath-images/scalemath-{i:06d}.svg"></div>'
        content = pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Check if the output directory exists, if not create it
    os.makedirs(output_dir_scalemath, exist_ok=True)
    os.makedirs(output_dir_scalemath_dark_mode, exist_ok=True)

    # Write each scalemath environment to a separate file
    for i, environment in enumerate(scalemath_environments):
        filename = os.path.join(output_dir_scalemath, f'scalemath-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write("\\documentclass[varwidth]{standalone}\n")
            file.write(f"\\input{{../../tikzcd-preamble.tex}}\n")
            file.write("\\usepackage[libertine]{newtxmath}")
            file.write("\\setmainfont[Path = ../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.ttf},BoldFont={AlegreyaSans-Bold.ttf},ItalicFont={AlegreyaSans-Italic.ttf},BoldItalicFont={AlegreyaSans-BoldItalic.ttf}]{AlegreyaSans}")
            file.write("\\let\\mathrm\\relax")
            file.write("\\newcommand{\\mathrm}[1]{\\text{#1}}")
            file.write("\\begingroup")
            file.write("\\catcode`(\\active \\xdef({\\left\\string(}")
            file.write("\\catcode`)\\active \\xdef){\\right\\string)}")
            file.write("\\catcode`[\\active \\xdef[{\\left\\string[}")
            file.write("\\catcode`]\\active \\xdef]{\\right\\string]}")
            file.write("\\endgroup")
            file.write("\\mathcode`(=\"8000")
            file.write("\\mathcode`)=\"8000")
            file.write("\\mathcode`[=\"8000")
            file.write("\\mathcode`]=\"8000")
            file.write("\\begin{document}\n")
            file.write("\\begin{scalemath}%")
            environment = re.sub("\n\n","\n",environment)
            file.write(environment)
            file.write("\\end{scalemath}\n")
            file.write("\\end{document}\n")
        regex(filename)
    # Write each dark-mode scalemath environment to a separate file
    for i, environment in enumerate(scalemath_environments):
        filename = os.path.join(output_dir_scalemath_dark_mode, f'scalemath-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write("\\documentclass[varwidth]{standalone}\n")
            file.write(f"\\input{{../../../tikzcd-preamble.tex}}\n")
            file.write("\\usepackage[libertine]{newtxmath}")
            file.write("\\setmainfont[Path = ../../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.ttf},BoldFont={AlegreyaSans-Bold.ttf},ItalicFont={AlegreyaSans-Italic.ttf},BoldItalicFont={AlegreyaSans-BoldItalic.ttf}]{AlegreyaSans}")
            file.write("\\let\\mathrm\\relax")
            file.write("\\newcommand{\\mathrm}[1]{\\text{#1}}")
            file.write("\\color{white}")
            file.write("\\definecolor{grayEnv}{RGB}{52,53,65}")
            file.write("\\colorlet{backgroundColor}{grayEnv}")
            file.write("\\begingroup")
            file.write("\\catcode`(\\active \\xdef({\\left\\string(}")
            file.write("\\catcode`)\\active \\xdef){\\right\\string)}")
            file.write("\\catcode`[\\active \\xdef[{\\left\\string[}")
            file.write("\\catcode`]\\active \\xdef]{\\right\\string]}")
            file.write("\\endgroup")
            file.write("\\mathcode`(=\"8000")
            file.write("\\mathcode`)=\"8000")
            file.write("\\mathcode`[=\"8000")
            file.write("\\mathcode`]=\"8000")
            file.write("\\begin{document}\n")
            file.write("\\[%")
            environment = re.sub("\n\n","\n",environment)
            environment = re.sub("/pictures/light-mode","/pictures/dark-mode",environment)
            environment = re.sub("gray!40","gray!80!black",environment)
            file.write(environment)
            file.write("\\]\n")
            file.write("\\end{document}\n")
        regex(filename)
    scalemath(output_dir_scalemath,scalemath_environments)
    scalemath(output_dir_scalemath_dark_mode,scalemath_environments)
    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)
    # Make backups
    for i, environment in enumerate(scalemath_environments):
        filename = os.path.join(output_dir_scalemath_dark_mode, f'scalemath-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
        filename = os.path.join(output_dir_scalemath, f'scalemath-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")

    print(f"Processed {len(scalemath_environments)} scalemath environments.")

    # WEBCOMPILE
    output_dir_webcompile           = '../the-clowder-project/tmp/webcompile'
    output_dir_webcompile_dark_mode = '../the-clowder-project/tmp/webcompile/dark-mode'

    # Regular expression pattern to find webcompile environments
    pattern = re.compile(r'\\begin\{webcompile\}(.*?)\\end\{webcompile\}', re.DOTALL)

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # Extract webcompile environments and store them in a list
    webcompile_environments = pattern.findall(content)

    # Replace webcompile environments in the content
    for i, environment in enumerate(webcompile_environments):
        img_tag = f'<div class="webcompile"><img src="/static/webcompile-images/webcompile-{i:06d}.svg"></div>'
        content = pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Check if the output directory exists, if not create it
    os.makedirs(output_dir_webcompile, exist_ok=True)
    os.makedirs(output_dir_webcompile_dark_mode, exist_ok=True)

    # Write each webcompile environment to a separate file
    for i, environment in enumerate(webcompile_environments):
        filename = os.path.join(output_dir_webcompile, f'webcompile-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write("\\documentclass[varwidth]{standalone}\n")
            file.write(f"\\input{{../../tikzcd-preamble.tex}}\n")
            file.write("\\usepackage[libertine]{newtxmath}")
            file.write("\\setmainfont[Path = ../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.ttf},BoldFont={AlegreyaSans-Bold.ttf},ItalicFont={AlegreyaSans-Italic.ttf},BoldItalicFont={AlegreyaSans-BoldItalic.ttf}]{AlegreyaSans}")
            file.write("\\let\\mathrm\\relax")
            file.write("\\newcommand{\\mathrm}[1]{\\text{#1}}")
            file.write("\\begingroup")
            file.write("\\catcode`(\\active \\xdef({\\left\\string(}")
            file.write("\\catcode`)\\active \\xdef){\\right\\string)}")
            file.write("\\catcode`[\\active \\xdef[{\\left\\string[}")
            file.write("\\catcode`]\\active \\xdef]{\\right\\string]}")
            file.write("\\endgroup")
            file.write("\\mathcode`(=\"8000")
            file.write("\\mathcode`)=\"8000")
            file.write("\\mathcode`[=\"8000")
            file.write("\\mathcode`]=\"8000")
            file.write("\\begin{document}\n")
            file.write("\\[%")
            environment = re.sub("\n\n","\n",environment)
            file.write(environment)
            file.write("\\]\n")
            file.write("\\end{document}\n")
        regex(filename)
    # Write each dark-mode webcompile environment to a separate file
    for i, environment in enumerate(webcompile_environments):
        filename = os.path.join(output_dir_webcompile_dark_mode, f'webcompile-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write("\\documentclass[varwidth]{standalone}\n")
            file.write(f"\\input{{../../../tikzcd-preamble.tex}}\n")
            file.write("\\usepackage[libertine]{newtxmath}")
            file.write("\\setmainfont[Path = ../../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.ttf},BoldFont={AlegreyaSans-Bold.ttf},ItalicFont={AlegreyaSans-Italic.ttf},BoldItalicFont={AlegreyaSans-BoldItalic.ttf}]{AlegreyaSans}")
            file.write("\\let\\mathrm\\relax")
            file.write("\\newcommand{\\mathrm}[1]{\\text{#1}}")
            file.write("\\color{white}")
            file.write("\\definecolor{grayEnv}{RGB}{52,53,65}")
            file.write("\\colorlet{backgroundColor}{grayEnv}")
            file.write("\\begingroup")
            file.write("\\catcode`(\\active \\xdef({\\left\\string(}")
            file.write("\\catcode`)\\active \\xdef){\\right\\string)}")
            file.write("\\catcode`[\\active \\xdef[{\\left\\string[}")
            file.write("\\catcode`]\\active \\xdef]{\\right\\string]}")
            file.write("\\endgroup")
            file.write("\\mathcode`(=\"8000")
            file.write("\\mathcode`)=\"8000")
            file.write("\\mathcode`[=\"8000")
            file.write("\\mathcode`]=\"8000")
            file.write("\\begin{document}\n")
            file.write("\\[%")
            environment = re.sub("\n\n","\n",environment)
            environment = re.sub("/pictures/light-mode","/pictures/dark-mode",environment)
            environment = re.sub("gray!40","gray!80!black",environment)
            file.write(environment)
            file.write("\\]\n")
            file.write("\\end{document}\n")
        regex(filename)
    webcompile(output_dir_webcompile,webcompile_environments)
    webcompile(output_dir_webcompile_dark_mode,webcompile_environments)
    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)
    # Make backups
    for i, environment in enumerate(webcompile_environments):
        filename = os.path.join(output_dir_webcompile_dark_mode, f'webcompile-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
        filename = os.path.join(output_dir_webcompile, f'webcompile-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")

    print(f"Processed {len(webcompile_environments)} webcompile environments.")

    # TIKZ-CD
    output_dir           = '../the-clowder-project/tmp/tikz-cd'
    output_dir_dark_mode = '../the-clowder-project/tmp/tikz-cd/dark-mode'

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # First, let's identify and temporarily replace verbatim environments
    verbatim_pattern = re.compile(r'\\begin\{verbatim\}(.*?)\\end\{verbatim\}', re.DOTALL)
    verbatim_blocks = verbatim_pattern.findall(content)
    for i, block in enumerate(verbatim_blocks):
        placeholder = f"VERBATIM_PLACEHOLDER_{i}_END"
        content = content.replace(f"\\begin{{verbatim}}{block}\\end{{verbatim}}", placeholder)

    # Regular expression pattern to find tikzcd environments
    pattern = re.compile(r'\\begin\{tikzcd\}(.*?)\\end\{tikzcd\}', re.DOTALL)

    # Extract tikzcd environments and store them in a list
    tikzcd_environments = pattern.findall(content)

    # Replace tikzcd environments in the content
    for i, environment in enumerate(tikzcd_environments):
        img_tag = f'<div class="tikz-cd"><img src="/static/tikzcd-images/tikzcd-{i:06d}.svg"></div>'
        content = pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Check if the output directory exists, if not create it
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(output_dir_dark_mode, exist_ok=True)

    # Restore verbatim environments
    for i, block in enumerate(verbatim_blocks):
        placeholder = f"VERBATIM_PLACEHOLDER_{i}_END"
        content = content.replace(placeholder, f"\\begin{{verbatim}}{block}\\end{{verbatim}}")

    # Write each tikzcd environment to a separate file
    for i, environment in enumerate(tikzcd_environments):
        filename = os.path.join(output_dir, f'tikzcd-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write("\\documentclass{standalone}\n")
            file.write(f"\\input{{../../tikzcd-preamble.tex}}\n")
            file.write("\\usepackage[libertine]{newtxmath}")
            file.write("\\setmainfont[Path = ../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.ttf},BoldFont={AlegreyaSans-Bold.ttf},ItalicFont={AlegreyaSans-Italic.ttf},BoldItalicFont={AlegreyaSans-BoldItalic.ttf}]{AlegreyaSans}")
            file.write("\\let\\mathrm\\relax")
            file.write("\\newcommand{\\mathrm}[1]{\\text{#1}}")
            file.write("\\begingroup")
            file.write("\\catcode`(\\active \\xdef({\\left\\string(}")
            file.write("\\catcode`)\\active \\xdef){\\right\\string)}")
            file.write("\\catcode`[\\active \\xdef[{\\left\\string[}")
            file.write("\\catcode`]\\active \\xdef]{\\right\\string]}")
            file.write("\\endgroup")
            file.write("\\mathcode`(=\"8000")
            file.write("\\mathcode`)=\"8000")
            file.write("\\mathcode`[=\"8000")
            file.write("\\mathcode`]=\"8000")
            file.write("\\begin{document}\n")
            file.write("\\begin{tikzcd}%\n")
            environment = re.sub("\n\n","\n",environment)
            file.write(environment)
            file.write("\\end{tikzcd}\n")
            file.write("\\end{document}\n")
        regex(filename)
    # Write each tikzcd dark-mode environment to a separate file
    for i, environment in enumerate(tikzcd_environments):
        filename = os.path.join(output_dir_dark_mode, f'tikzcd-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write("\\documentclass{standalone}\n")
            file.write(f"\\input{{../../../tikzcd-preamble.tex}}\n")
            file.write("\\usepackage[libertine]{newtxmath}")
            file.write("\\setmainfont[Path = ../../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.ttf},BoldFont={AlegreyaSans-Bold.ttf},ItalicFont={AlegreyaSans-Italic.ttf},BoldItalicFont={AlegreyaSans-BoldItalic.ttf}]{AlegreyaSans}")
            file.write("\\let\\mathrm\\relax")
            file.write("\\newcommand{\\mathrm}[1]{\\text{#1}}")
            file.write("\\color{white}")
            file.write("\\definecolor{grayEnv}{RGB}{52,53,65}")
            file.write("\\colorlet{backgroundColor}{grayEnv}")
            file.write("\\begingroup")
            file.write("\\catcode`(\\active \\xdef({\\left\\string(}")
            file.write("\\catcode`)\\active \\xdef){\\right\\string)}")
            file.write("\\catcode`[\\active \\xdef[{\\left\\string[}")
            file.write("\\catcode`]\\active \\xdef]{\\right\\string]}")
            file.write("\\endgroup")
            file.write("\\mathcode`(=\"8000")
            file.write("\\mathcode`)=\"8000")
            file.write("\\mathcode`[=\"8000")
            file.write("\\mathcode`]=\"8000")
            file.write("\\begin{document}\n")
            file.write("\\begin{tikzcd}%\n")
            environment = re.sub("\n\n","\n",environment)
            environment = re.sub("gray!40","gray!80!black",environment)
            file.write(environment)
            file.write("\\end{tikzcd}\n")
            file.write("\\end{document}\n")
        regex(filename)

    compile_tikzcd(output_dir,tikzcd_environments)
    compile_tikzcd(output_dir_dark_mode,tikzcd_environments)
    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)
    # Make backups
    for i, environment in enumerate(tikzcd_environments):
        filename = os.path.join(output_dir, f'tikzcd-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
        filename = os.path.join(output_dir_dark_mode, f'tikzcd-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")

    print(f"Processed {len(tikzcd_environments)} tikzcd environments.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)
    main(sys.argv[1])
