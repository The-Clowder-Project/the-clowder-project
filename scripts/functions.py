# Find location of repository
import re, os, sys

def regex_env_str():
    # Build a string containing environment names
    regex_env_str
    envs_str = r"("
    for env in list_of_labeled_envs_function():
        envs_str += r"|" + str(env)
    envs_str += r")"
    # envs_str looks like "(definition|question|proposition|lemma|corollary|remark|notation|theorem|construction|example|warning|oldtag|gap|motivation)"
    return envs_str

def absolute_path():
    # Get the absolute path of the script
    script_absolute_path = os.path.abspath(__file__)

    # Get the directory containing the script
    script_dir = os.path.dirname(script_absolute_path)

    # Construct the parent directory by removing the "scripts/" subdirectory
    parent_dir = os.path.abspath(os.path.join(script_dir, os.pardir))

    return parent_dir

def get_path_2():
    from sys import argv
    if not len(argv) == 3 and not len(argv) == 4:
        print("")
        print("This script needs exactly two arguments")
        print("namely the path to the stacks project directory")
        print("")
        raise Exception('Wrong arguments')
    path = argv[2]
    path.rstrip("/")
    path = path + "/"
    return path

def get_path():
    from sys import argv
    if not len(argv) == 2:
        print("")
        print("This script needs exactly one argument")
        print("namely the path to the stacks project directory")
        print("")
        raise Exception('Wrong arguments')
    path = argv[1]
    path.rstrip("/")
    path = path + "/"
    return path

# Assuming there is a title on the line, find it.
def find_title(line):
    n = line.find("\\title{")
    if n < 0:
        return ""
    n = n + 6
    m = find_sub_clause(line, n, "{", "}")
    title = line[n + 1 : m]
    return title

# Returns list of terms being defined, which are pieces of the form
#    {\it definition-text}
def find_defined_terms(def_text):
    def_terms = []
    n = def_text.find("{\\it ")
    while n >= 0:
        m = find_sub_clause(def_text, n, "{", "}")
        def_terms.append(def_text[n : m + 1])
        n = def_text.find("{\\it ", m)
    return def_terms

# Spits out the git version of the git repositor in the path
def git_version(path):
    from subprocess import Popen, PIPE, STDOUT
    cmd = 'git --git-dir=' + path + '.git log --pretty=format:%h -n1'
    p = Popen(cmd, shell=True, stdout=PIPE).stdout
    version = p.read()
    p.close()
    return version

# Check if the line contains a label
def is_label(env_text):
    n = env_text.find("\\label{")
    if n < 0:
        return 0
    return 1

# Check if the line contains a label
def is_label_tcb(env_text):
    n = env_text.find("\\label{")
    if len(re.findall(r"\\begin{"+regex_env_str()+r"}",env_text)) > 0:
        return 1
    if n >= 0:
        return 1
    return 0

# Check if there are references on the line
def contains_ref(line):
    n = line.find("\\ref{")
    if n < 0:
        return 0
    return 1
def contains_cref(line):
    n = line.find("\\cref{")
    if n < 0:
        return 0
    return 1
# returns all long labels for a given name
def get_all_labels(path, name):
    labels = []
    tex_file = open(path + name + ".tex", 'r')
    verbatim = 0
    for line in tex_file:
        # Check for verbatim, because we do not add labels from
        # verbatim environments.
        verbatim = verbatim + beginning_of_verbatim(line)
        if verbatim:
            if end_of_verbatim(line):
                verbatim = 0
            continue

        label = find_label(line)
        if label:
            label = name + ":" + label
            labels.append(label)
    tex_file.close()
    return labels

# returns all long labels in the project
def all_labels(path):
    lijstje = list_text_files(path)
    labels = []
    for name in lijstje:
        extra = get_all_labels(path, name)
        labels = labels + extra
    return labels

# Structure of tags:
#    Already created tags are listed in the file tags/tags
#    Each line of tags/tags is of the form
#        tag,full_label
#    with no spaces and where
#        tag: the actual tag
#        full_label: label with "name-" prepended if the label occurs
#            in the file name.tex
#    See also the file tags/tags for an example.
#    We can also have lines starting with a hash # marking comments.
#    We may want to change the name/label if a result moves from one file to
#    another, or if we split a long file into two pieces. We may also
#    sometimes change the label of a result (eg if there is a typo in the
#    label itself). But the tags should never change.

# The first tag is 0000 and the last tag is ZZZZ
# Starting at tag 04E6 we no longer use O
def next_tag(tag):
    next = list(tag)
    S = "0123456789ABCDEFGHIJKLMNPQRSTUVWXYZ"
    i = 3
    while i >= 0:
        n = S.find(next[i])
        if n == 34:
            next[i] = '0'
        else:
            next[i] = S[n + 1]
            break
        i = i - 1
    return next[0] + next[1] + next[2] + next[3]

