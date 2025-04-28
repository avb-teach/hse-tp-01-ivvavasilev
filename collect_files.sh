#!/usr/bin/env bash

max_depth=
if [[ $1 == "-m" || $1 == "--max_depth" ]]; then
  max_depth=$2
  shift 2
fi

input_dir=$1
output_dir=$2
mkdir -p "$output_dir"


join(){ local IFS="/"; echo "$*"; }

find "$input_dir" -type f -print0 | while IFS= read -r -d '' file_path; do

  rel=${file_path#"$input_dir"/}
  rel_dir=$(dirname "$rel")
  filename=$(basename "$rel")


  if [[ "$rel_dir" == "." ]]; then
    dir_parts=()
  else
    IFS="/" read -ra dir_parts <<< "$rel_dir"
  fi
  depth=${#dir_parts[@]}

  if [[ -z $max_depth ]]; then
    dest_dirs=( "$output_dir" )
  else
    dest_dirs=()


    if (( depth < max_depth )); then

      dest_dirs+=( "$output_dir${rel_dir:+/$rel_dir}" )
    fi


    if (( depth >= max_depth )); then
      if (( max_depth > 1 )); then
        start=$(( depth - (max_depth - 1) ))
        flat_parts=( "${dir_parts[@]:start:(max_depth-1)}" )
        flat_dir=$(join "${flat_parts[@]}")
        dest_dirs+=( "$output_dir/$flat_dir" )
      else
        dest_dirs+=( "$output_dir" )
      fi
    fi
  fi

  for d in "${dest_dirs[@]}"; do
    mkdir -p "$d"
    dest="$d/$filename"

    idx=1
    base="${filename%.*}"
    ext="${filename##*.}"
    while [[ -e "$dest" ]]; do
      if [[ "$filename" == *.* && "$ext" != "$filename" ]]; then
        dest="$d/${base}($idx).$ext"
      else
        dest="$d/${base}_$idx"
      fi
      ((idx++))
    done

    cp -a "$file_path" "$dest"
  done
done
