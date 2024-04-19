# Рабора с текстовыми логами

# Фильтрация лога
cat messages | grep err | grep -P '\d{2}:\d{2}:00'

# Последние 10 строк лога
tail -n 10 messages

# Первые 10 строк лога
head -n 10 messages

# Просмотр сообщений в реальном времени
tail -f messages

# Journald

# Проверка формата времени
timedatectl status
sudo timedatectl set-timezone zone

# Логи с момента загрузки
journalctl -b

# Сохрание логов между загрузками системы
sudo mkdir -p /var/log/journal
sudo nano /etc/systemd/journald.conf

[Journal]
Storage=persistent

# Фильтрация по времени
journalctl --since "2022-01-01 17:15:00"
journalctl --since "2022-01-01 17:15:00" --until "2022-01-02 17:15:00"
journalctl --since yesterday
journalctl --since 09:00 --until "1 hour ago"

# Фильтрация по юниту
journalctl -u nginx.service

# Фильтрация по приоритету
journalctl -p err -b

# Форматирование в JSON
journalctl -b -u nginx -o json-pretty


#############################################################
ELK setup
#############################################################

sudo apt update
sudo apt install default-jdk -y

java -version

# Качаем пакеты (или используем репозиторий)
# https://www.elastic.co/guide/en/elasticsearch/reference/8.9/deb.html
https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/kibana/kibana-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/logstash/logstash-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-8.9.1-amd64.deb

# Устанавливаем ES
sudo dpkg -i elasticsearch-8.9.1-amd64.deb

# Устанавливаем лимиты памяти для виртуальной машины Java
cat > /etc/elasticsearch/jvm.options.d/jvm.options

-Xms1g
-Xmx1g

# Конфигурация ES
nano /etc/elasticsearch/elasticsearch.yml
##############################################
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch

xpack.security.enabled: false
xpack.security.enrollment.enabled: true

xpack.security.http.ssl:
  enabled: false
  keystore.path: certs/http.p12

xpack.security.transport.ssl:
  enabled: false
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
cluster.initial_master_nodes: ["elk"]

http.host: 0.0.0.0

##############################################
# Старт сервиса
sudo systemctl daemon-reload
sudo systemctl enable --now elasticsearch.service

# Проверка
curl http://localhost:9200

# Установка kibana
dpkg -i kibana-8.9.1-amd64.deb

# Копируем сертификаты
#cp -R /etc/elasticsearch/certs /etc/kibana
#chown -R root:kibana /etc/kibana/certs

sudo systemctl daemon-reload
sudo systemctl enable --now kibana.service

sudo nano /etc/kibana/kibana.yml
server.port: 5601
server.host: "0.0.0.0"

systemctl restart kibana

#############################################
# Установка Logstash
dpkg -i logstash-8.9.1-amd64.deb

systemctl enable --now logstash.service

######
# logstash config
sudo nano /etc/logstash/logstash.yml

path.config: /etc/logstash/conf.d

cat > /etc/logstash/conf.d/logstash-nginx-es.conf
####################################################
input {
    beats {
        port => 5400
    }
}

filter {
 grok {
   match => [ "message" , "%{COMBINEDAPACHELOG}+%{GREEDYDATA:extra_fields}"]
   overwrite => [ "message" ]
 }
 mutate {
   convert => ["response", "integer"]
   convert => ["bytes", "integer"]
   convert => ["responsetime", "float"]
 }
 date {
   match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
   remove_field => [ "timestamp" ]
 }
 useragent {
   source => "agent"
 }
}

output {
 elasticsearch {
   hosts => ["http://localhost:9200"]
   #cacert => '/etc/logstash/certs/http_ca.crt'
   #ssl => true
   index => "weblogs-%{+YYYY.MM.dd}"
   document_type => "nginx_logs"
 }
 stdout { codec => rubydebug }
}
########################################################

systemctl restart logstash.service

# Установка filebeat
dpkg -i filebeat-8.9.1-amd64.deb 

sudo nano /etc/filebeat/filebeat.yml

# Закомментарить output.elasticsearch
##########################################
filebeat.inputs:
- type: filestream
  paths:
    - /var/log/nginx/*.log

  enabled: true
  exclude_files: ['.gz$']
  prospector.scanner.exclude_files: ['.gz$']

output.logstash:
  hosts: ["localhost:5400"]
###########################################
systemctl restart filebeat

sudo filebeat modules enable nginx

##############################
# Добавляем индексные шаблоны Stack management - Index management
http://192.168.122.229:5601/app/management/data/index_management/indices

# Analytics - Discover - Create data view - weblogs* (слева вверху)

# Analytics - Dashboard - Create

# Bar horizontal - request.keyword host.ip.keyword
# Donut - slice by response, size by #records

# Metricbeat настройка
dpkg -i metricbeat-8.9.1-amd64.deb

systemctl enable --now metricbeat

# https://www.elastic.co/guide/en/beats/metricbeat/current/load-kibana-dashboards.html

metricbeat setup --dashboards


