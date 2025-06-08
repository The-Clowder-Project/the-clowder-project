import os, re, sys, subprocess, hashlib, concurrent.futures, shutil

def clear_lua_cache():
    subprocess.run(['luaotfload-tool', '--cache=erase'])
    return True

def get_preamble(IS_DARK_MODE):
    preamble = ""
    preamble += "\\documentclass[varwidth]{standalone}\n"
    # Get TikZ preamble
    if IS_DARK_MODE:
        preamble += f"\\input{{../../../preamble/compiled/preamble-tikzcd.tex}}\n"
    else:
        preamble += f"\\input{{../../preamble/compiled/preamble-tikzcd.tex}}\n"
    preamble += "\\usepackage[libertine]{newtxmath}"
    # Set font
    if IS_DARK_MODE:
        preamble += "\\setmainfont[Path = ../../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.otf},BoldFont={AlegreyaSans-Bold.otf},ItalicFont={AlegreyaSans-Italic.otf},BoldItalicFont={AlegreyaSans-BoldItalic.otf}]{AlegreyaSans}"
    else:
        preamble += "\\setmainfont[Path = ../../fonts/alegreya-sans/,Ligatures=TeX,UprightFont={AlegreyaSans-Regular.otf},BoldFont={AlegreyaSans-Bold.otf},ItalicFont={AlegreyaSans-Italic.otf},BoldItalicFont={AlegreyaSans-BoldItalic.otf}]{AlegreyaSans}"
    # Set background color
    if IS_DARK_MODE:
        preamble += "\\definecolor{tikzBackgroundColor}{RGB}{52,53,65}"
        preamble += "\\colorlet{backgroundColor}{tikzBackgroundColor}"
        preamble += "\\usepackage{pagecolor}"
        preamble += "\\pagecolor{backgroundColor}"
        preamble += "\\color{white}"
    else:
        preamble += "\\definecolor{tikzBackgroundColor}{RGB}{242,242,242}"
        preamble += "\\colorlet{backgroundColor}{tikzBackgroundColor}"
    preamble += "\\let\\mathrm\\relax"
    preamble += "\\newcommand{\\mathrm}[1]{\\text{#1}}"
    preamble += "\\begingroup"
    preamble += "\\catcode`(\\active \\xdef({\\left\\string(}"
    preamble += "\\catcode`)\\active \\xdef){\\right\\string)}"
    preamble += "\\catcode`[\\active \\xdef[{\\left\\string[}"
    preamble += "\\catcode`]\\active \\xdef]{\\right\\string]}"
    preamble += "\\endgroup"
    preamble += "\\mathcode`(=\"8000"
    preamble += "\\mathcode`)=\"8000"
    preamble += "\\mathcode`[=\"8000"
    preamble += "\\mathcode`]=\"8000"
    return preamble

# Function to compare file with its backup
def has_file_changed(output_dir, filename, content):
    backup_filename_ext = f"{filename}.bak"  # e.g., 'scalemath-000000.tex.bak'
    # 'filename' is the base name of the .tex file, e.g., 'scalemath-000000.tex'
    
    backup_file_full_path = os.path.join(output_dir, backup_filename_ext)
    
    # Check if backup file exists
    if os.path.exists(backup_file_full_path):
        # Read the backup file content
        try:
            with open(backup_file_full_path, 'r') as f:
                backup_content = f.read()
            # Compare current content with backup content
            return content != backup_content
        except Exception as e:
            print(f"Warning: Could not read backup file {backup_file_full_path}: {e}")
            return True # Treat as changed if backup is unreadable
    else:
        # No backup file means the file is considered changed
        return True

def scalemath(output_dir, scalemath_environments):
    with concurrent.futures.ThreadPoolExecutor(max_workers=12) as executor:
        futures = []
        for i in range(len(scalemath_environments)):
            filename = f'scalemath-{i:06d}.tex'
            file_path = os.path.join(output_dir, filename) # Use a distinct variable name
            try:
                with open(file_path, 'r') as f:
                    content = f.read()
                if has_file_changed(output_dir, filename, content):
                    future = executor.submit(compile_tex, output_dir, filename)
                    futures.append(future)
            except IOError as e:
                print(f"Error reading {file_path} in scalemath function: {e}")
        concurrent.futures.wait(futures)

def webcompile(output_dir, webcompile_environments):
    with concurrent.futures.ThreadPoolExecutor(max_workers=12) as executor:
        futures = []
        for i in range(len(webcompile_environments)):
            filename = f'webcompile-{i:06d}.tex'
            file_path = os.path.join(output_dir, filename)
            try:
                with open(file_path, 'r') as f:
                    content = f.read()
                if has_file_changed(output_dir, filename, content):
                    future = executor.submit(compile_tex, output_dir, filename)
                    futures.append(future)
            except IOError as e:
                print(f"Error reading {file_path} in webcompile function: {e}")
        concurrent.futures.wait(futures)

