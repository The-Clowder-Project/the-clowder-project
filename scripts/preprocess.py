import re
import os
import sys
import time
from functions import regex_env_str

def absolute_path():
    # Get the absolute path of the script
    script_absolute_path = os.path.abspath(__file__)

    # Get the directory containing the script
    script_dir = os.path.dirname(script_absolute_path)

    # Construct the parent directory by removing the "scripts/" subdirectory
    parent_dir = os.path.abspath(os.path.join(script_dir, os.pardir))

    return parent_dir

def expand_cref(line):
    # Pattern to find \cref{...}
    pattern = r'\\cref\{([^}]+)\}'

    def replacer(match):
        # Split the matched contents inside {} by commas
        refs = match.group(1).split(',')
        # If there's only one reference, return it unmodified
        if len(refs) == 1:
            return match.group(0)
        # If there are two references, return it in the form \cref{1} and \cref{2}
        if len(refs) == 2:
            expanded = ', '.join(['\\cref{' + ref.strip() + '}' for ref in refs[:-1]]) + ' and ' + '\\cref{' + refs[-1].strip() + '}'
            return expanded
        # Otherwise, strip any whitespace and reassemble into multiple \cref{} commands
        expanded = ', '.join(['\\cref{' + ref.strip() + '}' for ref in refs[:-1]]) + ', and ' + '\\cref{' + refs[-1].strip() + '}'
        return expanded

    # Substitute each \cref{...} match with the new format
    return re.sub(pattern, replacer, line)

def trans_flag_tcb_fix(line):
    return re.sub(r"../../pictures/trans-flag",r"../../../pictures/trans-flag",line)

def tcbthm(line):
    return re.sub(r"\\begin\{"+regex_env_str()+r"\}\{(.*?)\}\{(.*?)\}",r"\\begin{\1}{\2}{\3}%\\label{\3}",line)

def amsthm(line):
    return re.sub(r"\\begin\{"+regex_env_str()+r"\}\{.*?\}\{(.*?)\}",r"\\begin{\1}\\label{\2}",line)

def chaptermacros(line):
    line = re.sub(r'\\newcommand\{(\\\w+)\}\{\\hyperref\[([a-z0-9-]+):section-phantom\].*',r'\\newcommand{\1}{\\cref{\2:section-phantom}\\xspace}',line)
    return line

def amsthm_web(line):
    line = re.sub(r"\\begin\{"+regex_env_str()+r"\}\{(.*?)\}\{(.*?)\}",r"\\begin{\1}[\2]\\label{\3}",line)
    line = re.sub(r"\\begin\{Proof\}\{(.*?):(.*?)\}%",r"\\begin{proof}[\1:\2}]",line)
    line = re.sub(r"\\begin\{Proof\}\{(.*?)\}\}%",r"\\begin{proof}[\1}]",line)
    line = re.sub(r"FirstProofBox",r"ProofBox",line)
    return line

def Proof_to_proof(line):
    line = re.sub(r"\\begin\{Proof\}\{.*?\}%",r"\\begin{proof}",line)
    line = re.sub(r"\\end\{Proof\}",r"\\end{proof}",line)
    return line

def proofbox_to_proof(line):
    line = re.sub(r"\\FirstProofBox",r"\\ProofBox",line)
    line = re.sub(r"\\ProofBox",r"\\noindent\\ProofBox",line)
    line = re.sub(r"\\ProofBox{\\cref{([a-zA-Z0-9-]+)}: ([\\`,'a-zA-Z0-9 :\-$_{}\*\(\)\/]+)}%",r"\\textit{\\cref{\1}, \2}:",line)
    line = re.sub(r"\\ProofBox{(.*)}%\n",r"\\textit{\1}:",line)
    # SubProofBox
    line = re.sub(r"\\SubProofBox",r"\\noindent\\SubProofBox",line)
    line = re.sub(r"\\SubProofBox{\\cref{([a-zA-Z0-9-]+)}: ([\\`,'a-zA-Z0-9 :\-$_{}\*\(\)\/]+)}%",r"\\textit{\\cref{\1}, \2}:",line)
    line = re.sub(r"\\SubProofBox{(.*)}%\n",r"\\textbf{\1. }",line)
    return line

