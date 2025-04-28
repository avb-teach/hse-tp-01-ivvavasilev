#!/bin/bash

inputDirectory="$1"
outputDirectory="$2"

# Create the output directory if it does not exist
if [ ! -d "$outputDirectory" ]; then
    mkdir -p "$outputDirectory"
fi

# Grant read and execute permissions for the input directory and its contents (if the directory and subdirectories are not empty)
chmod -R +x "$inputDirectory"

# Find files in the input directory and copy them to the output directory, checking for duplicates
find "$inputDirectory" -type f | while read -r path; do
    filename=$(basename -- "$path")
    destFilePath="$outputDirectory/$filename"
    counter_of_identical_files=1

    # If a file with the same name exists, add a counter to the file name
    while [ -f "$destFilePath" ]; do
        baseName="${filename%.*}"
        extension="${filename##*.}"

        if [[ "$filename" == *.* ]]; then
            destFilePath="$outputDirectory/${baseName}($counter_of_identical_files).$extension"
        else
            destFilePath="$outputDirectory/${baseName}_$counter_of_identical_files"
        fi
        ((counter_of_identical_files++))
    done

    # Copy the file to the target directory
    cp -a "$path" "$destFilePath"
done