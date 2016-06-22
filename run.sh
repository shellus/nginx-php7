#!/bin/sh
#########################################################################
# File Name: start.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2015/12/13
#########################################################################
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/www

set -e
mkdir -p ${DATA_DIR}
cd ${DATA_DIR}

if [[ -n "$GIT" ]]; then
    git clone ${GIT} git_app
    cd git_app
    echo "git $GIT clone done"
else
    echo "User is $USER; not deinf GIT var"
fi

chown -R www:www .

/usr/bin/supervisord -n -c /etc/supervisord.conf
