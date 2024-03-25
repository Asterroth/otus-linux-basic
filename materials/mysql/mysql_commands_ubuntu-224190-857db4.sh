# mysql root pass
Testpass1$

# Устанавливаем MySQL
apt install mysql-server-8.0

# Запускаем
systemctl start mysql

# Проверка портов
ss -ntlp

# Ставим имя хоста
hostnamectl set-hostname mysql-master
reboot


# Запускаем скрипт безопасности для MySQL
mysql_secure_installation

# Заходим в root-аккаунт
sudo mysql

# Просмотр пользователй в MySQL
use mysql;

SELECT * FROM user WHERE User='root';

SELECT * FROM user WHERE User='root'\G

# Устанавливаем пароль
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'caching_sha2_password' BY 'Testpass1$';

# 5.7 версия
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'Testpass1$';

# Процессы

ps ax | grep mysqld

# Потоки
ps -eLf | grep mysqld

# Файлы
ls -l /var/lib/mysql

# Тип бинлога
show variables like '%binlog%';

# Найти server_id
SELECT @@server_id;

# Начинаем слушать на всех IP /etc/my.cnf (не нужно на CentOS 7)
bind-address = 0.0.0.0

#####################################################
# На Мастере
#####################################################

# Создаём пользователя для реплики
CREATE USER repl@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'oTUSlave#2020'; 
# Даём ему права на репликацию
GRANT REPLICATION SLAVE ON *.* TO repl@'%';
# Сбрасываем кэш привилегий (не обязательно)
# FLUSH PRIVILEGES;

# Смотрим пользователей
SELECT User, Host FROM mysql.user;

# Закрываем и блокируем все таблицы
FLUSH TABLES WITH READ LOCK;

# Смотрим статус Мастера
SHOW MASTER STATUS;

######################################################
# На Слейве
######################################################

# Если клонировали машину с мастера, обновляем auto.cnf
rm /var/lib/mysql/auto.cnf
systemctl restart mysql

# Смотрим статус Мастера
SHOW MASTER STATUS;
sudo nano /etc/my.cnf

server_id = 2

systemctl restart mysql

SHOW GLOBAL VARIABLES LIKE 'caching_sha2_password_public_key_path';
SHOW STATUS LIKE 'Caching_sha2_password_rsa_public_key'\G

# Конфиг Source
[mysqld]
server-id = 1
log-bin = mysql-bin
binlog_format = row
gtid-mode=ON
enforce-gtid-consistency
log-replica-updates


# Конфиг Replica
[mysqld]
server-id = 2
log-bin = mysql-bin
relay-log = relay-log-server
read-only = ON
gtid-mode=ON
enforce-gtid-consistency
log-replica-updates


# необходимо получить публичный ключ
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST='192.168.0.10', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='binlog.000005', MASTER_LOG_POS=688, GET_MASTER_PUBLIC_KEY = 1;
START SLAVE;
show replica status\G

# GTID
STOP REPLICA;
CHANGE REPLICATION SOURCE TO SOURCE_HOST='mysql8master', SOURCE_USER='repl', SOURCE_PASSWORD='Slave#2023', SOURCE_AUTO_POSITION = 1, GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;


# https://dev.mysql.com/doc/refman/8.0/en/replica-logs-relaylog.html
# можем настроить наш relay.log
show variables like '%relay%';

# посмотрим статусы репликации
use performance_schema;
show tables like '%replic%';
show variables like '%log_bin%';
show variables like '%binlog%';
show variables like '%read%';


# КОМАНДЫ ДЛЯ УПРАВЛЕНИЯ СОСТОЯНИЕМ
STOP REPLICA;
START REPLICA;

# Создание таблицы
create table test_tbl (id int);

# Добавляем строчки
insert into test_tbl values (2),(3),(4);

# варианты разрешения конфликтов
1. удалить на слейве блокирующую запись
2. STOP SLAVE;
RESET SLAVE;
SHOW SLAVE STATUS; # на мастере
# новый номер позиции в бинлоге

START SLAVE;

3. скипаем 1 ошибку
stop slave; 
set global sql_slave_skip_counter=1; 
start slave;

# скрипт избавления от дубликатов при репликации
while [ 1 ]; do      
if [ `mysql -uroot -ptest -e"show slave status \G;" | grep "Duplicate entry" | wc -l` -eq 2 ] ; then          
mysql -uroot -ptest -e "stop slave; set global sql_slave_skip_counter=1; start slave;";      
fi;      
mysql -uroot -ptest -e "show slave status\G";  
done

4. можно добавить в конфиг игнор ошибки при репликации
ну для duplicate entry например ошибка номер 1062
в конфиг добавляется
slave-skip-errors = 1062

################### Бекапы
mysqldump --help

# Бекап без создания таблиц
mysqldump --all-databases --no-create-info -u root -p > dump-data.sql

# C сохранением позиции бинлога
mysqldump -h 10.128.15.220 -p --all-databases --events --routines --master-data=2 > dump_file

# Скачивание бинлогов
# стандартный бэкап 1 файла
mysqlbinlog -R -h 10.128.15.201 -p --raw binlog.000001

# бэкапы без остановки начиная с 1 файла
mysqlbinlog -R -h 10.128.15.201 -p --raw --stop-never binlog.000001

# заливаем данные
mysql -u root -p < dump-data.sql

# Проигрываем изменение из бинлога
mysqlbinlog --start-position=4596 binlog.000004 | mysql
