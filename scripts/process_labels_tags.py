import re
import sys

def process_labels(text):
    # Mapping dictionary
    chapter_labels = [
            "sets",
            "constructions-with-sets",
            "monoidal-structures-on-the-category-of-sets",
            "pointed-sets",
            "tensor-products-of-pointed-sets",
            "relations",
            "constructions-with-relations",
            "equivalence-relations-and-apartness-relations",
            "categories",
            "constructions-with-monoidal-categories",
            "types-of-morphisms-in-bicategories",
            "monoids",
            "groups",
            "rings",
            "notes",
    ]
    # Define the regex pattern
    for string in chapter_labels:
        text = re.sub("{"+string+":"+"(?!(section-phantom))",'{',text)
        text = re.sub(","+string+":",',',text)
    return text

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()

    content = process_labels(content)

    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)
