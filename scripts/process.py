import sys
import re
import html

def process_iff(content):
    content = re.sub('textiff ,', 'iff,', content)
    content = re.sub('textiff ', 'iff ', content)
    return content

def process_textdbend(content):
    #content = re.sub('by 15by 22Umanual', '<span class="textdbend-container"><span class="textdbend-content"><img alt="Dangerous Bend Symbol" src="https://upload.wikimedia.org/wikipedia/commons/0/0b/Knuth%27s_dangerous_bend_symbol.svg">', content)
    content = re.sub('BEGIN TEXTDBEND', '<span class="textdbend-container"><span class="textdbend-content"><img alt="Dangerous Bend Symbol" src="https://upload.wikimedia.org/wikipedia/commons/0/0b/Knuth%27s_dangerous_bend_symbol.svg">', content)
    content = re.sub('END TEXTDBEND', '</span></span>', content)
    return content

def process_warning_sign(content):
    content = re.sub('WARNINGSIGN', '<img src="/static/images/warning.svg" width="20px" style="margin-top:-5px">', content)
    return content

def process_chapter_names(content):
    # Mapping dictionary
    mapping = {
        "Chapter 1":  "Chapter 1: Sets",
        "Chapter 2":  "Chapter 2: Constructions With Sets",
        "Chapter 3":  "Chapter 3: Monoidal Structures on the Category of Sets",
        "Chapter 4":  "Chapter 4: Pointed Sets",
        "Chapter 5":  "Chapter 5: Tensor Products of Pointed Sets",
        "Chapter 6":  "Chapter 6: Relations",
        "Chapter 7":  "Chapter 7: Constructions With Relations",
        "Chapter 8":  "Chapter 8: Equivalence Relations and Apartness Relations",
        "Chapter 9":  "Chapter 9: Categories",
        "Chapter 10": "Chapter 10: Constructions With Monoidal Categories",
        "Chapter 11": "Chapter 11: Types of Morphisms in Bicategories",
    }

    # Define the regex pattern
    for key, value in mapping.items():
        # Use re.escape to handle any special characters in the string
        pattern = r'\b' + re.escape(key) + r'\b'
        content = re.sub(pattern, value, content)
    return content

def process_data_content(content):
    def replacer(match):
        # Replace double quotes with single quotes within the matched content inside data-content attribute
        inner_content = match.group(1).replace('"', "'")
        # Remove all <p> and </p> tags
        inner_content = inner_content.replace('<p>', '').replace('</p>', '')
        return 'data-content="' + inner_content + '"><a class="footnotemark"'
    
    # Match data-content attribute and use replacer function to modify its content
    return re.sub(r'data-content="(.*?)">(?:<a class="footnotemark")', replacer, content, flags=re.DOTALL)
