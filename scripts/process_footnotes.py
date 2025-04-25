import re, sys

def transform_environments(content):
    # Define the regex pattern to find environments and footnotes
    environment_pattern = re.compile(r'\\begin\{(definition|theorem|question|proposition|lemma|construction|example|remark|notation|corollary|warning|oldtag)\}(\[.*?\]\\label\{.*?:(.*?)\}.*?)\\end\{\1\}', re.DOTALL)
    #footnote_pattern = re.compile(r'(%\n\s*)%--- Begin Footnote ---%\s*\\footnote\{\\textit{}%%(.*?)\n\s*\}(.*?)%\n\s*%---  End Footnote  ---%(\n\s*)', re.DOTALL)
    footnote_pattern = re.compile(r'%--- Begin Footnote ---%\s*\\footnote\{\\textit{}%%(.*?)\n\s*\}(.*?)%\n\s*%---  End Footnote  ---%(\n\s*)', re.DOTALL)
    
    # Function to replace footnotes
    def replace_footnotes(environment,environment_label):
        footnotes = footnote_pattern.findall(environment)
        if len(footnotes) > 0:
            # Rewrite environment
            footnote_number = 0
            environment = footnote_pattern.sub(lambda m: f'BREAKMEHERE', environment)
            segmented_environment = re.split('BREAKMEHERE',environment)
            environment = ''
            for i, segment in enumerate(segmented_environment):
                if i != 0:
                    environment += '\n    % BEGIN RAW HTML %\n        <a href="#footnote:'+environment_label+'-'+str(i)+'"><sup>'+str(footnote_number)+'</sup></a>\n    % BEGIN LATEX HTML %\n    % END RAW HTML %\n    '
                environment += segment
                footnote_number += 1
            footnote_number = 1
            footnote_text = "\n    % BEGIN RAW HTML %\n    <div class=\"footnotes-section\">\n        <hr>\n"
            for footnote in footnotes:
                cleaned_footnote = footnote[0].strip()
                footnote_text += "        <div id=\"footnote:"+environment_label+"-"+str(footnote_number)+"\""+" class=\"individual-footnote\">\n            <sup>" + str(footnote_number) + f"</sup>{cleaned_footnote}\n" + "        </div>\n"
                footnote_number += 1
            footnote_text += "    </div>\n    % BEGIN LATEX HTML %\n    % END RAW HTML %\n"
            return environment.strip() + footnote_text
        else:
            return environment

    # Apply the transformation to all environments
    transformed_content = environment_pattern.sub(lambda m: f'\\begin{{{m.group(1)}}}{replace_footnotes(m.group(2), m.group(3))}\\end{{{m.group(1)}}}', content)
    
    return transformed_content

def transform_proof_environment(content):
    # Define the regex pattern to find environments and footnotes
    environment_pattern = re.compile(r'\\begin\{(proof)\}(\[.*?\](.*?))\\end\{proof\}', re.DOTALL)
    #footnote_pattern = re.compile(r'(%\n\s*)%--- Begin Footnote ---%\s*\\footnote\{\\textit{}%%(.*?)\n\s*\}(.*?)%\n\s*%---  End Footnote  ---%(\n\s*)', re.DOTALL)
    footnote_pattern = re.compile(r'%--- Begin Footnote ---%\s*\\footnote\{\\textit{}%%(.*?)\n\s*\}(.*?)%\n\s*%---  End Footnote  ---%(\n\s*)', re.DOTALL)
    
    # Function to replace footnotes
    def replace_proof_footnotes(environment):
        environment_label = str(abs(hash(environment)))
        footnotes = footnote_pattern.findall(environment)
        if len(footnotes) > 0:
            # Rewrite environment
            footnote_number = 0
            environment = footnote_pattern.sub(lambda m: f'BREAKMEHERE', environment)
            segmented_environment = re.split('BREAKMEHERE',environment)
            environment = ''
            for i, segment in enumerate(segmented_environment):
                if i != 0:
                    environment += '\n    % BEGIN RAW HTML %\n        <a href="#footnote:'+environment_label+'-'+str(i)+'"><sup>'+str(footnote_number)+'</sup></a>\n    % BEGIN LATEX HTML %\n    % END RAW HTML %\n    '
                environment += segment
                footnote_number += 1
            footnote_number = 1
            footnote_text = "\n    % BEGIN RAW HTML %\n    <div class=\"footnotes-section\">\n        <hr>\n"
            for footnote in footnotes:
                cleaned_footnote = footnote[0].strip()
                footnote_text += "        <div id=\"footnote:"+environment_label+"-"+str(footnote_number)+"\""+" class=\"individual-footnote\">\n            <sup>" + str(footnote_number) + f"</sup>{cleaned_footnote}\n" + "        </div>\n"
                footnote_number += 1
            footnote_text += "    </div>\n    % BEGIN LATEX HTML %\n    % END RAW HTML %\n"
            return environment.strip() + footnote_text
        else:
            return environment

    # Apply the transformation to all environments
    transformed_content = environment_pattern.sub(lambda m: f'\\begin{{{m.group(1)}}}{replace_proof_footnotes(m.group(2))}\\end{{{m.group(1)}}}', content)
    
    return transformed_content


def main(input_file):
    # Step 1: Read file
    with open(input_file, 'r') as f:
        content = f.read()
    content = transform_environments(content)
    content = transform_proof_environment(content)
    # Step 2: Extract tcbbox environments
    # Step 3: Extract footnotes inside tcbbox environments
    # Step 4: Regex math
    # Step 5: Put things together again
    # Step 6: Write back
    with open(input_file, 'w') as f:
        f.write(content)

if __name__ == "__main__":
    main(sys.argv[1])
