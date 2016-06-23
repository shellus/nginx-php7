#!/bin/sh

set -e

/install_app.sh

/usr/bin/supervisord -n -c /etc/supervisord.conf

echo "》》》》》》》欢迎使用shellus出品镜像《《《《《《《《"

