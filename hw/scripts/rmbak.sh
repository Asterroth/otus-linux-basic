#!/bin/bash

directory="$1"

if [ ! -d "$directory" ]; then
  echo "Directory $directory doesn't exist!"
  exit 2
fi

for extension in .bak .backup .tmp;
  do
    files=( "$1"/*"$extension" )

    if [ -n "$files" ]; then
      echo "Deleting $extension files in $directory..."
      rm -f "${files[@]}"
    else
      echo "No $extension files found in $directory"
    fi
  done
