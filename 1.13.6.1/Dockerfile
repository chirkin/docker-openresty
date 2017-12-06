#
# Openresty
#

FROM debian:jessie

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color \
	OPENRESTY_VERSION=1.13.6.1 \
	NGX_CONFIG=/etc/nginx

RUN apt-get update && apt-get -y install \
  build-essential \
  curl \
  libreadline-dev \
  libncurses5-dev \
  libpcre3-dev \
  libssl-dev \
  perl \
  wget \
	git \
  libpq-dev \
  luarocks

RUN apt-get -y install \
	postgresql-client-9.4

#COPY openresty-${OPENRESTY_VERSION}.tar.gz openresty-${OPENRESTY_VERSION}.tar.gz

# Compile openresty from source.
RUN \
  wget http://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
  tar -xzvf openresty-*.tar.gz && \
  rm -f openresty-*.tar.gz && \
	git clone https://github.com/evanmiller/mod_zip.git && \
  cd openresty-* && \
  # change nginx version to fake
  sed -i -- 's/^#define NGINX_VER .*/#define NGINX_VER "nginx"/g' bundle/nginx-*/src/core/nginx.h && \
  ./configure --with-http_sub_module \
              --with-http_gzip_static_module \
              --with-http_stub_status_module \
              --with-http_iconv_module \
							--with-luajit \
              --with-http_postgres_module \
              --add-module=../mod_zip && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf openresty-* && \
	rm -rf mod_zip && \
  ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
  ldconfig

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log
RUN ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

#RUN groupadd -r -g 1000 nginx && useradd -r -u 1000 -g nginx nginx

RUN luarocks install pgmoon
RUN luarocks install luafilesystem
RUN luarocks install lua-resty-auto-ssl

ENV GOSU_VERSION 1.10
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove ca-certificates wget

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx"]