def compile_tikzcd(output_dir, tikzcd_environments):
    with concurrent.futures.ThreadPoolExecutor(max_workers=12) as executor:
        futures = []
        for i in range(len(tikzcd_environments)):
            filename = f'tikzcd-{i:06d}.tex'
            file_path = os.path.join(output_dir, filename)
            try:
                with open(file_path, 'r') as f:
                    content = f.read()
                if has_file_changed(output_dir, filename, content):
                    future = executor.submit(compile_tex, output_dir, filename)
                    futures.append(future)
            except IOError as e:
                print(f"Error reading {file_path} in compile_tikzcd function: {e}")
        concurrent.futures.wait(futures)

def regex(filename):
    try:
        with open(filename, 'r') as file:
            content = file.read()
        # Corrected regex pattern from </div to </div>
        content = re.sub(r'<div class="scriptsize">',r'\\begingroup\\scriptsize',content)
        content = re.sub(r'</div>',r'\\endgroup',content) # Corrected pattern
        with open(filename, 'w') as file:
            file.write(content)
    except IOError as e:
        print(f"Error processing file {filename} in regex function: {e}")

def compile_tex(output_dir, filename):
    tex_file_full_path = os.path.join(output_dir, filename)
    base_name = os.path.splitext(filename)[0]
    log_file_path = os.path.join(output_dir, base_name + ".log")
    pdf_file_path = os.path.join(output_dir, base_name + ".pdf")
    svg_file_path = os.path.join(output_dir, base_name + ".svg")

    print(f"Attempting to compile: {tex_file_full_path}")
    print(f"Lualatex will run in directory: {output_dir}")

    # 1. Check if lualatex command is available
    if shutil.which("lualatex") is None:
        print(f"CRITICAL ERROR: 'lualatex' command not found. Please ensure TeX distribution (like TeX Live or MiKTeX) is installed and 'lualatex' is in your system's PATH.")
        return None

    # 2. Check if the source .tex file exists
    if not os.path.exists(tex_file_full_path):
        print(f"Error: LaTeX source file not found: {tex_file_full_path}")
        return None

    print(f"Compiling {filename} with lualatex...")
    try:
        # Using -output-directory=output_dir ensures all auxiliary files go there.
        # The 'filename' argument to lualatex should be the simple filename if CWD is output_dir,
        # or the full path if CWD is elsewhere and -output-directory is used for outputs.
        # Sticking with cwd=output_dir is generally simpler for relative paths within the TeX file.
        result = subprocess.run(
            ['lualatex', '-interaction=batchmode', filename],
            cwd=output_dir,
            check=False # We will check the returncode manually
        )

        if result.stdout:
            print(f"STDOUT from lualatex [{filename}]:\n{result.stdout}")
        if result.stderr:
            # LuaLaTeX often puts non-fatal warnings here, but errors too.
            print(f"STDERR from lualatex [{filename}]:\n{result.stderr}")

        if result.returncode != 0:
            print(f"ERROR: lualatex failed compiling {filename}. Return code: {result.returncode}")
            if os.path.exists(log_file_path):
                try:
                    with open(log_file_path, 'r') as log_file:
                        print(f"Contents of {log_file_path} (Please check for errors like 'File not found' or 'Undefined control sequence'):\n{log_file.read()}")
                except Exception as e:
                    print(f"Could not read log file {log_file_path}: {e}")
            else:
                print(f"Lualatex log file {log_file_path} not found. This often means lualatex could not even start processing the file.")
            return None
        
        # 3. Check if PDF was actually created
        if not os.path.exists(pdf_file_path):
            print(f"ERROR: PDF file {pdf_file_path} was not generated by lualatex, even though lualatex returned success code.")
            print("This can happen if there are severe errors that lualatex reported but didn't cause a non-zero exit code in batchmode, or if output was redirected unexpectedly.")
            if os.path.exists(log_file_path):
                try:
                    with open(log_file_path, 'r') as log_file:
                        print(f"Contents of {log_file_path} (Re-check for subtle errors):\n{log_file.read()}")
                except Exception as e:
                    print(f"Could not read log file {log_file_path}: {e}")
            return None
        print(f"Successfully compiled {filename} to {pdf_file_path}.")

    except FileNotFoundError:
        # This specific exception occurs if 'lualatex' itself isn't found and shutil.which somehow missed it,
        # or if cwd is invalid (less likely here).
        print(f"CRITICAL ERROR: The 'lualatex' command was not found by subprocess.run. Ensure it's in your PATH.")
        return None
    except Exception as e:
        print(f"An unexpected error occurred during lualatex compilation of {filename}: {e}")
        return None

    # 4. Check if pdf2svg command is available
    if shutil.which("pdf2svg") is None:
        print(f"CRITICAL ERROR: 'pdf2svg' command not found. Please ensure it is installed and in your system's PATH.")
        return None

    print(f"Converting {pdf_file_path} to SVG...")
    try:
        # For pdf2svg, filename_pdf is just the basename.pdf, and filename_svg is basename.svg
        # It will operate in output_dir due to cwd.
        result_pdf2svg = subprocess.run(
            ['pdf2svg', os.path.basename(pdf_file_path), os.path.basename(svg_file_path)],
            cwd=output_dir,
            check=False
        )

        if result_pdf2svg.stdout:
            print(f"STDOUT from pdf2svg [{os.path.basename(pdf_file_path)}]:\n{result_pdf2svg.stdout}")
        if result_pdf2svg.stderr:
            print(f"STDERR from pdf2svg [{os.path.basename(pdf_file_path)}]:\n{result_pdf2svg.stderr}")

        if result_pdf2svg.returncode != 0:
            print(f"ERROR: pdf2svg failed for {pdf_file_path}. Return code: {result_pdf2svg.returncode}")
            return None

        # 5. Check if SVG was actually created
        if not os.path.exists(svg_file_path):
            print(f"ERROR: SVG file {svg_file_path} was not generated by pdf2svg, despite a success return code.")
            return None
        
        print(f"Successfully converted {os.path.basename(pdf_file_path)} to {os.path.basename(svg_file_path)}.")
        return filename # Indicate success by returning the original base filename

    except FileNotFoundError:
        print(f"CRITICAL ERROR: The 'pdf2svg' command was not found by subprocess.run. Ensure it's in your PATH.")
        return None
    except Exception as e:
        print(f"An unexpected error occurred during pdf2svg conversion for {pdf_file_path}: {e}")
        return None

