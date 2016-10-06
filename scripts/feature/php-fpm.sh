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
:: feature - php-fpm
########################################

# install php and cross-version dependencies
yum $extra_repos install -y php-fpm

# rsync any overriden config files for this machine
if [[ -d $VAGRANT_DIR/guest/etc/php-fpm.d ]]; then
    rsync -a $VAGRANT_DIR/guest/etc/php-fpm.d/ /etc/php-fpm.d/
    chown -R root:root /etc/php-fpm.d/    
fi

# ensure each of the web services will start on boot
chkconfig php-fpm on
service php-fpm start