def process_references(content):
    # Mapping dictionary
    mapping = {
        "2-categories-book": "Johnson–Yau, 2-Dimensional Categories",
        "MO119454": "<code>MO 119454</code>",
        "MO302680": "<code>MO 302680</code>",
        "MO321971": "<code>MO 321971</code>",
        "MO382264": "<code>MO 382264</code>",
        "MO441087": "<code>MO 441087</code>",
        "MO455260": "<code>MO 455260</code>",
        "MO460656": "<code>MO 460656</code>",
        "MO461592": "<code>MO 461592</code>",
        "MO467527": "<code>MO 467527</code>",
        "MO468121": "<code>MO 468121</code>",
        "MO468125": "<code>MO 468125</code>",
        "MO468334": "<code>MO 468334</code>",
        "MO64365": "<code>MO 64365</code>",
        "martins-ferreira-sobral:schreier-split-extensions-of-preordered-monoids": "Martins-Ferreira–Sobral, Schreier Split Extensions of Preordered Monoids",
        "MSE102751": "<code>MSE 102751</code>",
        "MSE1299052": "<code>MSE 1299052</code>",
        "MSE1465107": "<code>MSE 1465107</code>",
        "MSE1483996": "<code>MSE 1483996</code>",
        "MSE2096272": "<code>MSE 2096272</code>",
        "MSE2194": "<code>MSE 2194</code>",
        "MSE267365": "<code>MSE 267365</code>",
        "MSE267469": "<code>MSE 267469</code>",
        "MSE2719059": "<code>MSE 2719059</code>",
        "MSE2855868": "<code>MSE 2855868</code>",
        "MSE350788": "<code>MSE 350788</code>",
        "MSE3774686": "<code>MSE 3774686</code>",
        "MSE4565435": "<code>MSE 4565435</code>",
        "MSE733161": "<code>MSE 733161</code>",
        "MSE733163": "<code>MSE 733163</code>",
        "MSE749304": "<code>MSE 749304</code>",
        "MSE884460": "<code>MSE 884460</code>",
        "MSE89736": "<code>MSE 89736</code>",
        "MSE940849": "<code>MSE 940849</code>",
        "arthan:the-eudoxus-real-numbers": "Arthan, The Eudoxus Real Numbers",
        "kemp:cauchy-s-construction-of-r": "Kemp, Cauchy's Construction of $\\mathbb{R}$",
        "belotto:notes-about-dedekind-cuts": "Belotto, Notes About Dedekind Cuts",
        "borceux1994handbook1": "Borceux, Handbook of Categorical Algebra I",
        "bourbaki-general-topology-1-4": "Bourbaki, General Topology 1–4",
        "broughan-adic-topologies-for-the-rational-integers": "Broughan, Adic Topologies for the Rational Integers",
        "ciesielski1997set": "Ciesielski, Set Theory for the Working Mathematician",
        "coalgebras-in-symmetric-monoidal-categories-of-spectra": "Péroux–Shipley, Coalgebras in Symmetric Monoidal Categories of Spectra",
        "coend-calculus": "Loregian, Coend Calculus",
        "epimorphisms-and-dominions-3": "Isbell, Epimorphisms and Dominions III",
        "four-notions-of-conjugacy-for-abstract-semigroups": "Araújo–Kinyon–Konieczny–Malheiro, Four Notions of Conjugacy for Abstract Semigroups",
        "favier:postcompose-not-full": "Favier, Postcompose Not Full",
        "frey:on-the-2-categorical-duals-of-full-and-faithful-functors": "Frey, On the 2-Categorical Duals of (Full and) Faithful Functors",
        "homogeneity-of-the-hilbert-cube-notes-taken-by-albert-verbeek-from-lectures-by-j-de-groot": "Verbeek, Homogeneity of the Hilbert Cube",
        "idempotent-triples-and-completion": "Deleanu–Frei–Hilton, Idempotent Triples and Completion",
        "infinite-dimensional-topology-van-mill": "van Mill, Infinite-Dimensional Topology",
        "lectures-on-n-categories-and-cohomology": "Baez–Shulman, Lectures on $n$-Categories and Cohomology",
        "megginson-an-introduction-to-banach-space-theory": "Megginson, An Introduction to Banach Space Theory",
        "munkres-topology": "Munkres, Topology",
        "niefield:change-of-base-for-relational-variable-sets": "Niefield, Change of Base for Relational Variable Sets",
        "nlab:boundary": "nLab, Boundary",
        "nlab:bump-function": "nLab, Bump Function",
        "nlab:displayed-category": "nLab, Displayed Category",
        "nlab:groupoid": "nLab, Groupoid",
        "nlab:skeleton": "nLab, Skeleton",
        "notes-on-homotopical-algebra": "Zhen Lin Low, Notes on Homotopical Algebra",
        "on-functors-which-are-lax-epimorphisms": "Adámek–Bashir–Sobral–Velebil, On Functors Which Are Lax Epimorphisms",
        "oplax-natural-transformations-twisted-quantum-field-theories-and-even-higher-morita-categories": "Johnson-Freyd–Scheimbauer, Oplax Natural Transformations, Twisted Quantum Field Theories, and “Even Higher” Morita Categories",
        "proof-wiki:cartesian-product-distributes-over-set-difference": "Proof Wiki, Cartesian Product Distributes Over Set Difference",
        "proof-wiki:cartesian-product-distributes-over-symmetric-difference": "Proof Wiki, Cartesian Product Distributes Over Symmetric Difference",
        "proof-wiki:cartesian-product-distributes-over-union": "Proof Wiki, Cartesian Product Distributes Over Union",
        "proof-wiki:cartesian-product-is-empty-iff-factor-is-empty": "Proof Wiki, Cartesian Product Is Empty Iff Factor Is Empty",
        "proof-wiki:cartesian-product-is-weakly-associative": r"Proof Wiki, Bijection between $R\times(S\times T)$ and $(R\times S)\times T$",
        "proof-wiki:cartesian-product-is-weakly-commutative": r"Proof Wiki, Bijection between $S\times T$ and $T\times S$",
        "proof-wiki:cartesian-product-of-intersections": "Proof Wiki, Cartesian Product of Intersections",
        "proof-wiki:characteristic-function-of-intersection": "Proof Wiki, Characteristic Function Of Intersection",
        "proof-wiki:characteristic-function-of-set-difference": "Proof Wiki, Characteristic Function Of Set Difference",
        "proof-wiki:characteristic-function-of-symmetric-difference": "Proof Wiki, Characteristic Function Of Symmetric Difference",
        "proof-wiki:characteristic-function-of-union": "Proof Wiki, Characteristic Function Of Union",
        "proof-wiki:complement-of-complement": "Proof Wiki, Complement Of Complement",
        "proof-wiki:complement-of-preimage-equals-preimage-of-complement": "Proof Wiki, Complement of Preimage Equals Preimage of Complement",
        "proof-wiki:condition-for-mapping-from-quotient-set-to-be-a-surjection": "Proof Wiki, Condition For Mapping From Quotient Set To Be A Surjection",
        "proof-wiki:condition-for-mapping-from-quotient-set-to-be-an-injection": "Proof Wiki, Condition For Mapping From Quotient Set To Be An Injection",
        "proof-wiki:condition-for-mapping-from-quotient-set-to-be-well-defined": "Proof Wiki, Condition For Mapping From Quotient Set To Be Well Defined",
        "proof-wiki:de-morgan-s-laws-set-theory": "Proof Wiki, De Morgan's Laws (Set Theory)",
        "proof-wiki:de-morgan-s-laws-set-theory-set-difference-difference-with-union": "Proof Wiki, De Morgan's Laws (Set Theory)/Set Difference/Difference With Union",
        "proof-wiki:equivalence-of-definitions-of-symmetric-difference": "Proof Wiki, Equivalence of Definitions of Symmetric Difference",
        "proof-wiki:fundamental-theorem-on-equivalence-relations": "Proof Wiki, Fundamental Theorem on Equivalence Relations",
        "proof-wiki:homeomorphism-iff-image-of-closure-equals-closure-of-image": "Proof Wiki, Homeomorphism Iff Image Of Closure Equals Closure Of Image",
        "proof-wiki:image-of-intersection-under-mapping": "Proof Wiki, Image of Intersection Under Mapping",
        "proof-wiki:image-of-set-difference-under-mapping": "Proof Wiki, Image of Set Difference Under Mapping",
        "proof-wiki:image-of-union-under-mapping": "Proof Wiki, Image of Union Under Mapping",
        "proof-wiki:intersection-distributes-over-symmetric-difference": "Proof Wiki, Intersection Distributes Over Symmetric Difference",
        "proof-wiki:intersection-is-associative": "Proof Wiki, Intersection Is Associative",
        "proof-wiki:intersection-is-commutative": "Proof Wiki, Intersection Is Commutative",
        "proof-wiki:intersection-with-empty-set": "Proof Wiki, Intersection With Empty Set",
        "proof-wiki:intersection-with-set-difference-is-set-difference-with-intersection": "Proof Wiki, Intersection With Set Difference Is Set Difference With Intersection",
        "proof-wiki:intersection-with-subset-is-subset": "Proof Wiki, Intersection With Subset Is Subset",
        "proof-wiki:mapping-from-quotient-set-when-defined-is-unique": "Proof Wiki, Mapping From Quotient Set When Defined Is Unique",
        "proof-wiki:preimage-of-intersection-under-mapping": "Proof Wiki, Preimage of Intersection Under Mapping",
        "proof-wiki:preimage-of-set-difference-under-mapping": "Proof Wiki, Preimage of Set Difference Under Mapping",
        "proof-wiki:preimage-of-union-under-mapping": "Proof Wiki, Preimage of Union Under Mapping",
        "proof-wiki:quotient-map-is-coequaliser": "Proof Wiki, Quotient Mapping is Coequalizer",
        "proof-wiki:set-difference-as-intersection-with-complement": "Proof Wiki, Set Difference As Intersection With Complement",
        "proof-wiki:set-difference-as-symmetric-difference-with-intersection": "Proof Wiki, Set Difference As Symmetric Difference With Intersection",
        "proof-wiki:set-difference-is-right-distributive-over-union": "Proof Wiki, Set Difference Is Right Distributive Over Union",
        "proof-wiki:set-difference-over-subset": "Proof Wiki, Set Difference Over Subset",
        "proof-wiki:set-difference-with-empty-set-is-self": "Proof Wiki, Set Difference With Empty Set Is Self",
        "proof-wiki:set-difference-with-self-is-empty-set": "Proof Wiki, Set Difference With Self Is Empty Set",
        "proof-wiki:set-difference-with-set-difference-is-union-of-set-difference-with-intersection": "Proof Wiki, Set Difference With Set Difference Is Union of Set Difference With Intersection",
        "proof-wiki:set-difference-with-subset-is-superset-of-set-difference": "Proof Wiki, Set Difference With Subset Is Superset of Set Difference",
        "proof-wiki:set-difference-with-union": "Proof Wiki, Set Difference With Union",
        "proof-wiki:set-intersection-distributes-over-union": "Proof Wiki, Set Intersection Distributes Over Union",
        "proof-wiki:set-intersection-is-idempotent": "Proof Wiki, Set Intersection Is Idempotent",
        "proof-wiki:set-intersection-preserves-subsets": "Proof Wiki, Set Intersection Preserves Subsets",
        "proof-wiki:set-union-is-idempotent": "Proof Wiki, Set Union Is Idempotent",
        "proof-wiki:set-union-preserves-subsets": "Proof Wiki, Set Union Preserves Subsets",
        "proof-wiki:symmetric-difference-is-associative": "Proof Wiki, Symmetric Difference Is Associative",
        "proof-wiki:symmetric-difference-is-commutative": "Proof Wiki, Symmetric Difference Is Commutative",
        "proof-wiki:symmetric-difference-of-complements": "Proof Wiki, Symmetric Difference Of Complements",
        "proof-wiki:symmetric-difference-on-power-set-forms-abelian-group": "Proof Wiki, Symmetric Difference On Power Set Forms Abelian Group",
        "proof-wiki:symmetric-difference-with-complement": "Proof Wiki, Symmetric Difference With Complement",
        "proof-wiki:symmetric-difference-with-empty-set": "Proof Wiki, Symmetric Difference With Empty Set",
        "proof-wiki:symmetric-difference-with-intersection-forms-ring": "Proof Wiki, Symmetric Difference With Intersection Forms Ring",
        "proof-wiki:symmetric-difference-with-self-is-empty-set": "Proof Wiki, Symmetric Difference With Self Is Empty Set",
        "proof-wiki:symmetric-difference-with-union-does-not-form-ring": "Proof Wiki, Symmetric Difference With Union Does Not Form Ring",
        "proof-wiki:symmetric-difference-with-universe": "Proof Wiki, Symmetric Difference With Universe",
        "proof-wiki:union-as-symmetric-difference-with-intersection": "Proof Wiki, Union As Symmetric Difference With Intersection",
        "proof-wiki:union-distributes-over-intersection": "Proof Wiki, Union Distributes Over Intersection",
        "proof-wiki:union-is-associative": "Proof Wiki, Union Is Associative",
        "proof-wiki:union-is-commutative": "Proof Wiki, Union Is Commutative",
        "proof-wiki:union-of-symmetric-differences": "Proof Wiki, Union Of Symmetric Differences",
        "proof-wiki:union-with-empty-set": "Proof Wiki, Union With Empty Set",
        "riehl:context": "Riehl, Category Theory in Context",
        "schaefer-wolff-topological-vector-spaces": "Schaefer–Wolff, Topological Vector Spaces",
        "selected-topics-in-infinite-dimensional-topology": "Bessaga–Pełczyński, Selected Topics in Infinite-Dimensional Topology",
        "steinberg-representation-theory-of-finite-groups": "Steinberg, Representation Theory of Finite Groups",
        "the-free-adjunction": "Schanuel–Street, The Free Adjunction",
        "the-homogeneous-property-of-the-hilbert-cube": "Halverson–Wright, The Homogeneous Property of the Hilbert Cube",
        "theory-of-correspondences": "Klein–Thompson, Theory of Correspondences",
        "trace-as-an-alternative-decategorification-functor": "Beliakova–Guliyev–Habiro–Lauda, Trace as an Alternative Decategorification Functor",
        "universality-of-multiplicative-infinite-loop-space-machines": "Gepner–Groth–Nikolaus, Universality of Multiplicative Infinite Loop Space Machines",
        "weiss:the-reals-as-rational-cauchy-filters": "Weiss, The Reals as Rational Cauchy Filters",
        "wikipedia:james-s-space": "Wikipedia, James's Space",
        "wikipedia:multivalued-function": "Wikipedia, Multivalued Function",
        "wikipedia:representation-theory-of-finite-groups": "Wikipedia, Representation Theory of Finite Groups",
        "wikipedia:symmetric-difference": "Wikipedia, Symmetric Difference",
    }

    # Define the regex pattern
    pattern = re.compile(r'(<span class=["\']cite["\']>\[<a href="/bibliography/)([^">]+)(["\']>[^<]+</a>\]</span>)')

    # Perform replacement using regex substitution
    content = pattern.sub(lambda m: f'{m.group(1)}{m.group(2)}">{mapping.get(m.group(2), m.group(2))}</a>]</span>', content)
    return content

