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
:: feature - letsencrypt
########################################

mkdir -p /etc/letsencrypt/

# add github.com key so non-interactive clones will work later in provisioning
if [[ ! -f ~/.ssh/known_hosts ]] || [[ -z "$(grep github ~/.ssh/known_hosts)" ]]; then
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
fi

git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

# rsync any overriden config files for this machine
if [[ -d $VAGRANT_DIR/guest/etc/letsencrypt/configs ]]; then
    rsync -a $VAGRANT_DIR/guest/etc/letsencrypt/ /etc/letsencrypt/
    chown -R root:root /etc/letsencrypt/
fi

# Build required directories
mkdir -p /var/www/html/letsencrypt
chmod g+s /var/www/html/letsencrypt
chgrp nginx /var/www/html/letsencrypt

# installs all deps and prints available plugin info
/opt/letsencrypt/certbot-auto --non-interactive plugins