def remove_index(line):
    def remove_index_with_parser(line):
        i = 0
        output = []
        while i < len(line):
            # Correcting the condition to look for a single backslash
            if line[i:i+7] == r'\index[':
                depth_square = 0
                depth_brace = 0
                inside_square = True
                inside_brace = False
                j = i
                while j < len(line):
                    if inside_square:
                        if line[j] == '[':
                            depth_square += 1
                        elif line[j] == ']':
                            depth_square -= 1
                            if depth_square == 0:
                                inside_square = False
                                inside_brace = True
                    elif inside_brace:
                        if line[j] == '{':
                            depth_brace += 1
                        elif line[j] == '}':
                            depth_brace -= 1
                            if depth_brace == 0:
                                break
                    j += 1
                # Append the part of the line before the \index command and skip to the position after the command
                output.append(line[i:j+1].replace(line[i:j+1], ''))
                i = j + 1
            else:
                output.append(line[i])
                i += 1
        return ''.join(output)
    return remove_index_with_parser(line)

def leftright_square_brackets_and_curly_braces(line):
    # Curly braces
    line = re.sub('(?<!right)(?<!big)(?<!bigg)(?<!Big)(?<!Bigg)\\\\(?!\\\\right)(?!right)}', '\\\\right\\}', line)
    line = re.sub('(?<!left)(?<!big)(?<!bigg)(?<!Big)(?<!Bigg)\\\\(?!\\\\left)(?!left){', '\\\\left\\{', line)
    # Angular brackets
    line = re.sub('\\\\langle', '\\\\left\\\\langle', line)
    line = re.sub('\\\\rangle', '\\\\right\\\\rangle', line)
    # Square brackets
    #line = re.sub(r'(?<!right)(?<!big)(?<!bigg)(?<!Big)(?<!Bigg)(?!\\right)(?!right)(?<![~[0-9][0-9]])\]', r'\\right\]', line)
    #line = re.sub(r'(?<![Gape|pt|cm|cite.*?])(?<!left)(?<!big)(?<!bigg)(?<!Big)(?<!Bigg)(?!\\left)(?!left)\[', r'\\left\[', line)
    #line = re.sub(r'(?<!right)(?<!big)(?<!bigg)(?<!Big)(?<!Bigg)(?!right)(?<!")(?<!cramped)\]', r'\\right\]', line)
    #line = re.sub(r'(?<!left)(?<!big)(?<!bigg)(?<!Big)(?<!Bigg)(?!left)(?<!arrow)(?<!tikzcd})\[', r'\\left\[', line)
    # old
    #line = re.sub('[?<!right][?<!big][?<!bigg][?<!Big][?<!Bigg]\\\\[?!\\\\right][?!right]}', '\\\\right\\\}', line)
    #line = re.sub('[?<!left][?<!big][?<!bigg][?<!Big][?<!Bigg]\\\\[?!\\\\left][?!left]{', '\\\\left\\\{', line)
    return line

