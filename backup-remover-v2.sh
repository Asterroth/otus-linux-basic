#! /bin/bash

directory=$1

if [ -d "$directory" ]; then
  for filename in $directory/*.; do
    filename=${filename%.*}
    if  [ -f "$filename.bak" ] || \
        [ -f "$filename.backup" ] || \
          [ -f "$filename.tmp" ]; then 
      echo "Removing $filename.bak..."
      rm $filename.bak
      echo "Removing $filename.backup..."
      rm $filename.backup
      echo "Removing $filename.tmp..."
      rm $filename.tmp
    fi
  done
else
  echo "Directory $directory not found."
fi
