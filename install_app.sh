#!/usr/bin/env bash

cd /www && \
    curl -L -o shcms.tar.gz https://github.com/shellus/shcms/archive/v2.0.0.tar.gz && \
    tar -zxvf shcms.tar.gz && \
    cd shcms-2.0.0 && \
    composer install && \
    cp .env.example .env && \
    sed -i "s/DB_HOST=.*/DB_HOST=mysql-shellus.myalauda.cn/" .env && \
    sed -i "s/DB_PORT=.*/DB_PORT=55620/" .env && \
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=shcms/" .env && \
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=shellus/" .env && \
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=a7245810/" .env && \
    sed -i "s/root[ ][ ]*\/.*/root \/www\/shcms-2.0.0\/public;/" /usr/local/nginx/conf/nginx.conf && \
    supervisorctl restart nginx && \
    chown -R www:www /www