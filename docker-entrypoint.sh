#!/bin/bash
set -e

# Функция для ожидания PostgreSQL
wait_for_postgres() {
    echo "Ожидание PostgreSQL на ${DB_HOST:-postgres}:${DB_PORT:-5432}..."
    
    until pg_isready -h "${DB_HOST:-postgres}" -p "${DB_PORT:-5432}" -U "${DB_USER:-zabbix}"; do
        echo "PostgreSQL недоступен, ждем 5 секунд..."
        sleep 5
    done
    
    echo "PostgreSQL доступен!"
}

# Функция для инициализации базы данных
init_database() {
    local db_name="${DB_NAME:-zabbix}"
    local db_user="${DB_USER:-zabbix}"
    local db_password="${DB_PASSWORD:-zabbix}"
    
    echo "Проверка базы данных ${db_name}..."
    
    # Проверяем, существует ли база данных
    if ! PGPASSWORD="${db_password}" psql -h "${DB_HOST:-postgres}" -p "${DB_PORT:-5432}" -U "${db_user}" -d "${db_name}" -c "SELECT 1" >/dev/null 2>&1; then
        echo "База данных ${db_name} не существует. Создаем..."
        
        # Создаем базу данных если нужно
        if ! PGPASSWORD="${db_password}" psql -h "${DB_HOST:-postgres}" -p "${DB_PORT:-5432}" -U "${db_user}" -d "postgres" -c "SELECT 1 FROM pg_database WHERE datname='${db_name}'" | grep -q 1; then
            echo "Создаем базу данных ${db_name}..."
            PGPASSWORD="${db_password}" psql -h "${DB_HOST:-postgres}" -p "${DB_PORT:-5432}" -U "${db_user}" -d "postgres" -c "CREATE DATABASE ${db_name} OWNER ${db_user} ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';"
        fi
        
        # Импортируем схему Zabbix
        echo "Импортируем схему Zabbix..."
        zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz 2>/dev/null || \
        gunzip -c /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | \
            PGPASSWORD="${db_password}" psql -h "${DB_HOST:-postgres}" -p "${DB_PORT:-5432}" -U "${db_user}" -d "${db_name}" -q
    else
        echo "База данных ${db_name} уже существует."
    fi
}

# Главная функция
main() {
    # Ждем PostgreSQL
    wait_for_postgres
    
    # Инициализируем базу данных (опционально)
    # init_database
    
    echo "Запуск Zabbix Server..."
    
    # Запускаем Zabbix Server
    exec /usr/local/sbin/zabbix_server \
        -c /etc/zabbix/zabbix_server.conf \
        -f
}

# Запускаем главную функцию
main "$@"