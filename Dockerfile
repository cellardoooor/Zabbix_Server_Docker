FROM debian:12-slim

ENV ZABBIX_VERSION=6.0.27

# Добавляем zlib-dev
RUN apt-get update && \
    apt-get install -y \
      wget \
      gcc \
      g++ \
      make \
      automake \
      autoconf \
      libtool \
      pkg-config \
      # PostgreSQL
      postgresql-common \
      postgresql-15 \
      postgresql-server-dev-15 \
      libpq-dev \
      # SSL
      libssl-dev \
      openssl \
      # XML
      libxml2-dev \
      # CURL
      libcurl4-openssl-dev \
      # PCRE
      libpcre3-dev \
      # Event
      libevent-dev \
      # ZLIB - ЭТО ВАЖНО!
      zlib1g-dev

WORKDIR /build

RUN wget https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${ZABBIX_VERSION}.tar.gz && \
    tar -xzf zabbix-${ZABBIX_VERSION}.tar.gz

RUN cd zabbix-${ZABBIX_VERSION} && \
    ./configure \
      --enable-server \
      --with-postgresql \
      --with-openssl \
      --with-libxml2 \
      --with-libcurl \
      --with-libpcre \
      --with-libevent 2>&1 | tee configure.log && \
    echo "=== Проверяем успешность ===" && \
    if [ -f Makefile ]; then \
      echo "Makefile создан успешно!"; \
    else \
      echo "Ошибка! Показываю конец лога:"; \
      tail -30 configure.log; \
      exit 1; \
    fi

RUN cd zabbix-${ZABBIX_VERSION} && \
    make -j$(nproc) && \
    make install && \
    # Очистка после установки для уменьшения размера образа
    cd / && \
    rm -rf /build/*

# Создаем пользователя и директории
RUN groupadd -r zabbix && \
    useradd -r -g zabbix zabbix && \
    mkdir -p /etc/zabbix /var/log/zabbix && \
    chown -R zabbix:zabbix /etc/zabbix /var/log/zabbix

COPY zabbix_server.conf /etc/zabbix/
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 10051
USER zabbix
ENTRYPOINT ["/docker-entrypoint.sh"]