def process_data_content(content):
    def replacer(match):
        # Replace double quotes with single quotes within the matched content inside data-content attribute
        inner_content = match.group(1).replace('"', "'")
        # Remove all <p> and </p> tags
        inner_content = inner_content.replace('<p>', '').replace('</p>', '')
        return 'data-content="' + inner_content + '"><a class="footnotemark"'
    
    # Match data-content attribute and use replacer function to modify its content
    return re.sub(r'data-content="(.*?)">(?:<a class="footnotemark")', replacer, content, flags=re.DOTALL)

def process_itemize(content):
    content = re.sub('&lt;ul&gt;', '<ul>', content)
    content = re.sub('&lt;ul class="star"&gt;', '<ul class="star">', content)
    content = re.sub('&lt;ul class="UP"&gt;', '<ul class="UP">', content)
    content = re.sub('&lt;li&gt;', '<li>', content)
    content = re.sub('&lt;/ul&gt;', '</ul>', content)
    #content = re.sub('&lt;li class="custom-item" id="NONE"&gt;&lt;span class="counter"&gt;&lt;a class="counter-link" href="/tag/NONE"&gt;&lt;span class="counter-inner"&gt;&lt;/span&gt;&lt;/a&gt;&lt;/span&gt;', '<li class="custom-item" id="NONE"><span class="counter"><a class="counter-link" href="/tag/NONE"><span class="counter-inner"></span></a></span>', content)
    content = re.sub('&lt;li class="custom-item" id="NONE"&gt;&lt;span class="counter-inner-no-pointer"&gt;&lt;/span&gt;', '<li class="custom-item" id="NONE"><span class="counter-inner-no-pointer"></span>', content)
    content = re.sub('&lt;ol class="main-list"&gt;', '<ol class="main-list">', content)
    content = re.sub('&lt;li class="custom-item"&gt;&lt;span class="counter-inner-no-pointer"&gt;&lt;/span&gt;', '<li class="custom-item"><span class="counter-inner-no-pointer"></span>', content)
    content = re.sub('&lt;/ol&gt;', '</ol>', content)
    return content