def expand_adjunctions(line):
    line = re.sub('\\\\RelativeAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#', r'\\left({\2}\\dashv{\3}\\right)\\colon\\enspace\\phantom{{\4}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\2}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\3}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "{\\rotatebox[origin=c]{-90}{\\dashv}\\mathrlap{\\mkern1.5mu{}_{\\scalebox{0.5}{\1}}}}"{pos=0.55}]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\4}$}{\4}\\mspace{+49.25mu}{\5}',line)#
    line = re.sub('\\\\Adjunction#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    #line = re.sub('\\\\Adjunction#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\AdjunctionShort#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\3\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\4\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}',line)#
    line = re.sub('\\\\FootnoteAdjunction#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.0*\\the\\DL},between origins}, column sep={{4.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\HookAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25,hook']\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\StraightHookAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, shift left=2]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, shift left=2,hook']\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\varStraightHookAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, shift left=2,hook']\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, shift left=2]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\StraightHookTwoAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, shift left=2]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, shift left=2,hook']\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{2}}}"]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\FootnoteHookAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.0*\\the\\DL},between origins}, column sep={{4.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25,hook']\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\varHookAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25,hook']\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\varHookTwoAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25,hook']\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{2}}}"]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\varFootnoteHookAdjunction#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.0*\\the\\DL},between origins}, column sep={{4.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25,hook']\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}''',line)#
    line = re.sub('\\\\TripleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\dashv{\3}\\right)\!\\colon\\enspace\\phantom{{\4}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{6.0*\\the\\DL},between origins}, column sep={{6.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=45]\\arrow[r,"{\3}"'{name=H}, bend right=45]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G,description}]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\arrow[phantom, from=G, to=H, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-65mu}\\negphantom{${\4}$}{\4}\\mspace{+65mu}{\5}''',line)#
    line = re.sub('\\\\FootnoteTripleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\dashv{\3}\\right)\!\\colon\\enspace\\phantom{{\4}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.8*\\the\\DL},between origins}, column sep={{4.8*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=45]\\arrow[r,"{\3}"'{name=H}, bend right=45]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G,description}]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\arrow[phantom, from=G, to=H, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-65mu}\\negphantom{${\4}$}{\4}\\mspace{+65mu}{\5}''',line)#
    line = re.sub('\\\\HookTripleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\dashv{\3}\\right)\!\\colon\\enspace\\phantom{{\4}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{6.0*\\the\\DL},between origins}, column sep={{6.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=45]\\arrow[r,"{\3}"'{name=H}, bend right=45]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G,description},hook']\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\arrow[phantom, from=G, to=H, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-65mu}\\negphantom{${\4}$}{\4}\\mspace{+65mu}{\5}''',line)#
    line = re.sub('\\\\HookTripleTwoAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\dashv{\3}\\right)\!\\colon\\enspace\\phantom{{\4}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{6.0*\\the\\DL},between origins}, column sep={{6.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=45]\\arrow[r,"{\3}"'{name=H}, bend right=45]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G,description},hook']\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{2}}}"]\\arrow[phantom, from=G, to=H, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{2}}}"]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-65mu}\\negphantom{${\4}$}{\4}\\mspace{+65mu}{\5}''',line)#
    line = re.sub('\\\\FootnoteHookTripleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\dashv{\3}\\right)\!\\colon\\enspace\\phantom{{\4}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.8*\\the\\DL},between origins}, column sep={{4.8*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=45]\\arrow[r,"{\3}"'{name=H}, bend right=45]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G,description},hook']\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\arrow[phantom, from=G, to=H, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-65mu}\\negphantom{${\4}$}{\4}\\mspace{+65mu}{\5}''',line)#
    line = re.sub('\\\\QuadrupleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\dashv{\3}\\dashv{\4}\\right)\!\\colon\\enspace\\phantom{{\5}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{7.0*\\the\\DL},between origins}, column sep={{7.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[from=r,"{\1}"'{name=1}, bend right=70,shift right=0.25*\\the\\DL]\\arrow[r,"{\2}"'{description},""'{name=2}, bend left=25]\\arrow[from=r,"{\3}"'{description},""'{name=3}, bend left=25]\\arrow[r,"{\4}"'{name=4}, bend right=70,shift right=0.25*\\the\\DL]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[phantom, from=1, to=2, "\\dashv" rotate=-90,pos=0.45]\\arrow[phantom, from=2, to=3, "\\dashv" rotate=-90]\\arrow[phantom, from=3, to=4, "\\dashv" rotate=-90,pos=0.5]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-85mu}\\negphantom{${\5}$}{\5}\\mspace{+82.5mu}{\6}''',line)#
    line = re.sub('\\\\FootnoteQuadrupleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv{\2}\\dashv{\3}\\dashv{\4}\\right)\!\\colon\\enspace\\phantom{{\5}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{7.2*\\the\\DL},between origins}, column sep={{7.2*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[from=r,"{\1}"'{name=1}, bend right=60]\\arrow[r,"{\2}"'{description},""'{name=2}, bend left=20]\\arrow[from=r,"{\3}"'{description},""'{name=3}, bend left=20]\\arrow[r,"{\4}"'{name=4}, bend right=60]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[phantom, from=1, to=2, "\\dashv" rotate=-90,pos=0.45]\\arrow[phantom, from=2, to=3, "\\dashv" rotate=-90]\\arrow[phantom, from=3, to=4, "\\dashv" rotate=-90,pos=0.45]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-114mu}\\negphantom{${\5}$}{\5}\\mspace{+114mu}{\6}''',line)#
    line = re.sub('\\\\TwoAdjunction#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{2}}}"]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\FootnoteTwoAdjunction#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.0*\\the\\DL},between origins}, column sep={{4.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{2}}}"]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\WeightedTripleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv_{{\4}}{\2}\\dashv_{{\5}}{\3}\\right)\!\\colon\\enspace\\phantom{{\6}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{6.0*\\the\\DL},between origins}, column sep={{6.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=45]\\arrow[r,"{\3}"'{name=H}, bend right=45]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G,description}]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\4}}",pos=0.7]\\arrow[phantom, from=G, to=H, "\\scriptstyle\\udashv\\mrp{{}_{\5}}",pos=0.45]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-65mu}\\negphantom{${\6}$}{\6}\\mspace{+65mu}{\7}''',line)#
    line = re.sub('\\\\FootnoteWeightedTripleAdjunction#(.*)#(.*)#(.*)#(.*)#(.*)#(.*)#(.*)#', r'''\\left({\1}\\dashv_{{\4}}{\2}\\dashv_{{\5}}{\3}\\right)\!\\colon\\enspace\\phantom{{\6}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.8*\\the\\DL},between origins}, column sep={{4.8*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=45]\\arrow[r,"{\3}"'{name=H}, bend right=45]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G,description}]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\4}}"]\\arrow[phantom, from=G, to=H, "\\scriptstyle\\udashv\\mrp{{}_{\5}}"]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-65mu}\\negphantom{${\6}$}{\6}\\mspace{+65mu}{\7}''',line)#
    line = re.sub('\\\\AdjointEquivalence#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{eq}}}",pos=0.55]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\FootnoteAdjointEquivalence#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.0*\\the\\DL},between origins}, column sep={{4.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{eq}}}",pos=0.55]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\varAdjointEquivalence#(.*)#(.*)#(.*)#(.*)#', r'\\left(\\textstyle{\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"\\scriptstyle{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{eq}}}",pos=0.55]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\FootnoteAdjointEquivalence#(.*)#(.*)#(.*)#(.*)#', r'\\left(\\textstyle{\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{4.0*\\the\\DL},between origins}, column sep={{4.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,"\\scriptstyle{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\scriptstyle\\udashv\\mrp{{}_{\\FontForCategories{eq}}}",pos=0.55]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\RelAdjunction#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\phantom{{\3}}\\negphantom{$\\FontForCategories{Grp}$}\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\\phantom{\\FontForCategories{Grp}}\\arrow[r,mid vert,"{\1}"{name=F}, bend left=25]\\&\\phantom{\\FontForCategories{Grp}}\\arrow[l,mid vert,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}\\negphantom{$\\FontForCategories{Grp}$}\\mspace{-49.25mu}\\negphantom{${\3}$}{\3}\\mspace{+49.25mu}{\4}',line)#
    line = re.sub('\\\\RelAdjunctionShort#(.*)#(.*)#(.*)#(.*)#', r'\\left({\1}\\dashv{\2}\\right)\!\\colon\\enspace\\begin{tikzcd}[row sep={{5.0*\\the\\DL},between origins}, column sep={{5.0*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\3\\arrow[r,mid vert,"{\1}"{name=F}, bend left=25]\\&\4\\arrow[l,mid vert,"{\2}"{name=G}, bend left=25]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}',line)#
    line = re.sub('\\\\RelAdjunctionShortSize#(.*)#(.*)#(.*)#(.*)#(.*)#', r'\\left({\2}\\dashv{\3}\\right)\!\\colon\\enspace\\begin{tikzcd}[row sep={{\1*\\the\\DL},between origins}, column sep={{\1*\\the\\DL},between origins}, background color=backgroundColor,ampersand replacement=\\&,cramped]\4\\arrow[r,mid vert,"{\2}"{name=F}, bend left=30]\\&\5\\arrow[l,mid vert,"{\3}"{name=G}, bend left=30]\\arrow[phantom, from=F, to=G, "\\dashv" rotate=-90]\\end{tikzcd}',line)#
    return line

