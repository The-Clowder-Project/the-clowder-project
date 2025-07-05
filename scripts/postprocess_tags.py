#!/usr/bin/env python

import os
import json
import argparse
import preprocess

# --- Configuration ---
absolute_path = preprocess.absolute_path()

# MODIFIED: Define separate source and destination directories
SOURCE_DIR = os.path.join(absolute_path, 'WEB', 'book.bak')
DEST_DIR = os.path.join(absolute_path, 'WEB', 'book')
MAPPING_FILE = os.path.join(SOURCE_DIR, 'tag_ancestors.json') # The map is read from the source

# MODIFIED: The function now takes an 'output_file_path' to write to and contains new logic for proof files.
def process_file(tag_file_path, ancestor_file_path, output_file_path):
    """
    Rewrites the content of a tag_file with the content of its ancestor,
    leaving the original tag content as-is and wrapping the surrounding
    content in 'unfocused' divs. Writes the result to a new file.

    If a corresponding proof file exists (e.g., 01JM-1.proof for a tag
    containing -01JM-), the 'after' content is taken from after the proof.
    """
    # MODIFIED: Updated print statement to show output file
    print(f"Processing '{os.path.basename(tag_file_path)}' -> '{os.path.basename(output_file_path)}'...")

    # 1. Read the content of all necessary files
    try:
        # We use .strip() to remove any leading/trailing whitespace (like newlines)
        # from the tag file, which can interfere with string matching.
        with open(tag_file_path, 'r', encoding='utf-8') as f:
            tag_content = f.read().strip()

        with open(ancestor_file_path, 'r', encoding='utf-8') as f:
            ancestor_content = f.read()
    except FileNotFoundError as e:
        print(f"  [Error] Could not open source file: {e}. Skipping.")
        return

    # 2. Find the start index of the tag content within the ancestor content.
    start_index = ancestor_content.find(tag_content)

    if start_index == -1:
        print(f"  [Error] Content of '{os.path.basename(tag_file_path)}' not found in '{os.path.basename(ancestor_file_path)}'. Cannot process.")
        return

    # 3. Define content parts. Default to original logic.
    # This will be overridden if the special proof logic applies.
    content_before = ancestor_content[:start_index]
    end_index = start_index + len(tag_content)
    content_after = ancestor_content[end_index:]

    # --- NEW LOGIC FOR HANDLING PROOFS ---

    # A. Try to find the tag code (e.g., "01JM") from the filename
    tag_filename = os.path.basename(tag_file_path)
    # Remove the .tag extension before splitting to handle codes at the end of the name
    name_without_ext, _ = os.path.splitext(tag_filename)
    tag_code = None
    for part in name_without_ext.split('-'):
        # A Stacks Project tag code is typically 4 characters and alphanumeric
        if len(part) == 4 and part.isalnum():
            tag_code = part
            break

    # B. If a code is found, look for the corresponding proof file
    if tag_code:
        proof_filename = f"{tag_code}-1.proof"
        # The proof file is expected to be in the same source directory as the tag file
        source_dir = os.path.dirname(tag_file_path)
        proof_file_path = os.path.join(source_dir, proof_filename)

        if os.path.exists(proof_file_path):
            print(f"  [Info] Found corresponding proof file: '{proof_filename}'")
            try:
                with open(proof_file_path, 'r', encoding='utf-8') as f_proof:
                    proof_content = f_proof.read().strip()

                # C. Find the proof's content in the ancestor page
                proof_start_index = ancestor_content.find(proof_content)
                if proof_start_index != -1:
                    proof_end_index = proof_start_index + len(proof_content)

                    # D. As per the request, redefine 'content_after' to be the content AFTER the proof.
                    # This implements the special wrapping rule.
                    content_after = ancestor_content[proof_end_index:]
                    print("  [Info] Applying special wrapping rule for proof.")
                    tag_content = tag_content + proof_content
                else:
                    print(f"  [Warning] Proof content from '{proof_filename}' not found in ancestor '{os.path.basename(ancestor_file_path)}'. Using default wrapping.")
            except IOError as e:
                print(f"  [Warning] Could not read proof file '{proof_filename}': {e}. Using default wrapping.")

    # --- END OF NEW LOGIC ---

    # 4. Wrap the 'before' and 'after' parts with the unfocused class.
    # The definitions of content_before/content_after now depend on the logic above.
    wrapped_before = f'<div class="current-tag-unfocused">{content_before}</div><span class="current-tag"></span>' if content_before else ""
    wrapped_after = f'<div class="current-tag-unfocused">{content_after}</div>' if content_after else ""

    # 5. Reconstruct the final HTML by concatenating the parts.
    final_html = wrapped_before + tag_content + wrapped_after

    # 6. Write the new content to the destination path.
    with open(output_file_path, 'w', encoding='utf-8') as f:
        f.write(final_html)

    print(f"  [Success] Wrote processed file to '{os.path.basename(output_file_path)}'.")


if __name__ == '__main__':
    """
    Main function to orchestrate the post-processing.
    """
    parser = argparse.ArgumentParser(
        description="Post-process HTML output to highlight a target tag within its ancestor's content."
    )
    # No arguments are actually used, but it's fine to leave this here.
    args = parser.parse_args()

    # I've commented out the original absolute_path call in case 'preprocess' isn't available
    # absolute_path = preprocess.absolute_path()

    # MODIFIED: Use the new SOURCE_DIR and DEST_DIR variables
    if not os.path.isdir(SOURCE_DIR):
        print(f"Error: Source directory '{SOURCE_DIR}' not found.")
        exit()

    # ADDED: Ensure the destination directory exists. Create it if it doesn't.
    print(f"Ensuring destination directory exists: {DEST_DIR}")
    os.makedirs(DEST_DIR, exist_ok=True)

    # Note: MAPPING_FILE path is now based on SOURCE_DIR.
    if not os.path.exists(MAPPING_FILE):
        print(f"Error: Mapping file '{MAPPING_FILE}' not found.")
        print("Please ensure the file exists in the source directory.")
        exit()

    with open(MAPPING_FILE, 'r') as f:
        ancestor_map = json.load(f)

    if not ancestor_map:
        print("Mapping file is empty. No files to process.")
        exit()

    # Process each file pair from the map
    processed_count = 0
    print("\nStarting post-processing...")
    for tag_file, ancestor_file in ancestor_map.items():
        if ".proof" in tag_file:
            continue
        # MODIFIED: Construct full paths for source and destination
        full_tag_path = os.path.join(SOURCE_DIR, tag_file)
        full_ancestor_path = os.path.join(SOURCE_DIR, ancestor_file)
        full_output_path = os.path.join(DEST_DIR, tag_file) # Output file has same name, but in DEST_DIR

        if os.path.exists(full_tag_path) and os.path.exists(full_ancestor_path):
            # MODIFIED: Pass the new output path to the function
            process_file(full_tag_path, full_ancestor_path, full_output_path)
            processed_count += 1
        else:
            if not os.path.exists(full_tag_path):
                print(f"  [Warning] Tag file not found: {full_tag_path}")
            if not os.path.exists(full_ancestor_path):
                print(f"  [Warning] Ancestor file not found: {full_ancestor_path}")

    print(f"\nPost-processing complete. Processed {processed_count} files.")
