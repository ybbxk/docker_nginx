FROM debian:jessie
RUN apt-get update && apt-get install -y ca-certificates build-essential wget libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev curl
RUN apt-get install -y unzip

ENV NGINX_VERSION=1.15.4
ENV OPENSSL_VERSION=1.1.0i

#COPY nginx-$NGINX_VERSION.tar.gz /home/nginx.tar.gz
#COPY openssl-$OPENSSL_VERSION.tar.gz /home/openssl-$OPENSSL_VERSION.tar.gz
RUN curl https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o /home/nginx.tar.gz
RUN curl https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz -o /home/openssl.tar.gz

WORKDIR /home/
RUN   mkdir nginx && tar xzf nginx.tar.gz --strip 1 -C nginx \
       && mkdir openssl && tar xzf openssl.tar.gz --strip 1 -C openssl \
       && cd nginx && ./configure \
       --prefix=/usr/local/nginx \
       --sbin-path=/usr/sbin/nginx \
       --conf-path=/etc/nginx/nginx.conf \
       --pid-path=/var/run/nginx.pid \
       --error-log-path=/var/log/nginx/error.log \
       --http-log-path=/var/log/nginx/access.log \
       --with-http_ssl_module \
       --with-http_v2_module \
       --with-openssl=../openssl \
       --with-http_realip_module \
       --with-http_stub_status_module \
       --with-threads \
       --with-http_sub_module \
       --with-ipv6 \
       && make \
       && make install

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

ADD  nginx.conf      /etc/nginx/nginx.conf
ADD  fastcgi.conf	/etc/nginx/fastcgi.conf
#ADD  keys      /etc/nginx/keys
#ADD  vhosts/*    /etc/nginx/conf.d/
RUN  rm -rf /etc/nginx/conf.d && ln -s /opt/nginx_conf /etc/nginx/conf.d
RUN  mkdir -p /opt/nginx/htdocs && mkdir -p /opt/log/nginx && mkdir -p /opt/log/nginx
RUN  chown -R www-data.www-data /opt/nginx/htdocs /opt/log/nginx
VOLUME ["/opt"]


EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

