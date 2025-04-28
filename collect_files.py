#!/usr/bin/env python3
import sys, os, shutil

input_ = sys.argv[1]
output_ = sys.argv[2]

MAX_DEPTH = 1


if "--max_depth" in sys.argv:
    index = sys.argv.index("--max_depth")
    if index + 1 < len(sys.argv):
        MAX_DEPTH = int(sys.argv[index + 1])

for root, _, files in os.walk(input_):
    rel = os.path.relpath(root, input_)
    parts = rel.split(os.sep) if rel != "." else []
    keep = parts[-(MAX_DEPTH-1):] if MAX_DEPTH > 1 else []
    for name in files:
        rel_path = os.path.join(*keep, name) if keep else name
        destanation = os.path.join(output_, rel_path)

        base, extention = os.path.splitext(rel_path)
        counter = 0
        while os.path.exists(destanation):
            counter += 1
            new_name = f"{base}.{counter}{extention}"
            destanation = os.path.join(output_, *(keep if keep else []), new_name)

        os.makedirs(os.path.dirname(destanation), exist_ok=True)
        shutil.copy2(os.path.join(root, name), destanation)
