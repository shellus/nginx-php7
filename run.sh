#!/bin/sh

set -e



service nginx start && service php-fpm start
echo "》》》》》》》欢迎使用shellus出品镜像《《《《《《《《"
#/usr/bin/supervisord -n -c /etc/supervisord.conf