def process_list_items_web(content):
    # Perform replacement
    #content = re.sub(r'<span class="counter-inner"></span></a></span><p>\s*([^<]+)\s*</p>',
    #                 r'<span class="counter-inner"></span></a></span>\n\1', content)
    content = re.sub(r'<span class="counter-inner"></span></a></span><p>(.*?)</p>',
                     r'<span class="counter-inner"></span></a></span>\n\1', content, flags=re.DOTALL)
    return content
def process_tikzcd_tags(content):
    def replace_equation_divs(input_str):
        # Define a regex pattern to match \[ <div class="tikz-cd">...</div> \] in a single line
        pattern = re.compile(r'\\\[\s*<div class=(\'|")tikz-cd(\'|")>.*?</div>\s*\\\]')
        
        # Define a function to replace \[ and \] within matched strings
        def replace_brackets(match):
            matched_str = match.group(0)
            # Removing the leading \[ and trailing \]
            return matched_str.replace(r'\[', '').replace(r'\]', '').strip()
        
        # Use re.sub to replace matched strings in the original string
        return pattern.sub(replace_brackets, input_str)
    # Define a regex pattern to match specific <div> tags
    pattern = re.compile(r'&lt;div class="(tikz-cd|webcompile|scalemath)"&gt;.*?&lt;img src="/static/(tikzcd|webcompile|scalemath)-images/(tikzcd|webcompile|scalemath)-.*?\.svg".*?&lt;/div&gt;')
    # Define a function to replace &lt; and &gt; within matched strings
    def replace_entities(match):
        matched_str = match.group(0)
        return matched_str.replace('&lt;', '<').replace('&gt;', '>')
    # Use re.sub to replace matched strings in the original string
    content = pattern.sub(replace_entities, content)
    content = replace_equation_divs(content)
    return content
