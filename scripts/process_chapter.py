import re, os, io, sys, time, preprocess

def replacement(line,style):
    if ("tcb" in style):
        line = preprocess.tcbthm(line)
        line = preprocess.leftright_square_brackets_and_curly_braces(line)
        line = preprocess.expand_adjunctions(line)
    else:
        line = preprocess.amsthm(line)
        line = preprocess.Proof_to_proof(line)
        line = preprocess.proofbox_to_proof(line)
        line = preprocess.leftright_square_brackets_and_curly_braces(line)
        line = preprocess.expand_adjunctions(line)

    if line.find("%\\item") >= 0:
        line = ""
    if line.find("\\item\\label") >= 0:
        line = re.sub(r'(\\SloganFont{[^}]+})',r'\1%\n',line)
    if line.find(r"ABSOLUTEPATH") >= 0:
        absolute_path = preprocess.absolute_path()
        line = line.replace("ABSOLUTEPATH",absolute_path)
    if not ("tcb" in style):
        if line.find(r"\par\vspace") >= 0:
            line = ""
    return line


style = sys.argv[1]

chapter_number = sys.argv[2]

file_with_relative_path = sys.argv[3]

tex_file = "./" + file_with_relative_path + ".tex"

processed_file = "./" + file_with_relative_path + "P.tex"

# Delete previous processed LaTeX
if os.path.exists(processed_file):
    os.remove(processed_file)

f = open(processed_file, "a")

# Find number of sections/subsections
with open(tex_file,"r") as fp:
    tex_file_content = fp.read()
    def number_of_sections_and_subsections(tex_file_content):
        # Regex for sections (will be our delimiter) and subsections.
        section_pattern = r'\\section\*?(?:\[[^\]]*\])?\{[^}]*\}'
        subsection_pattern = r'\\subsection\*?(?:\[[^\]]*\])?\{[^}]*\}'
        
        # 1. Split the document by the \section command.
        # This gives us a list where the first item is the preamble (before any sections)
        # and the subsequent items are the contents of each section.
        section_chunks = re.split(section_pattern, tex_file_content)
        
        # We don't care about subsections in the preamble, so we analyze the list
        # from the second element onward (index 1).
        subsection_counts_per_section = []
        if len(section_chunks) > 1:
            for chunk in section_chunks[1:]:
                # 2. For each section's content, find all subsection matches.
                count = len(re.findall(subsection_pattern, chunk))
                subsection_counts_per_section.append(count)
                
        # 3. Find the maximum value in our list of counts.
        # If the list is empty (no sections found), the max is 0.
        max_subsections = max(subsection_counts_per_section) if subsection_counts_per_section else 0
        total_sections = len(section_chunks) -1 # The number of sections is the number of splits.
    
        return (total_sections, max_subsections)
    number_of_sections = number_of_sections_and_subsections(tex_file_content)[0]
    number_of_subsections = number_of_sections_and_subsections(tex_file_content)[1]

