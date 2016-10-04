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
:: feature - npm
########################################

yum install -y npm --disableexcludes=all
npm -g config set cache /var/cache/npm
npm -g config set cache-min 86400

# fix npm install problem by overwriting symlink with copy of linked version
if [[ -L /usr/lib/node_modules/inherits ]]; then
    inherits="$(readlink -f /usr/lib/node_modules/inherits)"
    rm -f /usr/lib/node_modules/inherits
    cp -r "$inherits" /usr/lib/node_modules/inherits
fi
