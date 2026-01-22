-- Создаем пользователя Zabbix (если не создан Docker'ом)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'zabbix') THEN
        CREATE USER zabbix WITH PASSWORD 'zabbix';
    END IF;
END
$$;

-- Создаем базу данных
CREATE DATABASE zabbix WITH OWNER = zabbix ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';

-- Даем все права пользователю zabbix на базу zabbix
GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;