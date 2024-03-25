# Разбор ДЗ урока 5.

# a) Написать скрипт, который удаляет из текстового файла пустые строки и 
# заменяет маленькие символы на большие (воспользуйтесь tr или sed).

#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

echo "Enter the filename:"
read filename

if [ -f $filename ]; then
  tr "[:lower:]" "[:upper:]" < $filename > tempfile
  tr -s '\n' < tempfile > $filename
  rm -f tempfile
  echo -en "${YELLOW}========\033[0m\n"
  cat $filename
  echo -en "${YELLOW}========\033[0m\n\n"
  echo -en "${GREEN}DONE\033[0m\n\n"
else
  echo -en "${RED}File doesn't exist\033[0m\n"
fi

# b) Создать скрипт мониторинга лога, чтобы он выводил сообщения при попытке 
# неудачной аутентификации пользователя /var/log/auth.log, отслеживая сообщения 
# примерно такого вида:
# May 16 19:45:52 vlamp login[102782]: FAILED LOGIN (1) on '/dev/tty3' FOR 'user', 
# Authentication failure
# Проверить скрипт, выполнив ошибочную регистрацию с виртуального терминала.

#!/bin/bash

RED='\033[0;31m'

tail -n 0 -F /var/log/auth.log | \
while read LINE
do
  echo "$LINE" | grep -q "failure"
  if [ $? = 0 ]
  then
    echo "\n"
    echo -en "${RED}Attention! Authentication failure!\033[0m\n"
  fi
done

# c) Создать скрипт, который создаст директории для нескольких годов (2010 — 2017), 
# в них — поддиректории для месяцев (от 01 до 12), и в каждый из них запишет 
# несколько файлов с произвольными записями (например 001.txt, содержащий текст 
# Файл 001, 002.txt с текстом Файл 002) и т.д.

for i in {2013..2019}
	do
		for j in {01..12}
			do
				for d in {01..31}
					do
						for h in {01..24}
						  do
						    echo $i$j$d$h.txt > $i$j$d$h.txt
						  done
					  mv $i$j$d* $i/$j/$d
					done
			done
	done

# 2. * Более сложные задания на скрипты (и cron):

# a) Создать файл crontab, который ежедневно регистрирует занятое 
# каждым пользователем дисковое пространство в его домашней директории.
# текст скрипта по адресу: /home/krotbrod/sandbox/script.sh

#!/bin/bash
# сначала скрипт узнаёт дату, затем размер всех домашних папок в кб 
# некоторые файлы в поддиректориях недоступны для скрипта, потому что недостаточно 
# прав, сообщение об этом также выводится в лог 
# но если запускать скрипт из /etc/crontab от пользователя root, то всё будет 
# работать без ошибок
day=$(date)
size=$(du -s /home/* 2>&1)
echo -e "$day\n$size\n\n\n" 

$ crontab -e
SHELL = /bin/sh
MAILTO = dsfdsff@gmail.com
PATH = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/home/krotbrod/sandbox
28 15 * * * $HOME/sandbox/script.sh >> $HOME/sandbox/sizelog.txt


# b) Создать скрипт ownersort.sh, который в заданной папке копирует файлы в 
# директории, названные по имени владельца каждого файла. Учтите, что файл 
# должен принадлежать соответствующему владельцу

#!/bin/bash

# Сначала считываем всех владельцев файлов в директории, 
# убираем повторения и делаем папки по одной для каждого.
dir=$(ls -l | tr -s ' ' '\t' | cut -f '3' | sort -u)
for i in $dir; do
  mkdir -p $i
done

# Теперь считываем владельцев и названия.
# Проходимся по ним циклом (нечётное - владелец, чётное - название)
# Если название - проверяем, что это файл, а не папка.
# Если файл - отправляем в директорию с именем хозяина.
dirfile=$(ls -l | tr -s ' ' '\t' | cut -f '3 9')
count=0
for i in $dirfile; do
  count=$((count+1))
  if (($count%2))
    then
        dir=$i
        echo $dir = $i zero
    else
        if [ -f ./$i ]
          then
                cp ./$i ./$dir/$i
        fi
  fi
done


# c) Написать скрипт rename.sh, аналогичный разобранному, но порядковые номера 
# файлов выравнивать, заполняя слева нуля до ширины максимального значения 
# индекса: newname000.jpg, newname102.jpg (Использовать printf). 
# Дополнительно к 3 добавить проверку на расширение, чтобы не переименовать .sh.

# в задании сказано написать скрипт аналогичный разобранному и внести изменения;
# основное тело скрипта скопировал из методички;
# над внесёнными от себя строками поставил комментарии

#!/bin/bash

if [ $# -lt 2 ]
then
	echo Usage:
	echo $0 newprefix file1 file2 …
	exit 1
fi

prefix=$1
shift
count=0
for file in $*
do
	# проверяем файл на суффикс ".sh", если суффикса нет, выражение даёт ноль и переименование выполняется
	$(echo $file | egrep -v "*\.sh$") && {          
		count=$[count+1]
		# как и сказано в задании с помощью printf задаём длину строки в три знака, 
		# а  пустые места заполняются нулями
		num=$(printf '%03d' $count)
		mv -n "${file}" "${prefix}${num}.jpg"
	}
done
exit 0


# d) Написать скрипт резервного копирования по расписанию следующим образом:
# В первый день месяца помещать копию в backdir/montlhy.
# Бэкап по пятницам хранить в каталоге backdir/weekley.
# В остальные дни сохранять копии в backdir/daily.
# Настроить ротацию следующим образом. Ежемесячные копии хранить 180 дней, ежедневные — неделю, еженедельные — 30 дней. Подсказка: для ротации используйте find.
# Примечание. Задание 2 дано для тех, кому упражнения 1 показалось недостаточно.

$nano ~/backup/back.sh
#!/bin/bash

[ "$1"  = "--help" ]&&{
                        echo \# Скрипт резервного копирования.
                        echo \# Первым аргументом принимает ключи:
                        echo \# -m для месячного бэкапа (хранятся 180 дней)
                        echo \# -w для недельного бэкапа (хранятся 30 дней)
                        echo \# -d для бэкапа за день (хранятся 7 дней)
                        exit
                        }

[ $# == 1 ] || echo Количество аргументов неверное, введите команду: "$0 --help"

# по ключу из первого аргумента скрипта определяем папку и срок хранения
case $1 in
        "-m")
                del=180 ; period="mothly"
                ;;
        "-w")
                del=30 ; period="weekley"
                ;;
        "-d")
                del=7 ; period="daily"
                ;;
esac

backdir="~/backup"
# заходим в папку в которой будет совершаться ротация
cd $backdir/$period
# определяем файлы которые хранились больше указанного времени
dellist=$(find -ctime +$del) 
# удаляем их
for i in $dellist
do
        rm $i
done

# дальше повторяем пример из методички:
backlist="~/backup/backlist.txt"
cat  "$backlist"  | xargs find | xargs tar -oc |  gzip -9c > $(date +"%Y%m%d")backup.tar.gz
cd ~-  

$ crontab -e
SHELL = /bin/sh
MAILTO = krotkolobrod@gmail.com
PATH = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/home/krotbrod/sandbox:/home/krotbrod/backup
0 0 1 * * $HOME/backup/back.sh -m 2>&1 >> $HOME/backup/out_err.txt
0 0 * * 0 $HOME/backup/back.sh -w 2>&1 >> $HOME/backup/out_err.txt
0 0 * * * $HOME/backup/back.sh -d 2>&1 >> $HOME/backup/out_err.txt

