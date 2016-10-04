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
:: feature - mysqld
########################################

# import gpg keys before installing anything
rpm --import $VAGRANT_DIR/etc/keys/RPM-GPG-KEY-MySql.txt

if [[ ! -d /var/cache/yum/rpms ]]; then
    mkdir -p /var/cache/yum/rpms
fi
pushd /var/cache/yum/rpms

# redirect stderr -> stdin so info is logged
# ignore error codes for offline cache (where file does not exist the following commands should fail on rpm --checksig)
wget --timestamp http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm 2>&1 || true

rpm --checksig mysql-community-release-el6-5.noarch.rpm

## only setup mysql community rpm if mysql 56 is requested
[ "$MYSQL_VERSION" == "56" ] && yum install -y /var/cache/yum/rpms/mysql-community-release-el6-5.noarch.rpm

popd

yum update -y

# copy guest etc configs
if [[ -f /etc/my.cnf ]] && [[ -f ./guest/etc/my.cnf ]]; then
    mv /etc/my.cnf /etc/my.cnf.provision-bak
    cp $VAGRANT_DIR/guest/etc/my.cnf /etc/my.cnf
fi

# rsync any overriden config files for this machine
if [[ -d $VAGRANT_DIR/guest/etc/my.cnf.d ]]; then
    mkdir -p /etc/my.cnf.d/
    rsync -a $VAGRANT_DIR/guest/etc/my.cnf.d/ /etc/my.cnf.d/
    chown -R root:root /etc/my.cnf.d/
fi

yum install -y mysql-server

chkconfig mysqld on

# start servcie to initialize data directory and then stop for remount
service mysqld start 2>&1   # quiet chatty data dir init output

mysql -uroot -e "
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
"
