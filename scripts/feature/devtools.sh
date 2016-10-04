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
:: feature - devtools
########################################

npm install -g grunt-cli

# install composer
wget https://getcomposer.org/download/1.1.2/composer.phar -O /usr/local/bin/composer 2>&1
chmod +x /usr/local/bin/composer

# install n98-magerun
wget http://files.magerun.net/n98-magerun-latest.phar -O /usr/local/bin/n98-magerun 2>&1
wget http://files.magerun.net/n98-magerun2-latest.phar -O /usr/local/bin/n98-magerun2 2>&1

chmod +x /usr/local/bin/n98-magerun
chmod +x /usr/local/bin/n98-magerun2

ln -s /usr/local/bin/n98-magerun /usr/local/bin/mr
ln -s /usr/local/bin/n98-magerun2 /usr/local/bin/mr2