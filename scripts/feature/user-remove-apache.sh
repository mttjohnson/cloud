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

# apache user comes in with the php-fpm rpm
userdel apache

chown -R root /var/log/php-fpm      # ditch apache ownership
chgrp -R root /var/lib/php      # ditch apache group

