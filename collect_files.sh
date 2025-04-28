#!/bin/bash

input_="$1"
output_="$2"
mkdir -p "$output_"


chmod -R +x "$input_"

find "$input_" -type f | while read -r path; do
    filename=$(basename -- "$path")
    FilePath="$output_/$filename"
    counter=1

    while [ -f "$FilePath" ]; do
        baseName="${filename%.*}"
        extension="${filename##*.}"

        if [[ "$filename" == *.* ]]; then
            FilePath="$output_/${baseName}($counter).$extension"
        else
            FilePath="$output_/${baseName}_$counter"
        fi
        ((counter++))
    done

    cp -a "$path" "$FilePath"
done