# Function producing a list of new tags to assign to LaTeX labels
def get_new_tags(path, tags):
    last_tag = tags[-1][0]
    label_tags = dict((tags[n][1], tags[n][0]) for n in range(0, len(tags)))
    lijstje = list_text_files(path)
    new_tags = []
    for name in lijstje:
        labels = get_all_labels(path, name)
        n = 0
        while n < len(labels):
            if labels[n] not in label_tags:
                last_tag = next_tag(last_tag)
                new_tags.append([last_tag, labels[n]])
            n = n + 1
    parts = get_parts(path)
    for part in parts:
        if parts[part][1] not in label_tags:
                last_tag = next_tag(last_tag)
                new_tags.append([last_tag, parts[part][1]])
    return new_tags

# print out the new tags as found by get_new_tags
def print_new_tags(new_tags):
    n = 0
    while n < len(new_tags):
        print(new_tags[n][0] + "," + new_tags[n][1])
        n = n + 1
    return

# write the new tags to tags/tags
def write_new_tags(path, new_tags):
    tag_file = open(path + "tags/tags", 'a')
    n = 0
    while n < len(new_tags):
        tag_file.write(new_tags[n][0] + "," + new_tags[n][1] + "\n")
        n = n + 1
    tag_file.close()
    return

def get_parts(path):
    lijst = list_text_files(path)
    lijst.append('index')
    lijst.append('xxx')
    parts = {}
    chapters = open(path + "chapters.tex", 'r')
    n = 0
    name = lijst[n]
    for line in chapters:
        if line.find(name + ':section-phantom') >= 0:
            n = n + 1
            name = lijst[n]
        if line.find('\\') < 0:
            title = line.rstrip()
            label = 'book-part:' + "-".join(title.lower().split())
            parts[name] = [title, label]
    chapters.close()
    #parts['notes'] = ['Extra Part', 'book-part:extra']
    return(parts)

########################################################################
#
#
# The rest of the code is shared with the code in the file
# functions.py in stacks-tools
#
#
########################################################################

# We also have labels for
#    'section', 'subsection', 'subsubsection' (every one of these has a label)
#    'item' (typically an item does not have a label)
list_of_labeled_envs = [ \
        'construction', \
        'corollary', \
        'definition', \
        'equation', \
        'example', \
        'explanation', \
        'gap', \
        'lemma', \
        'motivation', \
        'notation', \
        'oldtag', \
        'proposition', \
        'question', \
        'remark', \
        'theorem', \
        'warning']

# Standard labels
list_of_standard_labels = list_of_labeled_envs.append('item')
list_of_standard_labels = list_of_labeled_envs.append('section')
list_of_standard_labels = list_of_labeled_envs.append('subsection')
list_of_standard_labels = list_of_labeled_envs.append('subsubsection')

def list_of_labeled_envs_function():
    return list_of_labeled_envs
# List the stems of the TeX files in the project
# in the correct order
def list_text_files(path):
    Makefile_file = open(path + "Makefile", 'r')
    for line in Makefile_file:
        n = line.find("LIJST = ")
        if n == 0:
            break
    lijst = ""
    while line.find("\\") >= 0:
        line = line.rstrip()
        line = line.rstrip("\\")
        lijst = lijst + " " + line
        line = next(Makefile_file)
    Makefile_file.close()
    lijst = lijst + " " + line
    lijst = lijst.replace("LIJST = ", "")
    #lijst = lijst + " notes"
    return lijst.split()

# Check if the line contains the title of the document
def is_title(line):
    n = line.find("\\title{")
    if n < 0:
        return 0
    return 1

# See if line starts a definition
def beginning_of_definition(line):
    n = line.find("\\begin{definition}")
    if n == 0:
        return 1
    return 0

# See if line ends a definition
def end_of_definition(line):
    n = line.find("\\end{definition}")
    if n == 0:
        return 1
    return 0

# Find clause starting in specific spot with specific open and close characters
def find_sub_clause(text, spot, open, close):
    nr_braces = 0
    while nr_braces >= 0:
        spot = spot + 1
        if text[spot] == open:
            nr_braces = nr_braces + 1
        if text[spot] == close:
            nr_braces = nr_braces - 1
    return spot

# Returns short label. Does not assume there is a label on the line
def find_label(env_text):
    n = env_text.find("\\label{")
    m = env_text.find("%\\item\\label{")
    if n < 0:
        return ""
    if m >= 0:
        return ""
    n = n + 6
    m = find_sub_clause(env_text, n, "{", "}")
    label = env_text[n + 1 : m]
    return label

