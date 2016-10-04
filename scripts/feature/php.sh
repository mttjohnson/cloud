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
:: feature - php
########################################

# import gpg keys before installing anything
rpm --import $VAGRANT_DIR/etc/keys/RPM-GPG-KEY-remi.txt

if [[ ! -d /var/cache/yum/rpms ]]; then
    mkdir -p /var/cache/yum/rpms
fi
pushd /var/cache/yum/rpms

# redirect stderr -> stdin so info is logged
# ignore error codes for offline cache (where file does not exist the following commands should fail on rpm --checksig)
wget --timestamp http://rpms.famillecollet.com/enterprise/remi-release-6.rpm 2>&1 || true

rpm --checksig remi-release-6.rpm

yum install -y remi-release-6.rpm

popd

yum update -y

# install php and cross-version dependencies
yum $extra_repos install -y php-cli php-opcache \
    php-mysqlnd php-mhash php-curl php-gd php-intl php-mcrypt php-xsl php-mbstring php-soap php-bcmath php-zip

# phpredis does not yet have php7 support
[[ "$PHP_VERSION" < 70 ]] && yum $extra_repos install -y php-pecl-redis

# rsync any overriden config files for this machine
if [[ -d $VAGRANT_DIR/guest/etc/php.d ]]; then
    rsync -a $VAGRANT_DIR/guest/etc/php.d/ /etc/php.d/
    chown -R root:root /etc/php.d/
fi
