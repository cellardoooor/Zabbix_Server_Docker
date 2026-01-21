FROM debian:12-slim

ENV ZABBIX_VERSION=6.0.27

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      wget \
      gnupg \
      build-essential \
      pkg-config \
      libpq-dev \
      libssl-dev \
      libxml2-dev \
      libevent-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN wget https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${ZABBIX_VERSION}.tar.gz && \
    tar -xzf zabbix-${ZABBIX_VERSION}.tar.gz

    RUN cd zabbix-${ZABBIX_VERSION} && \
    ./configure \
      --enable-server \
      --with-postgresql \
      --with-openssl \
      --with-libxml2 && \
    make && \
    make install

    RUN groupadd -r zabbix && \
    useradd -r -g zabbix zabbix && \
    mkdir -p /etc/zabbix /var/log/zabbix && \
    chown -R zabbix:zabbix /etc/zabbix /var/log/zabbix

COPY zabbix_server.conf /etc/zabbix/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER zabbix
ENTRYPOINT ["/entrypoint.sh"]
