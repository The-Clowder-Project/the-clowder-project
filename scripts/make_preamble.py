# Author: GPT4 \o/
import re
import time
import os

def expand_input(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    return content

def main():
    input_pattern = re.compile(r'\\input\{(.+?)\}')
    
    with open('prepreamble.tex', 'r') as prepreamble, open('webpreamble.tex', 'w') as preamble:
        for line in prepreamble:
            if line.find(r"preamble/cm") >= 0:
                continue
            if line.find(r"zref") >= 0:
                continue
            if line.find(r"fancyheader") >= 0:
                continue
            if line.find(r"footnotes") >= 0:
                continue
            if line.find(r"nonweb") >= 0:
                continue
            match = input_pattern.search(line)
            if match:
                input_file = match.group(1)
                if os.path.exists(input_file):
                    content = expand_input(input_file)
                    preamble.write(content)
                else:
                    print(f"Warning: {input_file} does not exist, writing the line as is.")
                    preamble.write(line)
            else:
                preamble.write(line)
            ####
        if os.path.exists("preamble/web.tex"):
            content = expand_input("preamble/web.tex")
            preamble.write(content)
        ####
    with open('prepreamble.tex', 'r') as prepreamble, open('preamble.tex', 'w') as preamble:
        for line in prepreamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                preamble.write("\\input{preamble/cm.tex}")
                preamble.write("\n")
                continue
            if line.find(r"webpreamble-refs") >= 0:
                continue
            match = input_pattern.search(line)
            if match:
                input_file = match.group(1)
                if os.path.exists(input_file):
                    content = expand_input(input_file)
                    preamble.write(content)
                else:
                    print(f"Warning: {input_file} does not exist, writing the line as is.")
                    preamble.write(line)
            else:
                preamble.write(line)
    with open('prepreamble.tex', 'r') as prepreamble, open('preamble-tcb.tex', 'w') as preamble:
        for line in prepreamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                preamble.write("\\input{preamble/cm.tex}")
                preamble.write("\n")
                continue
            if line.find(r"webpreamble-refs") >= 0:
                continue
            if line.find(r"\input{preamble/amsthm.tex}") >= 0:
                line = line.replace("amsthm","tcbthm")
            if line.find(r"\input{preamble/footnotes.tex}") >= 0:
                line = line.replace("footnotes","footnotes-tcb")
            match = input_pattern.search(line)
            if match:
                input_file = match.group(1)
                if os.path.exists(input_file):
                    content = expand_input(input_file)
                    preamble.write(content)
                else:
                    print(f"Warning: {input_file} does not exist, writing the line as is.")
                    preamble.write(line)
            else:
                preamble.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/cm.tex', 'r') as cm, open('preamble-cm.tex', 'w') as preamble_cm:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line2 in cm:
                    preamble_cm.write(line2)
            else:
                preamble_cm.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/toc.tex', 'r') as toc, open('preamble/alegreya_sans.tex', 'r') as alegreya_sans, open('preamble-alegreya-sans.tex', 'w') as preamble_alegreya_sans:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in alegreya_sans:
                    preamble_alegreya_sans.write(line)
                continue
            else:
                preamble_alegreya_sans.write(line)
        for line in toc:
            preamble_alegreya_sans.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/toc.tex', 'r') as toc, open('preamble/arno.tex', 'r') as arno, open('preamble-arno.tex', 'w') as preamble_arno:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in arno:
                    preamble_arno.write(line)
                continue
            else:
                preamble_arno.write(line)
        for line in toc:
            preamble_arno.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/toc.tex', 'r') as toc, open('preamble/darwin.tex', 'r') as darwin, open('preamble-darwin.tex', 'w') as preamble_darwin:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in darwin:
                    preamble_darwin.write(line)
                continue
            else:
                preamble_darwin.write(line)
        for line in toc:
            preamble_darwin.write(line)
    with open('preamble-tcb.tex', 'r') as preamble_tcb, open('preamble/toc.tex', 'r') as toc, open('preamble/alegreya_sans_tcb.tex', 'r') as alegreya_sans_tcb, open('preamble-alegreya-sans-tcb.tex', 'w') as preamble_alegreya_sans_tcb:
        for line in preamble_tcb:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in alegreya_sans_tcb:
                    preamble_alegreya_sans_tcb.write(line)
                continue
            else:
                preamble_alegreya_sans_tcb.write(line)
        for line in toc:
            preamble_alegreya_sans_tcb.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/alegreya_sans.tex', 'r') as alegreya_sans, open('preamble-chapter-alegreya-sans.tex', 'w') as preamble_alegreya_sans:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in alegreya_sans:
                    preamble_alegreya_sans.write(line)
                continue
            else:
                preamble_alegreya_sans.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/arno.tex', 'r') as arno, open('preamble-chapter-arno.tex', 'w') as preamble_arno:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in arno:
                    preamble_arno.write(line)
                continue
            else:
                preamble_arno.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/darwin.tex', 'r') as darwin, open('preamble-chapter-darwin.tex', 'w') as preamble_darwin:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in darwin:
                    preamble_darwin.write(line)
                continue
            else:
                preamble_darwin.write(line)
    with open('preamble-tcb.tex', 'r') as preamble_tcb, open('preamble/alegreya_sans_tcb.tex', 'r') as alegreya_sans_tcb, open('preamble-chapter-alegreya-sans-tcb.tex', 'w') as preamble_alegreya_sans_tcb:
        for line in preamble_tcb:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line in alegreya_sans_tcb:
                    preamble_alegreya_sans_tcb.write(line)
                continue
            else:
                preamble_alegreya_sans_tcb.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/cm.tex', 'r') as cm, open('preamble-chapter-cm.tex', 'w') as preamble_cm:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line2 in cm:
                    preamble_cm.write(line2)
            else:
                preamble_cm.write(line)
    with open('preamble.tex', 'r') as preamble, open('preamble/toc.tex', 'r') as toc, open('preamble/cm.tex', 'r') as cm, open('preamble-cm.tex', 'w') as preamble_cm:
        for line in preamble:
            if line.find("\\input{preamble/cm.tex}") >= 0:
                for line2 in cm:
                    preamble_cm.write(line2)
            else:
                preamble_cm.write(line)
        for line in toc:
            preamble_cm.write(line)

if __name__ == "__main__":
    main()
