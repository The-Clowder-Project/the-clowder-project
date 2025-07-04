import re
import warnings
import os
import subprocess
from typing import Set, Optional, List, Union
import functions

def expand_latex_inputs(
    content: str,
    excluded_filenames: Optional[Union[List[str], Set[str]]] = None,
    base_dir: str = '.',
    visited_files: Optional[Set[str]] = None
) -> str:
    """
    Recursively expands \\input{filename.tex} directives within LaTeX content.
    Specific filenames can be excluded from expansion (their \\input command will
    be removed from the output).

    Args:
        content: The string containing LaTeX code to process.
        excluded_filenames: A list or set of specific filenames (e.g.,
                           {"file1.tex", "config.tex"}) whose \\input{} command
                           should be removed from the output entirely, rather than
                           being expanded or kept. If None or empty, no files
                           are treated this way.
        base_dir: The directory to resolve relative filenames against. Defaults to
                  the current working directory.
        visited_files: A set used internally to track visited files and prevent
                       infinite recursion. Should generally be left as None by the caller.

    Returns:
        The processed string with \\input commands expanded (where applicable)
        and commands for excluded files removed.
    """
    absolute_path = functions.absolute_path()

    if visited_files is None:
        visited_files = set()

    if excluded_filenames:
        excluded_filenames_set = set(excluded_filenames)
    else:
        excluded_filenames_set = set()

    input_pattern = re.compile(r'\\input\{(?:\s*)(.*?)(?:\s*)\}')

    def replacer(match):
        filename = match.group(1)
        if not filename.lower().endswith('.tex'):
            filename_tex = filename + ".tex"
        else:
            filename_tex = filename

        # --- Exclusion Check (MODIFIED BEHAVIOR) ---
        if filename_tex in excluded_filenames_set:
            # If it matches an excluded filename, return an empty string,
            # effectively removing the \input command from the output.
            return "" # MODIFIED LINE

        full_path = absolute_path + "/" + filename_tex

        if full_path in visited_files:
            warnings.warn(f"Circular dependency detected: Skipping expansion of {filename_tex} in {base_dir}. The \\input command will remain.", stacklevel=2)
            # For circular dependencies, we still keep the command to avoid breaking syntax unexpectedly further
            # or to make the circular dependency obvious in the output.
            return match.group(0)

        try:
            if not os.path.exists(full_path):
                 warnings.warn(f"File not found: {filename_tex} (resolved to {full_path}). The \\input command will remain.", stacklevel=2)
                 # If file not found, keep the original \input command
                 return match.group(0)

            visited_files.add(full_path)
            with open(full_path, 'r', encoding='utf-8') as f_input:
                file_content = f_input.read()

            expanded_content = expand_latex_inputs(
                file_content,
                excluded_filenames_set,
                base_dir=os.path.dirname(full_path),
                visited_files=visited_files
            )
            visited_files.remove(full_path)
            return expanded_content

        except IOError as e:
            warnings.warn(f"Error reading {filename_tex} (resolved to {full_path}): {e}. The \\input command will remain.", stacklevel=2)
            if full_path in visited_files:
                 visited_files.remove(full_path)
            return match.group(0) # Keep original command on error
        except Exception as e:
             warnings.warn(f"Unexpected error processing {filename_tex} (resolved to {full_path}): {e}. The \\input command will remain.", stacklevel=2)
             if full_path in visited_files:
                 visited_files.remove(full_path)
             return match.group(0) # Keep original command on error

    processed_content = input_pattern.sub(replacer, content)
    processed_content = re.sub("ABSOLUTEPATH",absolute_path,processed_content)
    return processed_content

