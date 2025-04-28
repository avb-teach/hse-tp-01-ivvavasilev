#!/bin/bash

inputDirectory="$1"
outputDirectory="$2"
mkdir -p "$outputDirectory"


chmod -R +x "$inputDirectory"

find "$inputDirectory" -type f | while read -r path; do
    filename=$(basename -- "$path")
    destFilePath="$outputDirectory/$filename"
    counter=1

    while [ -f "$destFilePath" ]; do
        baseName="${filename%.*}"
        extension="${filename##*.}"

        if [[ "$filename" == *.* ]]; then
            destFilePath="$outputDirectory/${baseName}($counter).$extension"
        else
            destFilePath="$outputDirectory/${baseName}_$counter"
        fi
        ((counter++))
    done

    cp -a "$path" "$destFilePath"
done