def process_webcompile_tikzcd_zoom(content):
    # Regular expression pattern to find and replace
    pattern = r'(<div class="(tikzcd|webcompile|scalemath)">)(<img src="[^"]+((webcompile|scalemath).*?)\.svg">)(</div>)'
    replacement = r'<div class="\2" id="\4">\3\6'
    return re.sub(pattern, replacement, content)

def process_leftright_to_webleftright(content):
    # Replace all occurrences of '\\left' with '\\webleft'
    content = re.sub(r'\\left\\{', r'\\webleft\\{', content)
    content = re.sub(r'\\left\[', r'\\webleft[', content)
    content = re.sub(r'\\left\(', r'\\webleft(', content)
    
    # Replace all occurrences of '\\right' with '\\webright'
    content = re.sub(r'\\right\\}', r'\\webright\\}', content)
    content = re.sub(r'\\right\]', r'\\webright]', content)
    content = re.sub(r'\\right\)', r'\\webright)', content)
    
    return content

def process_size_tags(content):
    pattern = re.compile(r'&lt;div class="(smallsize|footnotesize|scriptsize|tinysize)"&gt;(.*?)&lt;/div&gt;', re.DOTALL)
    return pattern.sub(r'<div class="\1">\2</div>', content)

def process_enumi(content):
    content = re.sub('(Enumi|Itemv)', 'Item', content)
    content = re.sub('Itemi 1',  'Item (a)', content)
    content = re.sub('Itemi 2',  'Item (b)', content)
    content = re.sub('Itemi 3',  'Item (c)', content)
    content = re.sub('Itemi 4',  'Item (d)', content)
    content = re.sub('Itemi 5',  'Item (e)', content)
    content = re.sub('Itemi 6',  'Item (f)', content)
    content = re.sub('Itemi 7',  'Item (g)', content)
    content = re.sub('Itemi 8',  'Item (h)', content)
    content = re.sub('Itemi 9',  'Item (i)', content)
    content = re.sub('Itemi 10', 'Item (j)', content)
    content = re.sub('Itemi 11', 'Item (k)', content)
    content = re.sub('Itemi 12', 'Item (l)', content)
    content = re.sub('Itemi 13', 'Item (m)', content)
    content = re.sub('Itemi 14', 'Item (n)', content)
    content = re.sub('Itemi 15', 'Item (o)', content)
    content = re.sub('Itemi 16', 'Item (p)', content)
    content = re.sub('Itemi 17', 'Item (q)', content)
    content = re.sub('Itemi 18', 'Item (r)', content)
    content = re.sub('Itemi 19', 'Item (s)', content)
    content = re.sub('Itemi 20', 'Item (t)', content)
    content = re.sub('Itemi 21', 'Item (u)', content)
    content = re.sub('Itemi 22', 'Item (v)', content)
    content = re.sub('Itemi 23', 'Item (w)', content)
    content = re.sub('Itemi 24', 'Item (x)', content)
    content = re.sub('Itemi 25', 'Item (y)', content)
    content = re.sub('Itemi 26', 'Item (z)', content)
    return content