def main(input_file):
    # SCALEMATH
    output_dir_scalemath           = '../tmp/scalemath'
    output_dir_scalemath_dark_mode = '../tmp/scalemath/dark-mode'

    # Regular expression pattern to find scalemath environments
    pattern = re.compile(r'\\begin\{scalemath\}(.*?)\\end\{scalemath\}', re.DOTALL)

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # Extract scalemath environments and store them in a list
    scalemath_environments = pattern.findall(content)

    # Replace scalemath environments in the content
    for i, environment in enumerate(scalemath_environments):
        img_tag = f'\\scalemath{{{i:06d}}}'
        content = pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Check if the output directory exists, if not create it
    os.makedirs(output_dir_scalemath, exist_ok=True)
    os.makedirs(output_dir_scalemath_dark_mode, exist_ok=True)

    # Write each scalemath environment to a separate file
    for i, environment in enumerate(scalemath_environments):
        filename = os.path.join(output_dir_scalemath, f'scalemath-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write(get_preamble(IS_DARK_MODE=False))
            file.write("\\usepackage{adjustbox}\\begin{document}\n")
            file.write(r"\[\begin{adjustbox}{width=\linewidth,center}$")
            environment = re.sub("\n\n","\n",environment)
            file.write(environment)
            file.write("$\\end{adjustbox}\\]\n")
            file.write("\\end{document}\n")
        #regex(filename)
    # Write each dark-mode scalemath environment to a separate file
    for i, environment in enumerate(scalemath_environments):
        filename = os.path.join(output_dir_scalemath_dark_mode, f'scalemath-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write(get_preamble(IS_DARK_MODE=True))
            file.write("\\usepackage{adjustbox}\\begin{document}\n")
            file.write(r"\[\begin{adjustbox}{width=\linewidth,center}$")
            environment = re.sub("\n\n","\n",environment)
            environment = re.sub("/pictures/light-mode","/pictures/dark-mode",environment)
            environment = re.sub("gray!40","gray!80!black",environment)
            file.write(environment)
            file.write("$\\end{adjustbox}\\]\n")
            file.write("\\end{document}\n")
        #regex(filename)
    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)

    # WEBCOMPILE
    output_dir_webcompile           = '../tmp/webcompile'
    output_dir_webcompile_dark_mode = '../tmp/webcompile/dark-mode'

    # Regular expression pattern to find webcompile environments
    pattern = re.compile(r'\\begin\{webcompile\}(.*?)\\end\{webcompile\}', re.DOTALL)

    # Read the content of the input file
    with open(input_file, 'r') as file:
        content = file.read()

    # Extract webcompile environments and store them in a list
    webcompile_environments = pattern.findall(content)

    # Replace webcompile environments in the content
    for i, environment in enumerate(webcompile_environments):
        img_tag = f'\\webcompile{{{i:06d}}}'
        content = pattern.sub(img_tag, content, 1)  # Replace only the first occurrence

    # Check if the output directory exists, if not create it
    os.makedirs(output_dir_webcompile, exist_ok=True)
    os.makedirs(output_dir_webcompile_dark_mode, exist_ok=True)

    # Write each webcompile environment to a separate file
    for i, environment in enumerate(webcompile_environments):
        filename = os.path.join(output_dir_webcompile, f'webcompile-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write(get_preamble(IS_DARK_MODE=False))
            file.write("\\begin{document}\n")
            file.write("\\[%")
            environment = re.sub("\n\n","\n",environment)
            file.write(environment)
            file.write("\\]\n")
            file.write("\\end{document}\n")
        #regex(filename)
    # Write each dark-mode webcompile environment to a separate file
    for i, environment in enumerate(webcompile_environments):
        filename = os.path.join(output_dir_webcompile_dark_mode, f'webcompile-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write(get_preamble(IS_DARK_MODE=True))
            file.write("\\begin{document}\n")
            file.write("\\[%")
            environment = re.sub("\n\n","\n",environment)
            environment = re.sub("/pictures/light-mode","/pictures/dark-mode",environment)
            environment = re.sub("gray!40","gray!80!black",environment)
            file.write(environment)
            file.write("\\]\n")
            file.write("\\end{document}\n")
        #regex(filename)
    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)

    # TIKZ-CD
    output_dir           = '../tmp/tikz-cd'
    output_dir_dark_mode = '../tmp/tikz-cd/dark-mode'

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
        img_tag = r'\\'+f'tikzcdid{{{i:06d}}}'
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
            file.write(get_preamble(IS_DARK_MODE=False))
            file.write("\\begin{document}\n")
            file.write("\\begin{tikzcd}%\n")
            environment = re.sub("\n\n","\n",environment)
            file.write(environment)
            file.write("\\end{tikzcd}\n")
            file.write("\\end{document}\n")
        #regex(filename)
    # Write each tikzcd dark-mode environment to a separate file
    for i, environment in enumerate(tikzcd_environments):
        filename = os.path.join(output_dir_dark_mode, f'tikzcd-{i:06d}.tex')
        with open(filename, 'w') as file:
            file.write(get_preamble(IS_DARK_MODE=True))
            file.write("\\begin{document}\n")
            file.write("\\begin{tikzcd}%\n")
            environment = re.sub("\n\n","\n",environment)
            environment = re.sub("gray!40","gray!80!black",environment)
            file.write(environment)
            file.write("\\end{tikzcd}\n")
            file.write("\\end{document}\n")
        #regex(filename)

    # Write the modified content back to the input file
    with open(input_file, 'w') as file:
        file.write(content)
    # Compile Light Mode
    clear_lua_cache()
    scalemath(output_dir_scalemath,scalemath_environments)
    webcompile(output_dir_webcompile,webcompile_environments)
    compile_tikzcd(output_dir,tikzcd_environments)
    # Compile Dark Mode
    clear_lua_cache()
    scalemath(output_dir_scalemath_dark_mode,scalemath_environments)
    webcompile(output_dir_webcompile_dark_mode,webcompile_environments)
    compile_tikzcd(output_dir_dark_mode,tikzcd_environments)
    # Make backups | scalemath
    for i, environment in enumerate(scalemath_environments):
        filename = os.path.join(output_dir_scalemath_dark_mode, f'scalemath-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
        filename = os.path.join(output_dir_scalemath, f'scalemath-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
    # Make backups | webcompile
    for i, environment in enumerate(webcompile_environments):
        filename = os.path.join(output_dir_webcompile_dark_mode, f'webcompile-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
        filename = os.path.join(output_dir_webcompile, f'webcompile-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
    # Make backups | tikzcd
    for i, environment in enumerate(tikzcd_environments):
        filename = os.path.join(output_dir, f'tikzcd-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
        filename = os.path.join(output_dir_dark_mode, f'tikzcd-{i:06d}.tex')
        shutil.copyfile(filename,filename+".bak")
    print(f"Processed {len(scalemath_environments)} scalemath environments.")
    print(f"Processed {len(webcompile_environments)} webcompile environments.")
    print(f"Processed {len(tikzcd_environments)} tikzcd environments.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)
    main(sys.argv[1])
