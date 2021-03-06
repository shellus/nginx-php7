FROM centos:6.8

ENV NGINX_VERSION 1.11.1
ENV PHP_VERSION 7.0.7
ENV INSTALL_DIR /root/install
ENV PROVISION_DIR /root/provision
ENV HELPER_DIR /root/helper
ENV WWW_DIR /www

# Install Require Package
RUN yum install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    yum clean all

#Install PHP library
## libmcrypt-devel DIY
RUN yum install -y epel-release && \
    yum install -y wget \
    git \
    zlib \
    zlib-devel \
    openssl \
    openssl-devel \
    pcre-devel \
    libxml2 \
    libxml2-devel \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
    python-setuptools && \
    yum clean all

# Create DIRs
RUN mkdir $INSTALL_DIR \
    $PROVISION_DIR \
    $HELPER_DIR \
    $WWW_DIR

# Add Files
ADD provision $PROVISION_DIR
ADD helper $HELPER_DIR
ADD www $WWW_DIR

#Download nginx & php
RUN mkdir -p $INSTALL_DIR && cd $_ && \
    wget -c -O nginx.tar.gz http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    wget -O php.tar.gz http://php.net/distributions/php-$PHP_VERSION.tar.gz

#Add user
RUN groupadd -r www && \
    useradd -M -s /sbin/nologin -r -g www www

#Make install nginx
RUN cd $INSTALL_DIR && \
    tar -zxvf nginx.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    ./configure --prefix=/usr/local/nginx \
    --user=www --group=www \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --with-http_gzip_static_module && \
    make && make install && \
    cp $PROVISION_DIR/nginx.conf /usr/local/nginx/conf/nginx.conf && \
    ln -s /usr/local/nginx/conf/nginx.conf /etc/nginx.conf

#Make install php
RUN cd $INSTALL_DIR && \
    tar zvxf php.tar.gz && \
    cd php-$PHP_VERSION && \
    ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir=/usr/local/php/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mcrypt=/usr/include \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-session \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --enable-ipv6 \
    --disable-debug \
    --without-pear && \
    make && make install && \
    ln -s /usr/local/php/bin/php /usr/bin/php

# Conf PHP
RUN cd $INSTALL_DIR/php-$PHP_VERSION && \
    cp php.ini-production /usr/local/php/etc/php.ini && \
    ln -s /usr/local/php/etc/php.ini /etc/php.ini && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    ln -s /usr/local/php/etc/php-fpm.conf /etc/php-fpm.ini && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

# Conf Service
RUN cp $PROVISION_DIR/nginx /etc/init.d/nginx && \
    cp $PROVISION_DIR/php-fpm /etc/init.d/php-fpm && \
    chmod +x /etc/init.d/nginx && chmod +x /etc/init.d/php-fpm && \
    chkconfig nginx on && chkconfig php-fpm on

# Install Composer && Cahce Composer Packages
RUN php -r "readfile('https://getcomposer.org/installer');" | php && \
    mv composer.phar /usr/bin/composer && \
    composer config -g repo.packagist composer https://packagist.phpcomposer.com && \
    cd $HELPER_DIR/cache/ && \
    composer install --no-autoloader --no-scripts

#Install supervisor
RUN easy_install supervisor && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/sshd && \
    mkdir -p /var/run/supervisord && \
    cp $PROVISION_DIR/supervisord.conf /etc/supervisord.conf

#Add SSH
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    chown root:root /root/.ssh && \
    cp $PROVISION_DIR/id_rsa.pub /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys


#Remove files
RUN cd / && \
    rm -rf $INSTALL_DIR && \
    rm -rf $PROVISION_DIR && \
    rm -rf $HELPER_DIR/cache

# Add Script
ADD run.sh /run.sh
RUN chmod +x /*.sh

# Start it
ENTRYPOINT ["/run.sh"]
#CMD ["/install_app.sh"]


# Set port
EXPOSE 80
#EXPOSE 22

# Add Volume
#VOLUME /www