def process_web_environments(content):
    # Define the regex pattern for the article environment
    article_pattern = re.compile(r'(<article class="env-(definition|theorem|question|proposition|lemma|construction|example|remark|notation|corollary|warning|oldtag)" id="[^"]+">)(.*?)(</article>)', re.DOTALL)

    # Define the regex pattern for the environment identifier
    identifier_pattern = re.compile(r'<a class="environment-identifier" href="/tag/[^"]+">[^<]+<span data-tag="[^"]+">[^<]+</span> <span class="named">\((.*?)</span>.</a>')

    def replacer(match):
        article_start = match.group(1)
        article_content = match.group(3)
        article_end = match.group(4)

        # Extract the environment identifier and remove <br> tag immediately after it
        identifier_match = identifier_pattern.search(article_content)
        if identifier_match:
            identifier = identifier_match.group(0)
            # Creating a pattern to match the identifier followed by optional spaces, non-breaking spaces, and a <br> tag
            pattern = re.compile(re.escape(identifier) + r'(\s|&nbsp;)*<br\s*/?>', re.DOTALL)
            # Removing the identifier along with the <br> tag from the article content
            article_content = pattern.sub("", article_content)
        else:
            identifier = ""

        # Create the transformed HTML
        if (match.group(2) == "warning"):
            return f'<div class="env-{match.group(2)}-header"><p>{identifier}</p></div>{article_start}<div class="gogogo-text gogogo-start-1">ゴ</div><div class="gogogo-text gogogo-start-2">ゴ</div><div class="gogogo-text gogogo-start-3">ゴ</div><div class="gogogo-text gogogo-start-4">ゴ</div><div class="gogogo-text gogogo-start-5">ゴ</div><div class="gogogo-text gogogo-start-6">ゴ</div><div class="gogogo-text gogogo-start-7">ゴ</div>{article_content}<div class="gogogo-text gogogo-end-1">ゴ</div><div class="gogogo-text gogogo-end-2">ゴ</div><div class="gogogo-text gogogo-end-3">ゴ</div><div class="gogogo-text gogogo-end-4">ゴ</div><div class="gogogo-text gogogo-end-5">ゴ</div><div class="gogogo-text gogogo-end-6">ゴ</div><div class="gogogo-text gogogo-end-7">ゴ</div><p></p>{article_end}<div class="env-{match.group(2)}-footer"></div>'
        else:
            return f'<div class="env-{match.group(2)}-header"><p>{identifier}</p></div>{article_start}{article_content}{article_end}<div class="env-{match.group(2)}-footer"></div>'
    
    # Replace the article environments using the replacer function
    transformed_html = article_pattern.sub(replacer, content)
    transformed_html = re.sub(r'<a class="environment-identifier" href="/tag/([^"]+)">([^<]+)<span data-tag="([^"]+)">([^<]+)</span> <span class="named">\((.*?)\)</span>.</a>',r'<a class="environment-identifier" href="/tag/\1">\2<span data-tag="\3">\4</span> <span class="named"> <span class="triangleright"> ▶ </span>\5</span></a>',transformed_html)
    return transformed_html

def process_web_environments_proof(content):
    # Pattern to extract the <article class="env-proof">[...]</article> block
    article_pattern = re.compile(r'(<article class="env-proof">)([\s\S]*?)(<\/article>)')
    # Pattern to extract the content inside <strong>...</strong> block
    strong_pattern = re.compile(r'(<strong>[\s\S]*?<\/strong>)')
    # Pattern to identify <br> immediately after </strong>
    br_pattern = re.compile(r'(<\/strong>)\s*<br>')
    # Substitution function to rearrange the blocks as required
    def substitute(match):
        article_start, article_content, article_end = match.groups()
        # Remove <br> immediately after </strong>
        article_content = br_pattern.sub(r'\1', article_content)
        strong_match = strong_pattern.search(article_content)
        if strong_match:
            strong_content = strong_match.group(0)
            article_content = article_content.replace(strong_content, '', 1)
            header_div = f'<div class="env-proof-header">{strong_content}</div>'
            footer_div = '<div class="env-proof-footer"></div>'
            return f'{header_div}{article_start}{article_content}{article_end}{footer_div}'
        return match.group(0)
    return article_pattern.sub(substitute, content)

def process_proof_web(content):
    def modify_article(match):
        article_content = match.group(1)
        
        # Replace <p> and </p> tags as per new requirements.
        #article_content = re.sub(r'<p>\s*<br /><em><a href="(/tag/\w+)" data-tag="(\w+)">(Itemv|Enumi|Enumiv) (\d+)</a>,([^<]+)</em>:(.*?)</p>', r'<div class="p-proof">\n      <a href="\1" data-tag="\2" style="color: white;">Item \4</a>:\5</div>\6', article_content, flags=re.DOTALL)
        article_content = re.sub(r'<p>\s*<em><a href="(/tag/\w+)" data-tag="(\w+)">(Item|Itemv|Enumi|Enumiv) (\d+)</a>,([^<]+)</em>:(.*?)<p>', r'<div class="p-proof">\n      <a href="\1" data-tag="\2" style="color: white;">Item \4</a>:\5</div>\6', article_content, flags=re.DOTALL)
        #
        #article_content = re.sub(r'<p>\s*<em><a href="(/tag/\w+)" data-tag="(\w+)">(Itemv|Enumi|Enumiv) (\d+)</a>,([^<]+)</em>:', r'<div class="p-proof">\n      <a href="\1" data-tag="\2" style="color: white;">Item \4</a>:\5</div>', article_content, flags=re.DOTALL)
        article_content = re.sub(r'<em><a href="(/tag/\w+)" data-tag="(\w+)">(Item|Itemv|Enumi|Enumiv) (\d+)</a>,([^<]+)</em>:', r'<div class="p-proof">\n      <a href="\1" data-tag="\2" style="color: white;">Item \4</a>:\5</div>', article_content, flags=re.DOTALL)
        article_content = re.sub(r'<em>STARTPROOFBOX(.*?)ENDPROOFBOX</em>:', r'<div class="p-proof">\n      \1</div>', article_content, flags=re.DOTALL)
        
        return f'<article class="env-proof">{article_content}</article>'

    return re.sub(r'<article class="env-proof">(.*?)</article>', modify_article, content, flags=re.DOTALL)

