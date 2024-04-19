# Просмотр сетевых интерфейсов
ip a
ip link

# Статистика
ip -s addr show

# Socket stat
ss -ntlp
ss -ntulp
ss -tulpan
ss -lt

apt install net-tools
netstat -tulpan

# Проверка подключения по портам
apt install nmap
nmap otus.ru

# TCP
nc -zvw1 8.8.8.8 80

# UDP
nc -u 8.8.8.8 53

# Просмотр маршрутов
ip route show

# Просмотр DNS-серверов
resolvectl
resolvectl dns

# Статистика по интерфейсу
sudo ip -s addr show enp0s3

# Работа с маршрутами
# Удаляем
ip route delete default via 192.168.0.1

# Возвращаем
ip route add default via 192.168.0.1 dev enp0s3

# Проверка по ICMP
ping -i 0.1 -c 5 8.8.8.8

# Добавляем IP к интерфейсу
sudo ip addr add 192.168.0.9/255.255.255.0 broadcast 192.168.0.255 dev enp0s3

sudo ip route show

# Прописываем дефолтный маршрут
sudo ip route add default via 192.168.0.254

# Управление интерфейсом
ip link set enp0s3 down
ip link set enp0s3 up

# Работа с DNS
host -t a otus.ru
host -t a otus.ru 8.8.8.8
dig otus.ru
nslookup ya.ru

# Системная конфигурация DNS-серверов
cat /etc/resolv.conf
# Локальный файл с именами
cat /etc/hosts


# Netplan
# Тестировать настройки
sudo netplan try
# Применить настройки
sudo netplan apply
# Создать конфиги
sudo netplan generate

