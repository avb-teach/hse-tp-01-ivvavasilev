#!/bin/bash

inputDirectory=""
outputDirectory=""
maxDepth=0

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --max_depth)
        maxDepth="$2"
        shift 2
        ;;
      *)
        if [[ -z "$inputDirectory" ]]; then
          inputDirectory="$1"
        elif [[ -z "$outputDirectory" ]]; then
          outputDirectory="$1"
        fi
        shift
        ;;
    esac
  done
}

prepare_directories() {
  mkdir -p "$outputDirectory" >/dev/null 2>&1
  chmod -R +x "$inputDirectory" >/dev/null 2>&1
}

build_find_command() {
  local cmd=(find "$inputDirectory" -type f)
  [[ $maxDepth -gt 0 ]] && cmd+=(-mindepth 1 -maxdepth "$maxDepth")
  echo "${cmd[@]}"
}

generate_unique_path() {
  local destDir="$1"
  local baseName="$2"
  local fileName="${baseName%.*}"
  local extension="${baseName##*.}"

  local candidatePath="$destDir/$baseName"
  local counter=1

  while [[ -e "$candidatePath" ]]; do
    if [[ "$baseName" == *.* ]]; then
      candidatePath="$destDir/${fileName}($counter).$extension"
    else
      candidatePath="$destDir/${fileName}($counter)"
    fi
    ((counter++))
  done

  echo "$candidatePath"
}

copy_files() {
  local findCmd=($(build_find_command))

  "${findCmd[@]}" | while IFS= read -r filePath; do
    local relPath="${filePath#$inputDirectory/}"
    local destDir="$outputDirectory/$(dirname "$relPath")"
    local baseName=$(basename "$relPath")

    mkdir -p "$destDir" >/dev/null 2>&1

    local finalDest
    finalDest=$(generate_unique_path "$destDir" "$baseName")

    cp -a "$filePath" "$finalDest" >/dev/null 2>&1
  done
}

main() {
  parse_arguments "$@"
  prepare_directories
  copy_files
}

main "$@"