def process_empty_a_tags_in_items(content):
    pattern = re.compile(r'<span class="counter"><a class="counter-link" href="/tag/"><span class="counter-inner"></span></a></span>')
    replacement = r'<span class="counter-inner-no-pointer"></span>'
    return re.sub(pattern, replacement, content)

def process_raw_html_2(content, begin_marker="BEGIN RAW HTML", end_marker="END RAW HTML"):
    while True:
        begin_index = content.find(begin_marker)
        end_index = content.find(end_marker)
        
        # Break if either marker is not found
        if begin_index == -1 or end_index == -1:
            break
        
        # Extract and unescape the raw HTML
        raw_html = content[begin_index + len(begin_marker):end_index]
        unescaped_html = html.unescape(raw_html)
        
        # Concatenate the parts together, excluding the markers
        content = content[:begin_index] + unescaped_html + content[end_index + len(end_marker):]
    return content

def process_sublists_web(content):
    list_classes = ["main-list", "sub-list", "subsub-list", "subsubsub-list"]
    depth = 0
    class_idx = 0
    def replacer(match):
        nonlocal depth, class_idx
        opening, closing = match.groups()
        if opening:
            class_name = list_classes[min(class_idx, len(list_classes) - 1)]
            class_idx += 1
            return f'<ol class="{class_name}">'
        elif closing:
            class_idx = max(0, class_idx - 1)
            return '</ol>'
    pattern = r'(<ol class="[^"]*">)|(<\/ol>)'
    updated_content = re.sub(pattern, replacer, content)

    return updated_content

def process_none(content):
    return re.sub('<a href="/tag/" data-tag=""> None</a>', '<a style="cursor: pointer;" tabindex="0" role="button" data-trigger="focus" data-placement="bottom" data-toggle="popover" title="<span class=\'no-reference-popover-title\'>Future Reference</span>" data-html="true" data-content="<div class=\'no-reference-popover-content\'>This is a reference to something which is not yet available in the Clowder Project.</div>"><img class="question-svg" src="/static/images/question.svg"></a>', content)

def process_egroup(content):
    content = re.sub(r'\\begin{bgroup}', '', content)
    content = re.sub(r'\\end{bgroup}', '', content)
    return content

def process_ipa(content):
    content = re.sub(r"IPA (broad|narrow) transcription: \[(.*?)\]\.", r'IPA \1 transcription: [<span class="brill">\2</span>].', content)
    content = re.sub(r"IPA transcription: \[(.*?)\]\.", r'IPA transcription: [<span class="brill">\1</span>].', content)
    return content

def process_footnotes(content):
    # Triple footnotes in running text
    content = re.sub(r'\s*</p>\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)(\s*</p>\n\s*<p>.*?)(<a href=".*?"><sup>\d+</sup></a>)(\s*</p>\n\s*<p>.*?)(<a href=".*?"><sup>\d+</sup></a>)\s*</p>\n\s*<p>(.*?)</p>',r'\1<sup>,</sup>\3<sup>,</sup>\5 \6', content, re.DOTALL)
    # Double footnotes in running text
    content = re.sub(r'\s*</p>\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)(\s*</p>\n\s*<p>.*?)(<a href=".*?"><sup>\d+</sup></a>)\s*</p>\n\s*<p>(.*?)</p>',r'\1<sup>,</sup>\3 \4', content, re.DOTALL)
    # Single footnote in running text
    content = re.sub(r'\s*</p>\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)\s*</p>\n\s*<p>(.*?)</p>',r'\1 \2', content, re.DOTALL)
    content = re.sub(r'\s*\n\n<p>\n\s*(<a href=".*?"><sup>\d+</sup></a>)\s*\n</p>\n<p>\n(.*?)\n</p>',r'\1 \2', content, re.DOTALL)
    # Footnotes appearing before lists
    content = re.sub(r'\s*</p>\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)\s*</p>\n\s*<p><ol',r'\1\n    <ol', content, re.DOTALL)
    # Footnotes appearing before equations
    content = re.sub(r'\s*</p>\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)\s*</p>\n\s*<div',r'\1\n    <div', content, re.DOTALL)
    content = re.sub(r'\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)\s*</p>\n\s*<div',r'\1\n    <div', content, re.DOTALL)
    # Single footnote appearing at the end of an environment
    content = re.sub(r'\s*</p>\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)(\s*</p>\n\s*<p> <div class="footnotes-section)',r'\1\2', content, re.DOTALL)
    content = re.sub(r'\n\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)\s*<p>\s*(<div class="footnotes-section")', r'\1\2', content, re.DOTALL)
    # Single footnote appearing after math in running text
    content = re.sub(r'\s*<p> (<a href=".*?"><sup>\d+</sup></a>)\s*</p>\s*<p>',r'\1 ', content, re.DOTALL)
    # Single footnote appearing after an item inside a list
    content = re.sub(r'\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)\s*</p>\s*</li>',r'\1</li>', content, re.DOTALL)
    # Single footnote appearing before a ProofBox
    content = re.sub(r'\s*<p>\s*(<a href=".*?"><sup>\d+</sup></a>)\s*<div class="p-proof">',r'\1<div class="p-proof">', content, re.DOTALL)
    # Single footnote appearing after colon
    content = re.sub(r'\s*(<a href=".*?"><sup>\d+</sup></a>)',r'\1', content, re.DOTALL)
    return content

