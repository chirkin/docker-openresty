#
# Openresty
#

FROM debian:jessie


MAINTAINER Aleksey Chirkin

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color \
	OPENRESTY_VERSION=1.9.7.2 \
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
  libpq-dev

RUN apt-get -y install \
	postgresql-client-9.4

# Compile openresty from source.
RUN \
  wget http://openresty.org/download/ngx_openresty-${OPENRESTY_VERSION}.tar.gz && \
  tar -xzvf ngx_openresty-*.tar.gz && \
  rm -f ngx_openresty-*.tar.gz && \
	git clone https://github.com/evanmiller/mod_zip.git && \
  cd ngx_openresty-* && \
  ./configure --with-http_sub_module \
              --with-http_gzip_static_module \
              --with-http_stub_status_module \
              --with-http_iconv_module \
              --with-lua51 \
							--with-luajit \
              --with-http_postgres_module \
              --add-module=../mod_zip && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf ngx_openresty-* && \
	rm -rf mod_zip && \
  ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
  ldconfig

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log
RUN ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

RUN groupadd -r nginx && useradd -r -g nginx nginx

VOLUME ["/var/cache/nginx"]

ADD docker-entrypoint.sh /

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx"]