with open(tex_file) as fp:
    line = fp.readline()
    cnt = 1
    while line:
        if line.find(r"\input{preamble}") >= 0:
            line = ""
            preamble_path = ""
            if style == "cm" or style == "tags-cm":
                preamble_path = "./preamble/compiled/preamble-cm.tex"
            elif style == "alegreya" or style == "tags-alegreya":
                preamble_path = "./preamble/compiled/preamble-alegreya.tex"
            elif style == "alegreya-sans" or style == "tags-alegreya-sans":
                preamble_path = "./preamble/compiled/preamble-alegreya-sans.tex"
            elif style == "crimson-pro" or style == "tags-crimson-pro":
                preamble_path = "./preamble/compiled/preamble-crimson-pro.tex"
            elif style == "eb-garamond" or style == "tags-eb-garamond":
                preamble_path = "./preamble/compiled/preamble-eb-garamond.tex"
            elif style == "xcharter" or style == "tags-xcharter":
                preamble_path = "./preamble/compiled/preamble-xcharter.tex"
            elif style == "cm-tcb" or style == "tags-cm-tcb":
                preamble_path = "./preamble/compiled/preamble-cm-tcb.tex"
            elif style == "alegreya-tcb" or style == "tags-alegreya-tcb":
                preamble_path = "./preamble/compiled/preamble-alegreya-tcb.tex"
            elif style == "alegreya-sans-tcb" or style == "tags-alegreya-sans-tcb":
                preamble_path = "./preamble/compiled/preamble-alegreya-sans-tcb.tex"
            elif style == "crimson-pro-tcb" or style == "tags-crimson-pro-tcb":
                preamble_path = "./preamble/compiled/preamble-crimson-pro-tcb.tex"
            elif style == "eb-garamond-tcb" or style == "tags-eb-garamond-tcb":
                preamble_path = "./preamble/compiled/preamble-eb-garamond-tcb.tex"
            elif style == "xcharter-tcb" or style == "tags-xcharter-tcb":
                preamble_path = "./preamble/compiled/preamble-xcharter-tcb.tex"
            with open(preamble_path,'r') as preamble:
                for line2 in preamble:
                    if line2.find(r"\documentclass") >= 0:
                        if "xcharter" in style:
                            line2 = r"\documentclass[oneside,11pt]{article}"
                        else:
                            line2 = r"\documentclass[oneside,12pt]{article}"
                    if line2.find(r"minitoc") >= 0:
                        continue
                    if line2.find(r"ABSOLUTEPATH") >= 0:
                        absolute_path = preprocess.absolute_path()
                        line2 = line2.replace("ABSOLUTEPATH",absolute_path)
                    if ("tcb" in style and "tags" in style):
                        line2 = preprocess.trans_flag_tcb_fix(line2)
                    if ("tcb" in style):
                        if line2.find("\\setlength{\\TCBBoxCorrection") >= 0:
                            line2 = "\\setlength{\\TCBBoxCorrection}{-0.5\\baselineskip}\n"
                    if line2.find("\\renewcommand{\\thesection}") >= 0:
                        line2 = r"\renewcommand{\thesection}{"+chapter_number+r".\oldthesection}"+"\n"
                    f.write(line2)
            line = fp.readline()
            cnt += 1
            continue
        if line.find(r"\input{chapter_modifications.tex}") >= 0:
            line = ""
            with open('preamble/chapter_modifications.tex','r') as modifications:
                # Lengths
                # Column #1: length for section    headings
                # Column #2: length for subsection headings
                # Column #3: length for subsection headings when subsecnum >= 10
                # Column #4: length for section    headings when chapter number >= 10
                # Column #5: length for subsection headings when chapter number >= 10                  and subsecnum < 10
                # Column #6: length for section    headings when chapter number >= 10                  and subsecnum >= 10
                # Column #7: length for section    headings when chapter number >= 10 and secnum >= 10
                # Column #8: length for subsection headings when chapter number >= 10 and secnum >= 10
                lengths = [ \
                        [1.65, 2.5,  2.9,  2.15, 2.85, 3.35, 2.5, 3.3],# Alegreya
                        [1.65, 2.5,  2.9,  2.15, 2.85, 3.35, 2.5, 3.3],# Alegreya Sans
                        [1.75, 2.6,  3.0,  2.35, 3.0,  3.55, 2.8, 3.45],# Crimson Pro
                        [2.0,  2.85, 3.15, 2.65, 3.3,  3.7,  3.1, 3.75],# Computer Modern
                        [1.85, 2.5,  2.9,  2.4,  2.9,  3.4, 2.95, 3.45],# EB Garamond
                        [2.0,  2.85, 3.25, 2.6,  3.35, 3.9, 3.25, 4.0],# XCharter
                           ]
                for line2 in modifications:
                    if int(chapter_number) < 10:
                        if number_of_sections >= 10:
                            # Doesn't happen at the moment
                            nothing = "nothing"
                        else:
                            # Sections
                            if line2.find(r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{1.65em}}") >= 0:
                                if "alegreya" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][0])+r"em}}"+"\n"
                                elif "alegreya-sans" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][0])+r"em}}"+"\n"
                                elif "crimson-pro" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][0])+r"em}}"+"\n"
                                elif "cm" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][0])+r"em}}"+"\n"
                                elif "eb-garamond" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][0])+r"em}}"+"\n"
                                elif "xcharter" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][0])+r"em}}"+"\n"
                            # Subsections
                            if number_of_subsections < 10:
                                if line2.find(r"{\hspace*{1.65em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{2.5em}}") >= 0:
                                    if "alegreya" in style:
                                        line2 = r"{\hspace*{"+str(lengths[0][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][1])+r"em}}"+"\n"
                                    elif "alegreya-sans" in style:
                                        line2 = r"{\hspace*{"+str(lengths[1][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][1])+r"em}}"+"\n"
                                    elif "crimson-pro" in style:
                                        line2 = r"{\hspace*{"+str(lengths[2][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][1])+r"em}}"+"\n"
                                    elif "cm" in style:
                                        line2 = r"{\hspace*{"+str(lengths[3][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][1])+r"em}}"+"\n"
                                    elif "eb-garamond" in style:
                                        line2 = r"{\hspace*{"+str(lengths[4][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][1])+r"em}}"+"\n"
                                    elif "xcharter" in style:
                                        line2 = r"{\hspace*{"+str(lengths[5][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][1])+r"em}}"+"\n"
                            else: # i.e. number_of_subsections >= 10:
                                if line2.find(r"{\hspace*{1.65em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{2.5em}}") >= 0:
                                    if "alegreya" in style:
                                        line2 = r"{\hspace*{"+str(lengths[0][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][2])+r"em}}"+"\n"
                                    elif "alegreya-sans" in style:
                                        line2 = r"{\hspace*{"+str(lengths[1][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][2])+r"em}}"+"\n"
                                    elif "crimson-pro" in style:
                                        line2 = r"{\hspace*{"+str(lengths[2][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][2])+r"em}}"+"\n"
                                    elif "cm" in style:
                                        line2 = r"{\hspace*{"+str(lengths[3][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][2])+r"em}}"+"\n"
                                    elif "eb-garamond" in style:
                                        line2 = r"{\hspace*{"+str(lengths[4][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][2])+r"em}}"+"\n"
                                    elif "xcharter" in style:
                                        line2 = r"{\hspace*{"+str(lengths[5][0])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][2])+r"em}}"+"\n"
                    else: # i.e. chapter_number >= 10:
                        if number_of_sections >= 10:
                            # Sections
                            if line2.find(r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{1.65em}}") >= 0:
                                if "alegreya" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][6])+r"em}}"+"\n"
                                elif "alegreya-sans" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][6])+r"em}}"+"\n"
                                elif "crimson-pro" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][6])+r"em}}"+"\n"
                                elif "cm" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][6])+r"em}}"+"\n"
                                elif "eb-garamond" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][6])+r"em}}"+"\n"
                                elif "xcharter" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][6])+r"em}}"+"\n"
                            # Subsections
                            if number_of_subsections < 10:
                                if line2.find(r"{\hspace*{1.65em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{2.5em}}") >= 0:
                                    if "alegreya" in style:
                                        line2 = r"{\hspace*{"+str(lengths[0][6])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][7])+r"em}}"+"\n"
                                    elif "alegreya-sans" in style:
                                        line2 = r"{\hspace*{"+str(lengths[1][6])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][7])+r"em}}"+"\n"
                                    elif "crimson-pro" in style:
                                        line2 = r"{\hspace*{"+str(lengths[2][6])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][7])+r"em}}"+"\n"
                                    elif "cm" in style:
                                        line2 = r"{\hspace*{"+str(lengths[3][6])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][7])+r"em}}"+"\n"
                                    elif "eb-garamond" in style:
                                        line2 = r"{\hspace*{"+str(lengths[4][6])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][7])+r"em}}"+"\n"
                                    elif "xcharter" in style:
                                        line2 = r"{\hspace*{"+str(lengths[5][6])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][7])+r"em}}"+"\n"
                            else: # i.e. number_of_subsections >= 10:
                                # Doesn't happen at the moment
                                nothing = "nothing"
                        else:
                            # Sections
                            if line2.find(r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{1.65em}}") >= 0:
                                if "alegreya" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][3])+r"em}}"+"\n"
                                elif "alegreya-sans" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][3])+r"em}}"+"\n"
                                elif "crimson-pro" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][3])+r"em}}"+"\n"
                                elif "cm" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][3])+r"em}}"+"\n"
                                elif "eb-garamond" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][3])+r"em}}"+"\n"
                                elif "xcharter" in style:
                                    line2 = r"{\color{black}\bfseries\textcolor{TitlingRed}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][3])+r"em}}"+"\n"
                            # Subsections
                            if number_of_subsections < 10:
                                if line2.find(r"{\hspace*{1.65em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{2.5em}}") >= 0:
                                    if "alegreya" in style:
                                        line2 = r"{\hspace*{"+str(lengths[0][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][4])+r"em}}"+"\n"
                                    elif "alegreya-sans" in style:
                                        line2 = r"{\hspace*{"+str(lengths[1][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][4])+r"em}}"+"\n"
                                    elif "crimson-pro" in style:
                                        line2 = r"{\hspace*{"+str(lengths[2][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][4])+r"em}}"+"\n"
                                    elif "cm" in style:
                                        line2 = r"{\hspace*{"+str(lengths[3][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][4])+r"em}}"+"\n"
                                    elif "eb-garamond" in style:
                                        line2 = r"{\hspace*{"+str(lengths[4][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][4])+r"em}}"+"\n"
                                    elif "xcharter" in style:
                                        line2 = r"{\hspace*{"+str(lengths[5][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][4])+r"em}}"+"\n"
                            else: # i.e. number_of_subsections >= 10:
                                if line2.find(r"{\hspace*{1.65em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{2.5em}}") >= 0:
                                    if "alegreya" in style:
                                        line2 = r"{\hspace*{"+str(lengths[0][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[0][5])+r"em}}"+"\n"
                                    elif "alegreya-sans" in style:
                                        line2 = r"{\hspace*{"+str(lengths[1][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[1][5])+r"em}}"+"\n"
                                    elif "crimson-pro" in style:
                                        line2 = r"{\hspace*{"+str(lengths[2][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[2][5])+r"em}}"+"\n"
                                    elif "cm" in style:
                                        line2 = r"{\hspace*{"+str(lengths[3][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[3][5])+r"em}}"+"\n"
                                    elif "eb-garamond" in style:
                                        line2 = r"{\hspace*{"+str(lengths[4][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[4][5])+r"em}}"+"\n"
                                    elif "xcharter" in style:
                                        line2 = r"{\hspace*{"+str(lengths[5][3])+r"em}\color{ToCGrey}{\contentslabel{0.0em}}\hspace*{"+str(lengths[5][5])+r"em}}"+"\n"
                    f.write(line2)
            line = fp.readline()
            cnt += 1
            continue
        line = replacement(line,style)
        if line.find(r"\end{appendices}") >= 0:
            line = r"\printbibliography\end{appendices}"
        f.write(line)
        line = fp.readline()
        cnt += 1
f.close()