def process_qed_symbol_should_come_before_the_footnotes_section_in_proof_environments(content):
    # Check if there are multiple proof environments
    if (len(re.findall(r"env-proof-header",content)) >= 3):
        # Case where there is a footnote section on the third proof environment
        content = re.sub(r'<div class="env-proof-header">(.*?)<div class="env-proof-header">(.*?)<div class="env-proof-header">(.*?)<div class="footnotes-section">(.*?)<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span>(.*?)<div class="env-proof-footer">',r'<div class="env-proof-header">\1<div class="env-proof-header">\2<div class="env-proof-header">\3<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span><div class="footnotes-section">\4\5<div class="env-proof-footer">',content,flags=re.DOTALL)
    else:
        if (len(re.findall(r"env-proof-header",content)) == 2):
            # Case where there is a footnote section on the first proof environment
            content = re.sub(r'<div class="env-proof-header">(.*?)<div class="footnotes-section">(.*)<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span>(.*)<div class="env-proof-footer">(.*)<div class="env-proof-header">',r'<div class="env-proof-header">\1<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span><div class="footnotes-section">\2\3<div class="env-proof-footer">\4<div class="env-proof-header">',content,flags=re.DOTALL)
            # Case where there are footnote sections on both proof environments
            content = re.sub(r'<div class="env-proof-header">(.*?)<div class="footnotes-section">(.*)<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span>(.*)<div class="env-proof-footer">(.*)<div class="env-proof-header">(.*?)<div class="footnotes-section">(.*)<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span>(.*)<div class="env-proof-footer">',r'<div class="env-proof-header">\1<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span><div class="footnotes-section">\2\3<div class="env-proof-footer">\4<div class="env-proof-header">\5<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span><div class="footnotes-section">\6\7<div class="env-proof-footer">',content,flags=re.DOTALL)
            # Case where there is a footnote section on the second proof environment
            content = re.sub(r'<div class="env-proof-header">(.*?)<div class="env-proof-header">(.*?)<div class="footnotes-section">(.*?)<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span>(.*?)<div class="env-proof-footer">',r'<div class="env-proof-header">\1<div class="env-proof-header">\2<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span><div class="footnotes-section">\3\4<div class="env-proof-footer">',content,flags=re.DOTALL)
        else:
            # If the last thing appearing in a proof is a footnote
            content = re.sub(r'(<a href=".*?"><sup>\d+</sup></a>)\s*<p>\s*<div class="footnotes-section">(.*)<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span>\s*</p>\s*</article>',r'\1<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span><p><div class="footnotes-section">\2</p></article>',content,flags=re.DOTALL)
            # General case
            content = re.sub(r'<div class="env-proof-header">(.*?)<div class="footnotes-section">(.*)<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span>(.*)<div class="env-proof-footer">',r'<div class="env-proof-header">\1<span class="qed"><img src="/static/images/trans-flag.svg" width="15px"></span><div class="footnotes-section">\2\3<div class="env-proof-footer">',content,flags=re.DOTALL)
    return content

def process_less_than_and_greater_than_symbols(content):
    content = re.sub(r'LESSTHANMATHSYMBOL',r'&lt;',content,flags=re.DOTALL)
    content = re.sub(r'GREATERTHANMATHSYMBOL',r'&gt;',content,flags=re.DOTALL)
    return content

def process_code_environment(content):
    content = re.sub(r'<pre class="code-block language-latex"><code>\n',r'<pre class="code-block language-latex"><code>',content,flags=re.DOTALL)
    return content

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    content = process_textdbend(content)
    content = process_warning_sign(content)
    content = process_references(content)
    content = process_data_content(content)
    content = process_itemize(content)
    content = process_list_items_web(content)
    content = process_tikzcd_tags(content)
    content = process_webcompile_tikzcd_zoom(content)
    content = process_leftright_to_webleftright(content)
    content = process_size_tags(content)
    content = process_enumi(content)
    content = process_web_environments(content)
    content = process_web_environments_proof(content)
    content = process_proof_web(content)
    content = process_enumi(content)
    content = process_empty_a_tags_in_items(content)
    content = process_raw_html_2(content)
    content = process_sublists_web(content)
    content = process_none(content)
    content = process_egroup(content)
    content = process_chapter_names(content)
    content = process_iff(content)
    content = process_ipa(content)
    content = process_footnotes(content)
    content = process_qed_symbol_should_come_before_the_footnotes_section_in_proof_environments(content)
    content = process_less_than_and_greater_than_symbols(content)
    content = process_code_environment(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
