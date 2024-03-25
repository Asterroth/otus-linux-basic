#!/bin/bash

## Путь к локальному репозиторию
PATH2REPO=$HOME/otus-git

## Путь к файлу конфигурации в удаленном (на github) репозитории 
PATH2CONF=./nginx.conf

## Имя ветки
BRANCH='main'

cd $PATH2REPO

git fetch --all

git checkout origin/$BRANCH -- $PATH2CONF