def process_math_expr(match):
    expr = match.group()
    # Transformation for "("
    expr = re.sub(r'(?<!\\noregex)(?<!\\left)(?<!\\big)(?<!\\bigg)(?<!\\Big)(?<!\\Bigg)(?<!\\pig)(?<!\\pigg)(?<!\\Pig)(?<!\\Pigg)\(', '\\\\left(', expr)
    # Transformation for ")"
    expr = re.sub(r'(?<!\\noregex)(?<!\\left)(?<!\\right)(?<!\\big)(?<!\\bigg)(?<!\\Big)(?<!\\Bigg)(?<!\\pig)(?<!\\pigg)(?<!\\Pig)(?<!\\Pigg)\)', '\\\\right)', expr)
    return expr

def transform_latex_content(text):
    # Define a regex pattern to match math expressions
    math_pattern = re.compile(r'(?<!\\)\$.*?(?<!\\)\$|\[.*?\]')
    # Apply the transformation to the text
    return math_pattern.sub(process_math_expr, text)

def itemize(itemize):
    env_stack = []
    output = ""
    i = 0
    ul_positions = []
    special_item_found = False

    while i < len(itemize):
        if itemize[i:i+7] == "\\begin{":
            closing_brace = itemize.find("}", i+7)
            if closing_brace == -1:
                output += itemize[i:]
                break
            env_name = itemize[i+7:closing_brace]
            env_stack.append(env_name)
            if env_name == "itemize":
                ul_positions.append(len(output))
                output += "<ul>"
            else:
                output += itemize[i:closing_brace+1]
            i = closing_brace + 1
        elif itemize[i:i+5] == "\\end{":
            closing_brace = itemize.find("}", i+5)
            if closing_brace == -1:
                output += itemize[i:]
                break
            env_name = itemize[i+5:closing_brace]
            if env_stack and env_stack[-1] == env_name and len(env_stack)>=1:
                env_stack.pop()
            if env_name == "itemize" and len(ul_positions)>=1:
                ul_positions.pop()
                output += "</ul>"
            else:
                output += itemize[i:closing_brace+1]
            i = closing_brace + 1
        elif itemize[i:i+5] == "\\item" and env_stack and env_stack[-1] == "itemize":
            if itemize[i:i+33] == "\\item[$\\webleft(\\star\\webright)$]":
                ul_pos = ul_positions[-1]
                output = output[:ul_pos] + '<ul class="star">' + output[ul_pos+4:]
                i += 33
            elif itemize[i:i+10] == "\\item[\\UP]":
                ul_pos = ul_positions[-1]
                output = output[:ul_pos] + '<ul class="UP">' + output[ul_pos+4:]
                i += 10
            else:
                i += 5
            output += "<li>"
        else:
            output += itemize[i]
            i += 1

    return output
