#!/bin/bash

# Loop through each directory provided as an argument
for dir in "$@"
do
  echo "Counting files in directory: $dir"

  # Use the find command to count the number of files in the directory and its subdirectories
  file_count=$(find "$dir" -type f | wc -l)

  # Output the file count
  echo "Number of files: $file_count"
done
