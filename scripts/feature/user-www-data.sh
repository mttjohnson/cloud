#!/usr/bin/env bash
##
 # Copyright © 2016 by Matt Johnson. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # https://github.com/mttjohnson
 ##

set -e

source ./scripts/lib/utils.sh

########################################
:: feature - user www-data
########################################

adduser -rUm -G sshusers www-data

# create a key-pair to be used as a deploy key as needed
[[ ! -f ~www-data/.ssh/id_rsa ]] && sudo -u www-data ssh-keygen -N '' -t rsa -f ~www-data/.ssh/id_rsa

# authorize public keys on www-data user as well, using either provided authorized_keys file or vagrant supplied key
if [[ -f $VAGRANT_DIR/guest/etc/ssh/authorized_keys ]]; then
    cat $VAGRANT_DIR/guest/etc/ssh/authorized_keys >> ~www-data/.ssh/authorized_keys
else
    cat ~/.ssh/authorized_keys >> ~www-data/.ssh/authorized_keys
fi

chown www-data:www-data ~www-data/.ssh/authorized_keys
chmod 600 ~www-data/.ssh/authorized_keys

# start user in the web root when logging in
mkdir -p /var/www/html
echo cd /var/www/html >> ~www-data/.bash_profile

# setup a phpinfo file in webroot for review purposes post-provisioning
mkdir -p /var/www/html/current/pub
echo '<?php phpinfo();' > /var/www/html/current/pub/index.php
chown -R www-data:www-data /var/www/html

# configure proper group membership and ownership (apache user comes in with the php-fpm rpm)
usermod -a -G www-data nginx

chgrp -R www-data /var/lib/php      # ditch apache group

