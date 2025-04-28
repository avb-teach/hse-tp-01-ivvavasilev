#!/usr/bin/env python3
import os
import sys
from shutil import copy2

def parse_arguments(argv):
    input_ = argv[1]
    output_ = argv[2]
    MAX_DEPTH = 1

    if "--max_depth" in argv:
        index = argv.index("--max_depth")
        MAX_DEPTH = int(argv[index + 1])

    return input_, output_, MAX_DEPTH

def flatten_directory(input_, output_, max_depth):
    for root, _, files in os.walk(input_):
        rel_path = os.path.relpath(root, input_)
        if rel_path == '.':
            parts = []
        else:
            parts = rel_path.split(os.sep)
        keep = parts[-(max_depth - 1):]
        for name in files:
            destination_path = construct_destination_path(output_, keep, name)
            handle_file_copy(root, name, destination_path)

def construct_destination_path(output_, keep, name):
    rel_path = os.path.join(*keep, name) if keep else name
    return os.path.join(output_, rel_path)

def handle_file_copy(root, name, destination_path):
    base, extension = os.path.splitext(destination_path)
    counter = 0

    while os.path.exists(destination_path):
        counter += 1
        new_name = f"{base}.{counter}{extension}"
        destination_path = os.path.join(os.path.dirname(destination_path), new_name)

    os.makedirs(os.path.dirname(destination_path), exist_ok=True)
    copy2(os.path.join(root, name), destination_path)

def main():
    input_, output_, max_depth = parse_arguments(sys.argv)
    flatten_directory(input_, output_, max_depth)

if __name__ == "__main__":
    main()