# See if line starts verbatim environment,
# also check if the \begin{verbatim} starts the line
def beginning_of_verbatim(line):
    n = line.find("\\begin{verbatim}")
    if n > 0:
        raise Exception('\\begin{verbatim} not at start of line.')
    if n == 0:
        return 1
    else:
        return 0

# See if line ends verbatim environment,
# also check if the \begin{verbatim} starts the line
def end_of_verbatim(line):
    n = line.find("\\end{verbatim}")
    if n > 0:
        raise Exception('\\end{verbatim} not at start of line.')
    if n == 0:
        return 1
    return 0

# Silly function
def get_tag_line(line):
    line = line.rstrip()
    return line.split(",")

# Get all active tags in the project
def get_tags(path):
    tags = []
    tag_file = open(path + "tags/tags", 'r')
    for line in tag_file:
        if not line.find("#") == 0:
            tags.append(get_tag_line(line))
    tag_file.close()
    return tags

def get_tags_without_colons(path):
    """
    Reads a tags file, processes each line to extract a tag and its description.
    It removes any prefix from the description part (e.g., "introduction:").
    """
    tags = []
    # Use a 'with' statement for safer file handling
    with open(path + "tags/tags", 'r') as tag_file:
        for line in tag_file:
            # More Pythonic way to check for comments and skip empty lines
            clean_line = line.strip()
            if not clean_line or clean_line.startswith("#"):
                continue

            # --- Start of Modification ---

            # Split the line into the tag ID and the full description
            # The '1' ensures we only split on the first comma
            try:
                tag_id, full_description = clean_line.split(',', 1)
            except ValueError:
                # Skip malformed lines that don't contain a comma
                continue

            # Split the description by the first colon and take the last part.
            # If no colon exists, it gracefully returns the original description.
            final_description = full_description.split(':', 1)[-1]

            # Reconstruct the line to be processed by get_tag_line
            processed_line = f"{tag_id},{final_description}"

            # --- End of Modification ---

            # Assuming get_tag_line is defined elsewhere and processes this format
            tags.append(get_tag_line(processed_line))
            
    return tags

# Check if environment should have a label
# The input should be a line from latex file containing the
# \begin{environment} statement
def labeled_env(env):
    n = 0
    while n < len(list_of_labeled_envs):
        if env.find('\\begin{' + list_of_labeled_envs[n] + '}') == 0:
            return 1
        n = n + 1
    return 0

# Replace refs to refs with full labels
def replace_refs(line, name):
    n = 0
    while n < len(list_of_standard_labels):
        text = "\\ref{" + list_of_standard_labels[n] + "-"
        repl = "\\ref{" + name + ":" + list_of_standard_labels[n] + "-"
        line = line.replace(text, repl)
        n = n + 1
    return line
def replace_crefs(line, name):
    def replacer(match):
        expressions = match.group(1).split(',')
        modified_expressions = [name + ':' + expression for expression in expressions]
        return "\\cref{" + ','.join(modified_expressions) + "}"
        
    line = re.sub(r"\\cref{([^}]*)}", replacer, line)
    return line
    #n = 0
    #while n < len(list_of_standard_labels):
    #    text = "\\cref{" + list_of_standard_labels[n] + "-"
    #    repl = "\\cref{" + name + ":" + list_of_standard_labels[n] + "-"
    #    line = re.sub(text, repl,line)
    #    print(re.sub(text, repl,line))
    #    #line = line.replace(text, repl)
    #    n = n + 1
    #return line

# Chapters unmodified
def print_chapters(path):
    chapters = open(path + "chapters.tex", 'r')
    for line in chapters:
        print(line,end=''),
    chapters.close()
    return

# version and date
def version(path):
    from datetime import date
    now = date.today()
    version = git_version(path)
    return r"V\kern-1.0ptersion " + version.decode("utf-8") + ", compiled on " + now.strftime('%h %d, %Y.')

# version no kern
def version_no_kern(path):
    from datetime import date
    now = date.today()
    version = git_version(path)
    return r"Version " + version.decode("utf-8") + ", compiled on " + now.strftime('%h %d, %Y.')

# Print version and date
def print_version(path):
    from datetime import date
    now = date.today()
    version = str(git_version(path))
    print("Version " + version + ", compiled on " + now.strftime('%h %d, %Y.'))


# Print license blurp
def print_license_blurp(path):
    filename = path + 'introduction.tex'
    introduction = open(filename, 'r')
    inside = 0
    for line in introduction:
        if line.find('\\begin{verbatim}') == 0:
            inside = 1
        if inside == 0:
            continue
        print(line),
        if line.find('\\end{verbatim}') == 0:
            inside = 0
    introduction.close()
