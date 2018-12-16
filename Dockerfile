FROM nginx:alpine
RUN apk --no-cache add shadow \
    && usermod -u 1000 nginx \
    && groupmod -g 1000 nginx
