FROM nginx:1.23-alpine
MAINTAINER Groots DevOps Team
RUN rm -rf /usr/share/nginx/html/*
COPY ./dist/industry-module /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
RUN ls -l
ADD nginx-temp.conf /etc/nginx/conf.d/client.conf
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf_original
