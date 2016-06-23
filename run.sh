#!/bin/sh

set -e

/usr/bin/supervisord -n -c /etc/supervisord.conf

echo "》》》》》》》欢迎使用shellus出品镜像《《《《《《《《"

/install_app.sh