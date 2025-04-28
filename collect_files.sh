#!/usr/bin/env bash

max_depth_value=
if [[ $1 == -m || $1 == --max_depth ]]; then
  max_depth_value=$2
  shift 2
fi

input_dir=$1
output_dir=$2
mkdir -p "$output_dir"

join_paths() {
  local IFS="/"
  echo "$*"
}

find "$input_dir" -type f -print0 | while IFS= read -r -d '' file_path; do
  relative_path=${file_path#"$input_dir"/}
  relative_dir=$(dirname "$relative_path")
  filename=$(basename "$relative_path")
  IFS='/' read -ra dir_segments <<< "$relative_dir"

  if [[ -z $max_depth_value ]]; then
    target_dir="$output_dir"
  else
    if (( ${#dir_segments[@]} > max_depth_value )); then
      truncated_segments=( "${dir_segments[@]:0:max_depth_value}" )
    else
      truncated_segments=( "${dir_segments[@]}" )
    fi
    target_dir="$output_dir/$(join_paths "${truncated_segments[@]}")"
  fi

  mkdir -p "$target_dir"
  dest_path="$target_dir/$filename"
  copy_index=1
  base_name=${filename%.*}
  extension=${filename##*.}

  while [[ -e $dest_path ]]; do
    if [[ $filename == *.* && $extension != $filename ]]; then
      dest_path="$target_dir/${base_name}($copy_index).$extension"
    else
      dest_path="$target_dir/${base_name}_$copy_index"
    fi
    ((copy_index++))
  done
  cp -a "$file_path" "$dest_path"

  if [[ -n $max_depth_value ]]; then
    if (( ${#dir_segments[@]} >= max_depth_value )); then
      if (( max_depth_value > 1 )); then
        start_index=$(( ${#dir_segments[@]} - (max_depth_value - 1) ))
        flat_segments=( "${dir_segments[@]:start_index:(max_depth_value - 1)}" )
        flat_dir=$(join_paths "${flat_segments[@]}")
      else
        flat_dir=""
      fi

      flat_target_dir="$output_dir/$flat_dir"
      mkdir -p "$flat_target_dir"

      flat_dest_path="$flat_target_dir/$filename"
      flat_index=1
      while [[ -e $flat_dest_path ]]; do
        if [[ $filename == *.* && $extension != $filename ]]; then
          flat_dest_path="$flat_target_dir/${base_name}($flat_index).$extension"
        else
          flat_dest_path="$flat_target_dir/${base_name}_$flat_index"
        fi
        ((flat_index++))
      done
      cp -a "$file_path" "$flat_dest_path"
    fi
  fi
done
