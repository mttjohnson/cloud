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
:: feature - redis
########################################

yum install -y redis

# remove any default config for redis
service redis stop
[[ -f /etc/init.d/redis ]] && mv /etc/init.d/redis $VAGRANT_DIR/guest/etc/init.d/redis.provision-bak #backup should not stay in /etc/init.d
[[ -f /etc/redis.conf ]] && mv /etc/redis.conf /etc/redis.conf.provision-bak

# it is expected that you would have a cusomized redis install for each instance you wish to have running


# rsync any overriden config files for this machine
#if [[ -d $VAGRANT_DIR/guest/etc/redis ]] && [[ -f $VAGRANT_DIR/guest/etc/init.d/redis* ]]; then
#    
#    [[ ! -d /etc/redis ]] && mkdir /etc/redis    
#    rsync -a $VAGRANT_DIR/guest/etc/redis/ /etc/redis/
#    chown -R root:root /etc/redis/
#    
#    mkdir -p /var/lib/redis-default
#    chown redis /var/lib/redis*
#    
#    rsync -a $VAGRANT_DIR/etc/init.d/redis* /etc/init.d/
#    chown root:root /etc/init.d/redis*
#    chmod +x /etc/init.d/redis*
#    
#    chkconfig redis-default on
#    service redis-default start
#fi
