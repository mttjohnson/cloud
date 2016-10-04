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
:: feature - varnish
########################################

# import gpg keys before installing anything
rpm --import $VAGRANT_DIR/etc/keys/RPM-GPG-KEY-Varnish.txt

if [[ ! -d /var/cache/yum/rpms ]]; then
    mkdir -p /var/cache/yum/rpms
fi
pushd /var/cache/yum/rpms

# redirect stderr -> stdin so info is logged
# ignore error codes for offline cache (where file does not exist the following commands should fail on rpm --checksig)
wget --timestamp https://repo.varnish-cache.org/redhat/varnish-4.1.el6.rpm 2>&1 || true

rpm --checksig varnish-4.1.el6.rpm

yum install -y varnish-4.1.el6.rpm

popd

yum update -y

yum install -y varnish

# rsync any overriden config files for this machine
if [[ -d $VAGRANT_DIR/guest/etc/varnish ]]; then
    mkdir -p /etc/varnish
    rsync -a $VAGRANT_DIR/guest/etc/varnish/ /etc/varnish/
    chown -R root:root /etc/varnish/
fi

if [[ -f $VAGRANT_DIR/guest/etc/sysconfig/varnish ]]; then
    cp $VAGRANT_DIR/guest/etc/sysconfig/varnish /etc/sysconfig/varnish
    chown root:root /etc/sysconfig/varnish
fi

# ensure each of the web services will start on boot
chkconfig varnish on
service varnish start
