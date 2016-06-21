#!/bin/sh
#########################################################################
# File Name: start.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2015/12/13
#########################################################################
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/data/www

set -e

if [[ -n "$GIT" ]]; then
    cd ${DATA_DIR}
    cd ..
    rmdir ${DATA_DIR}
    git clone ${GIT} www
    chown -R www.www ${DATA_DIR}
    echo "git $GIT clone done"
else
    echo "User is $USER"
fi

/usr/bin/supervisord -n -c /etc/supervisord.conf
