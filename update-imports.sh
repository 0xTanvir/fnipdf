#!/bin/bash

# Script to replace all occurrences of github.com/unidoc/unipdf/v3 with github.com/0xTanvir/fnipdf in Go files
# Modified for macOS compatibility

# Set the search and replace strings
OLD_IMPORT="github.com/unidoc/unipdf/v3"
NEW_IMPORT="github.com/0xTanvir/fnipdf"

# Count how many files will be modified
total_files=$(find . -name "*.go" -type f -exec grep -l "$OLD_IMPORT" {} \; | wc -l)
echo "Found $total_files Go files with the old import path."

# Find all Go files and replace the import string
find_output=$(find . -name "*.go" -type f -exec grep -l "$OLD_IMPORT" {} \;)
modified_count=0

# Check if any files were found
if [ -z "$find_output" ]; then
  echo "No files containing the old import path were found."
  exit 0
fi

# Process each file
for file in $find_output; do
  echo "Processing $file"
  
  # Make a backup of the original file
  cp "$file" "${file}.bak"
  
  # Replace the import string - using macOS compatible syntax
  sed -e "s|$OLD_IMPORT|$NEW_IMPORT|g" "${file}.bak" > "$file"
  
  # Check if the file was modified
  if diff -q "$file" "${file}.bak" > /dev/null; then
    echo "No changes in $file, restoring from backup."
    mv "${file}.bak" "$file"
  else
    echo "Updated imports in $file"
    modified_count=$((modified_count + 1))
  fi
  
  # Remove backup file
  rm -f "${file}.bak"
done

# Also update the go.mod file if it exists
if [ -f "go.mod" ]; then
  cp "go.mod" "go.mod.bak"
  sed -e "s|module $OLD_IMPORT|module $NEW_IMPORT|g" "go.mod.bak" > "go.mod"
  
  if diff -q "go.mod" "go.mod.bak" > /dev/null; then
    echo "No changes in go.mod, restoring from backup."
    mv "go.mod.bak" "go.mod"
  else
    echo "Updated module name in go.mod"
  fi
  
  # Remove backup file
  rm -f "go.mod.bak"
fi

echo "Import paths updated in $modified_count files."
echo "Done!"