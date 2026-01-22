# Вместо этого:
docker build -t zabbix-server:latest .

# Пишешь это:
make build

# Вместо этого:
docker run -d --name zabbix -p 10051:10051 zabbix-server:latest

# Пишешь это:
make run

# Вместо этого:
docker logs -f zabbix

# Пишешь это:
make logs