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
:: feature - nginx
########################################

# import gpg keys before installing anything
rpm --import $VAGRANT_DIR/etc/keys/RPM-GPG-KEY-nginx.txt

if [[ ! -d /var/cache/yum/rpms ]]; then
    mkdir -p /var/cache/yum/rpms
fi
pushd /var/cache/yum/rpms

# redirect stderr -> stdin so info is logged
# ignore error codes for offline cache (where file does not exist the following commands should fail on rpm --checksig)
wget --timestamp http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm 2>&1 || true

rpm --checksig nginx-release-centos-6-0.el6.ngx.noarch.rpm

yum install -y nginx-release-centos-6-0.el6.ngx.noarch.rpm

popd

yum update -y

yum install -y nginx

# rsync any overriden config files for this machine
if [[ -d $VAGRANT_DIR/guest/etc/nginx ]]; then
    rsync -a $VAGRANT_DIR/guest/etc/nginx/ /etc/nginx/
    chown -R root:root /etc/nginx/
fi

# create dir where dhparam.pem and ssl cert files are stored
mkdir -p /etc/nginx/ssl
chmod 700 /etc/nginx/ssl
[[ $(ls -A /etc/nginx/ssl) ]] && chmod -R 600 /etc/nginx/ssl/*

# ensure each of the web services will start on boot
chkconfig nginx on
service nginx start