def main():
    input_pattern = re.compile(r'\\input\{(.+?)\}')

    ##############
    # READ FILES #
    ##############

    absolute_path = functions.absolute_path()

    # Create the "preamble/compiled" directory if it doesn't exist
    os.makedirs(absolute_path + "/preamble/compiled", exist_ok=True)

    # PREPREAMBLE
    content_prepreamble = ""
    with open(absolute_path+'/prepreamble.tex', 'r') as prepreamble:
        content_prepreamble = prepreamble.read()

    # PREAMBLE/WEB.TEX
    content_web = ""
    with open(absolute_path+'/preamble/web.tex', 'r') as web_tex:
        content_web = web_tex.read()

    # PREAMBLE/TOC.TEX
    content_toc = ""
    with open(absolute_path+'/preamble/toc.tex', 'r') as toc_tex:
        content_toc = toc_tex.read()

    # PREAMBLE/TCBTHM.TEX
    content_tcbthm = ""
    with open(absolute_path+'/preamble/tcbthm.tex', 'r') as tcbthm_tex:
        content_tcbthm = tcbthm_tex.read()

    # PREAMBLE/TCB_FOOTNOTES.TEX
    content_tcb_footnotes = ""
    with open(absolute_path+'/preamble/footnotes-tcb.tex', 'r') as tcb_footnotes_tex:
        content_tcb_footnotes = tcb_footnotes_tex.read()

    # PREAMBLE/ALEGREYA.TEX
    content_alegreya = ""
    with open(absolute_path+'/preamble/alegreya.tex', 'r') as alegreya_tex:
        content_alegreya = alegreya_tex.read()

    # PREAMBLE/ALEGREYA_SANS.TEX
    content_alegreya_sans = ""
    with open(absolute_path+'/preamble/alegreya-sans.tex', 'r') as alegreya_sans_tex:
        content_alegreya_sans = alegreya_sans_tex.read()

    # PREAMBLE/CRIMSON_PRO.TEX
    content_crimson_pro = ""
    with open(absolute_path+'/preamble/crimson-pro.tex', 'r') as crimson_pro_tex:
        content_crimson_pro = crimson_pro_tex.read()

    # PREAMBLE/EB_GARAMOND.TEX
    content_eb_garamond = ""
    with open(absolute_path+'/preamble/eb-garamond.tex', 'r') as eb_garamond_tex:
        content_eb_garamond = eb_garamond_tex.read()

    # PREAMBLE/XCHARTER.TEX
    content_xcharter = ""
    with open(absolute_path+'/preamble/xcharter.tex', 'r') as xcharter_tex:
        content_xcharter = xcharter_tex.read()

    ###################
    # WRITE PREAMBLES #
    ###################

    # WEBPREAMBLE
    with open(absolute_path+'/preamble/compiled/preamble-web.tex', 'w') as webpreamble:
        webpreamble.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/cm.tex','preamble/nontikzcd.tex']))
        webpreamble.write(content_web)

    # PREAMBLE_TIKZCD
    with open(absolute_path+'/preamble/compiled/preamble-tikzcd.tex', 'w') as preamble_tikzcd:
        modified_content_prepreamble = re.sub('\\\documentclass{amsart}','',content_prepreamble)
        modified_content_prepreamble = re.sub('\\\setcounter{minitocdepth}{2\}','',modified_content_prepreamble)
        preamble_tikzcd.write(expand_latex_inputs(modified_content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex','preamble/cm.tex','preamble/fancyheader.tex','preamble/widebar.tex','preamble/nontikzcd.tex']))

    # PREAMBLE_CM
    with open(absolute_path+'/preamble/compiled/preamble-cm.tex', 'w') as preamble_cm:
        preamble_cm.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex']))
        preamble_cm.write(content_toc)

    # PREAMBLE_ALEGREYA
    with open(absolute_path+'/preamble/compiled/preamble-alegreya.tex', 'w') as preamble_alegreya:
        preamble_alegreya.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex','preamble/cm.tex','preamble/widebar.tex']))
        preamble_alegreya.write(content_alegreya)
        preamble_alegreya.write(content_toc)

    # PREAMBLE_ALEGREYA_SANS
    with open(absolute_path+'/preamble/compiled/preamble-alegreya-sans.tex', 'w') as preamble_alegreya_sans:
        preamble_alegreya_sans.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex','preamble/cm.tex','preamble/widebar.tex']))
        preamble_alegreya_sans.write(content_alegreya_sans)
        preamble_alegreya_sans.write(content_toc)

    # PREAMBLE_CRIMSON_PRO
    with open(absolute_path+'/preamble/compiled/preamble-crimson-pro.tex', 'w') as preamble_crimson_pro:
        preamble_crimson_pro.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex','preamble/cm.tex', 'preamble/widebar.tex']))
        preamble_crimson_pro.write(content_crimson_pro)
        preamble_crimson_pro.write(content_toc)

    # PREAMBLE_EB_GARAMOND
    with open(absolute_path+'/preamble/compiled/preamble-eb-garamond.tex', 'w') as preamble_eb_garamond:
        preamble_eb_garamond.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex','preamble/cm.tex', 'preamble/widebar.tex']))
        preamble_eb_garamond.write(content_eb_garamond)
        preamble_eb_garamond.write(content_toc)

    # PREAMBLE_XCHARTER
    with open(absolute_path+'/preamble/compiled/preamble-xcharter.tex', 'w') as preamble_xcharter:
        preamble_xcharter.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex','preamble/cm.tex', 'preamble/widebar.tex']))
        preamble_xcharter.write(content_xcharter)
        preamble_xcharter.write(content_toc)

    # PREAMBLE_ALEGREYA_TCB
    with open(absolute_path+'/preamble/compiled/preamble-alegreya-tcb.tex', 'w') as preamble_alegreya_tcb:
        preamble_alegreya_tcb.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/cm.tex','preamble/webpreamble-refs.tex','preamble/amsthm.tex','preamble/footnotes.tex','preamble/widebar.tex']))
        preamble_alegreya_tcb.write(content_tcbthm)
        preamble_alegreya_tcb.write(content_tcb_footnotes)
        preamble_alegreya_tcb.write(content_alegreya)
        preamble_alegreya_tcb.write(content_toc)

    # PREAMBLE_ALEGREYA_SANS_TCB
    with open(absolute_path+'/preamble/compiled/preamble-alegreya-sans-tcb.tex', 'w') as preamble_alegreya_sans_tcb:
        preamble_alegreya_sans_tcb.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/cm.tex','preamble/webpreamble-refs.tex','preamble/amsthm.tex','preamble/footnotes.tex','preamble/widebar.tex']))
        preamble_alegreya_sans_tcb.write(content_tcbthm)
        preamble_alegreya_sans_tcb.write(content_tcb_footnotes)
        preamble_alegreya_sans_tcb.write(content_alegreya_sans)
        preamble_alegreya_sans_tcb.write(content_toc)

    # PREAMBLE_CM_TCB
    with open(absolute_path+'/preamble/compiled/preamble-cm-tcb.tex', 'w') as preamble_cm_tcb:
        preamble_cm_tcb.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/webpreamble-refs.tex','preamble/amsthm.tex','preamble/footnotes.tex']))
        preamble_cm_tcb.write(content_tcbthm)
        preamble_cm_tcb.write(content_tcb_footnotes)
        preamble_cm_tcb.write(content_toc)

    # PREAMBLE_CRIMSON_PRO_TCB
    with open(absolute_path+'/preamble/compiled/preamble-crimson-pro-tcb.tex', 'w') as preamble_crimson_pro_tcb:
        preamble_crimson_pro_tcb.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/cm.tex','preamble/webpreamble-refs.tex','preamble/amsthm.tex','preamble/footnotes.tex','preamble/widebar.tex']))
        preamble_crimson_pro_tcb.write(content_tcbthm)
        preamble_crimson_pro_tcb.write(content_tcb_footnotes)
        preamble_crimson_pro_tcb.write(content_crimson_pro)
        preamble_crimson_pro_tcb.write(content_toc)

    # PREAMBLE_EB_GARAMOND_TCB
    with open(absolute_path+'/preamble/compiled/preamble-eb-garamond-tcb.tex', 'w') as preamble_eb_garamond_tcb:
        preamble_eb_garamond_tcb.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/cm.tex','preamble/webpreamble-refs.tex','preamble/amsthm.tex','preamble/footnotes.tex','preamble/widebar.tex']))
        preamble_eb_garamond_tcb.write(content_tcbthm)
        preamble_eb_garamond_tcb.write(content_tcb_footnotes)
        preamble_eb_garamond_tcb.write(content_eb_garamond)
        preamble_eb_garamond_tcb.write(content_toc)

    # PREAMBLE_XCHARTER_TCB
    with open(absolute_path+'/preamble/compiled/preamble-xcharter-tcb.tex', 'w') as preamble_xcharter_tcb:
        preamble_xcharter_tcb.write(expand_latex_inputs(content_prepreamble,excluded_filenames=['preamble/cm.tex','preamble/webpreamble-refs.tex','preamble/amsthm.tex','preamble/footnotes.tex','preamble/widebar.tex']))
        preamble_xcharter_tcb.write(content_tcbthm)
        preamble_xcharter_tcb.write(content_tcb_footnotes)
        preamble_xcharter_tcb.write(content_xcharter)
        preamble_xcharter_tcb.write(content_toc)

if __name__ == "__main__":
    main()
