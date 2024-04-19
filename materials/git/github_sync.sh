#!/bin/bash
## Ваш GitHub токен (можно найти в настройках аккаунта)
GITHUB_TOKEN=token

## URL репозитория, из которого вы хотите получить файл конфигурации
REPOSITORY_URL=https://github.com/your_username/your_repository

## Имя файла конфигурации
CONFIG_FILE=nginx.conf

## Замените ‘master’ на название ветки или тега,
## если вы хотите использовать конкретную версию файла конфигурации
BRANCH='main'

## Функция для проверки наличия обновлений файла конфигурации на GitHub
check_for_update() {
local url="https://api.github.com/repos/${REPOSITORY_URL}/git/refs/heads/${BRANCH}"
curl --write-out "%{http_code}\n" --silent --output /dev/null "$url"
}

## Если обновление файла конфигурации было обнаружено, скачайте его
if check_for_update; then
echo "Файл конфигурации обновлен. Скачивание…"
git clone --depth 1 --no-single-branch --branch "${BRANCH}" -n \
"https://${GITHUB_TOKEN}@github.com/${REPOSITORY__URL}.git" .
cp ./${CONFIG_FILE} ./nginx.conf
else
echo “Файл конфигурации не обновлен. Используется существующий.”
fi

## Этот скрипт автоматизирует процесс получения файла конфигурации nginx из репозитория GitHub.
## Он проверяет наличие обновлений файла конфигурации и, если обновление найдено,
## скачивает последнюю версию файла. Затем он копирует файл конфигурации в каталог настроек
## вашего веб-сервера. Если обновления не обнаружены, используется существующий файл конфигурации.
## Пожалуйста, замените your_github_token, your_username и your_repository на соответствующие значения
## для вашего случая использования. Также убедитесь, что ваш токен GitHub имеет права на чтение
##для данного репозитория.
## Также обратите внимание, что этот скрипт предполагает, что у вас уже есть рабочая установка
## веб-сервера nginx и вы хотите обновить файл конфигурации, который nginx использует
## для обслуживания ваших веб-страниц.