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

# MODIFIED: The function now takes an 'output_file_path' to write to.
def process_file(tag_file_path, ancestor_file_path, output_file_path):
    """
    Rewrites the content of a tag_file with the content of its ancestor,
    leaving the original tag content as-is and wrapping the surrounding
    content in 'unfocused' divs. Writes the result to a new file.
    """
    # MODIFIED: Updated print statement to show output file
    print(f"Processing '{os.path.basename(tag_file_path)}' -> '{os.path.basename(output_file_path)}'...")

    # 1. Read the content of both source files
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
    # The .find() method is perfect for this.
    start_index = ancestor_content.find(tag_content)
    
    if start_index == -1:
        print(f"  [Error] Content of '{os.path.basename(tag_file_path)}' not found in '{os.path.basename(ancestor_file_path)}'. Cannot process.")
        return

    # 3. Split the ancestor content into three parts.
    end_index = start_index + len(tag_content)

    # Part 1: Everything before the tag content.
    content_before = ancestor_content[:start_index]
    
    # Part 2: The tag content itself. This will remain unwrapped.
    
    # Part 3: Everything after the tag content.
    content_after = ancestor_content[end_index:]
    
    # Wrap the 'before' and 'after' parts with the unfocused class.
    # We add a check to ensure we don't create empty <div> tags.
    wrapped_before = f'<div class="current-tag-unfocused">{content_before}</div>' if content_before else ""
    wrapped_after = f'<div class="current-tag-unfocused">{content_after}</div>' if content_after else ""
    
    # Reconstruct the final HTML by concatenating the parts.
    # The tag_content itself is not wrapped.
    final_html = wrapped_before + tag_content + wrapped_after

    # 4. MODIFIED: Write the new content to the destination path, not the original.
    with open(output_file_path, 'w', encoding='utf-8') as f:
        f.write(final_html)
    
    # MODIFIED: Updated success message
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
