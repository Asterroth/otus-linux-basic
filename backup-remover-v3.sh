#!/bin/bash
##Проверка наличия аргумента

if [ -z "$1" ]; then
  echo "Path is not specified"
  exit 1
fi
##Формирование команды для вывода файлов с указанными расширениями

find "$1" -type f -iname '*.bak' -delete
echo '.bak files deleted'

find "$1" -type f -iname '*.backup' -exec rm {} \;
echo '.backup files deleted'

find "$1" -type f -iname '*.tmp' -exec rm {} \;
echo '.tmp files deleted'
