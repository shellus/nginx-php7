#!/bin/sh

set -e

/install_app.sh

echo "》》》》》》》欢迎使用shellus出品镜像《《《《《《《《"

/usr/bin/supervisord -n -c /etc/supervisord.conf



