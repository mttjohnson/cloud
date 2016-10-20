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

# Use the remi repo for the newer 3.x version of Redis instead of the default 2.4
yum --enablerepo=remi install -y redis

# remove any default config for redis
mkdir -p $VAGRANT_DIR/backup/etc/init.d/
[[ -f /etc/init.d/redis ]] && mv /etc/init.d/redis $VAGRANT_DIR/backup/etc/init.d/redis.provision-bak #backup should not stay in /etc/init.d
[[ ! -d /etc/redis ]] && mkdir /etc/redis
[[ -f /etc/redis.conf ]] && [[ -f $VAGRANT_DIR/guest/etc/redis.conf ]] && mv /etc/redis.conf /etc/redis/redis-defaults.conf.provision-bak

# rsync any overriden config files for this machine
if [[ -d $VAGRANT_DIR/guest/etc/redis ]]; then
        
    rsync -a $VAGRANT_DIR/guest/etc/redis/ /etc/redis/
    chown -R root:root /etc/redis/
    
    export redis_instance_name="redis-fpc"
    mkdir -p /var/lib/redis/${redis_instance_name}
    chown redis /var/lib/redis/${redis_instance_name}
    cp $VAGRANT_DIR/guest/etc/init.d/${redis_instance_name} /etc/init.d/${redis_instance_name}
    chown root:root /etc/init.d/${redis_instance_name}
    chmod +x /etc/init.d/${redis_instance_name}
    chkconfig --add ${redis_instance_name}
    chkconfig ${redis_instance_name} on
    service ${redis_instance_name} start
    
    export redis_instance_name="redis-obj"
    mkdir -p /var/lib/redis/${redis_instance_name}
    chown redis /var/lib/redis/${redis_instance_name}
    cp $VAGRANT_DIR/guest/etc/init.d/${redis_instance_name} /etc/init.d/${redis_instance_name}
    chown root:root /etc/init.d/${redis_instance_name}
    chmod +x /etc/init.d/${redis_instance_name}
    chkconfig --add ${redis_instance_name}
    chkconfig ${redis_instance_name} on
    service ${redis_instance_name} start
    
    export redis_instance_name="redis-ses"
    mkdir -p /var/lib/redis/${redis_instance_name}
    chown redis /var/lib/redis/${redis_instance_name}
    cp $VAGRANT_DIR/guest/etc/init.d/${redis_instance_name} /etc/init.d/${redis_instance_name}
    chown root:root /etc/init.d/${redis_instance_name}
    chmod +x /etc/init.d/${redis_instance_name}
    chkconfig --add ${redis_instance_name}
    chkconfig ${redis_instance_name} on
    service ${redis_instance_name} start
fi

# verify redis is running
redis-cli -s /var/run/redis/redis-fpc.sock ping
redis-cli -s /var/run/redis/redis-obj.sock ping
redis-cli -s /var/run/redis/redis-ses.sock ping

# set directory permissions so non root users can access redis
chmod 755 /var/run/redis