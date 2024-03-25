
########################################################## Nginx
// установка
sudo apt update
sudo apt install nginx -y

systemctl status nginx

// проверяем порты
ss -ntlp
sudo ss -ntlp

// конфиги тут
cd /etc/nginx
ll
nano /etc/nginx/nginx.conf

// Проверка корректности настроек
sudo nginx -t

// применение конфигов (если меняем что-то)
sudo systemctl reload nginx

// Конфиги сайта по умолчанию
nano /etc/nginx/sites-enabled/default
	 

##########################################################	Apache [30 минут]
4.2.1	Установка
//
sudo apt install apache2 -y

// проверка службы, портов
systemctl status apache2
sudo ss -ntlp


// Запустим Apache вместо Nginx на 80 порту
// остановим Nginx
sudo systemctl status nginx
sudo systemctl stop nginx

// запустим Apache
sudo systemctl start apache2
sudo systemctl status apache2

// проверим порты
sudo ss -ntlp

 

// конфиги тут
cd /etc/apache2
nano /etc/apache2/apache2.conf

// Проверка корректности настроек
sudo apachectl -t

// применение конфигов (если меняем что-то)
sudo systemctl reload apache2



4.2.3	Запуск на порту 9000
// меняем порт
sudo nano /etc/apache2/ports.conf
•	Поменяем порт на 9000

// правим сайт на порт 9000
sudo nano /etc/apache2/sites-enabled/000-default.conf

 

// проверим корректность конфигов
apachectl -t

// применим новые конфиги
sudo systemctl reload apache2
sudo systemctl status apache2

sudo ss -ntlp
	Убедились, что apache бегает теперь на порту 9000


##########################################################	Reverse proxy
•	В Nginx настраиваем проброс 

sudo nano /etc/nginx/sites-enabled/default
location / {
#               try_files $uri $uri/ =404;
	proxy_pass http://localhost:9000;
	proxy_set_header Host $host;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header X-Real-IP $remote_addr;
}

sudo nginx -t
sudo systemctl reload nginx



##########################################################	Балансировка Nginx
sudo nano sites-enabled/000-default.conf

<VirtualHost *:9000>
	#ServerName www.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/apache2/9000

	ErrorLog /var/log/apache2/error.log
	CustomLog /var/log/apache2/access.log combined

</VirtualHost>

####################################################

Listen 9001
<VirtualHost *:9001>
	#ServerName www.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/apache2/9001

	ErrorLog /var/log/apache2/error1.log
	CustomLog /var/log/apache2/access1.log combined

</VirtualHost>

####################################################

Listen 9002
<VirtualHost *:9002>
	#ServerName www.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/apache2/9002

	ErrorLog /var/log/apache2/error2.log
	CustomLog /var/log/apache2/access2.log combined

</VirtualHost>


// проверим, перезапустим, проверим
sudo apachectl -t
sudo systemctl reload apache2
sudo ss -ntlp

 

// настроим саму балансировку в Nginx
cd /etc/nginx
tree
sudo nano /etc/nginx/sites-enabled/default

upstream backend {
        server 127.0.0.1:9000;
        server 127.0.0.1:9001;
        server 127.0.0.1:9002;
}
...
location / {
        proxy_pass http://backends;
...
}
...

sudo nginx -t
sudo systemctl reload nginx

•	http://localhost:80

 


// Опции балансировки
Существует несколько методов балансировки:
round-robin – используется по умолчанию, нагрузка распределяется равномерно между серверами с учетом веса. Запросы уходят к серверам по порядку
least_conn – запросы поступают к менее загруженным серверам.
// least_conn
upstream backends {
    least_conn;
    server 127.0.0.1:9000;
    server 127.0.0.1:9001;
    server 127.0.0.1:9002;
}	


ip_hash — запросы распределяются по серверам на основе IP-адресов клиентов, т.е. запросы одного и того же клиента будут всегда передаваться на один и тот же сервер, пример:
// ip_hash
upstream backends {
    ip_hash;
    server 127.0.0.1:9000;
    server 127.0.0.1:9001;
    server 127.0.0.1:9002;
}


Если в группе серверов некоторые производительнее остальных, то следует воспользоваться механизмом весов. Это условная единица, которая позволяет направлять наибольшую нагрузку на одни сервера и ограждать от нее другие.
// weight
upstream backends {
    server 127.0.0.1:9000;
    server 127.0.0.1:9001 weight=3;
    server 127.0.0.1:9002;
}