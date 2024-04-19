# Установка
apt install tcpdump -y

# Список интерфейсов:
tcpdump -D

# Захват всего трафика интерфейса:
tcpdump -i enp0s3

# Запись пакетов в файл
tcpdump -i enp0s3 -w dump.pcap

# Вывод данных в цифровой форме:
tcpdump -nni enp0s3

# Повышенная детализация:
tcpdump -nnvAi enp0s3

# Еще больше деталей
tcpdump -nnvvAi enp0s3

# Только 80 порт:
tcpdump 'tcp port 80' -nnvvAi enp0s3

# Только 3 первых пакета
tcpdump 'tcp port 80' -c 3 -i enp0s3

# Фильтр по хосту и порту
tcpdump 'tcp port 80 and host 192.168.0.88' -i enp0s3

# По порту источника
tcpdump 'tcp src port 80' -nnvi enp0s3

# Фильтр по подсети
tcpdump net 192.168.0.0/24


