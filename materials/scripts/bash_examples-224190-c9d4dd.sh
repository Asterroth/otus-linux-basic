####### Скрипт подсчета файлов

#!/bin/bash

find /etc -type f | wc -l


###### Запуск
# 1 - без прав
bash count_files.sh

# 2 - с правом на исполнение
chmod +x count_files.sh

# Относительный путь
./count_files.sh

# Абсолютный путь
/home/db/count_files.sh

# 3 - из директории для исполняемых файлов
echo $PATH
/usr/local/bin
cp ./count_files.sh /usr/local/bin/

############### Параметры

# count_files.sh
find $1 -type f | wc -l

bash count_files.sh /usr
bash count_files.sh /etc
bash count_files.sh


################ Переменные
training=Python
TRAINING=Linux

echo $TRAINING
echo $training
echo ${TRAINING}
echo ${training}

# count_files.sh
directory=$1
find $directory -type f | wc -l

############ Возврат значений из команд

# count_files.sh
directory=$1
num_of_files=$(find $directory -type f | wc -l)
echo $num_of_files

############ Ограничение на имена

1var=2

var =2

var = 2

VaR=2

Var1=2

var_=2

var_test=2

перем1=2

############ Специальные переменные

echo $HOSTNAME - имя хоста
echo $HOME - домашняя директория
echo $PWD - текущая директория
echo $UID - идентификатор пользователя
echo $$ - идентификатор процесса
echo $PS1 - вид командной строки
echo $? - код возврата

############ Подстановки

echo {0..10}

mkdir test{a..e}

echo {{a..e},z}

mkdir test{001..100}

echo ~

echo ~+

echo ~-

############ Циклы

#!/bin/bash

c=10

while [ $c -ge 0 ] 
do 
	echo "Test"
	let "c = c - 1"
done

for h in {01..24}
do
	echo $h
done

#!/bin/bash
for (( c=1; c<=5; c++ ))
do  
   echo "Попытка номер $c"
done

##### SELinux

sestatus

getenforce

# Отключить
sudo setenforce 0

# Конфиг: /etc/selinux/config поставить SELINUX в disabled

# Включить
sudo setenforce 1

