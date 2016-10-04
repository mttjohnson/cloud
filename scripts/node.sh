#!/usr/bin/env bash
##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

set -e

source ./scripts/lib/utils.sh

########################################
:: running generic guest configuration
########################################

# set dns record in hosts file
ip_address=$(ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')
printf "\n$ip_address $(hostname)\n" >> /etc/hosts

########################################
:: configuring rpms needed for install
########################################

# enable rpm caching and set higher metadata cache
sed -i 's/keepcache=0/keepcache=1\nmetadata_expire=24h/' /etc/yum.conf

# append exclude rule to avoid updating the yum tool and kernel packages (causes issues with VM Ware tools on re-create)
printf "\n\nexclude=yum nfs-utils kernel*\n" >> /etc/yum.conf

# import gpg keys before installing anything
rpm --import $VAGRANT_DIR/etc/keys/RPM-GPG-KEY-CentOS-6.txt
rpm --import $VAGRANT_DIR/etc/keys/RPM-GPG-KEY-EPEL-6.txt

# install wget since it's not in Digital Ocean base image
yum install -y wget

if [[ ! -d /var/cache/yum/rpms ]]; then
    mkdir -p /var/cache/yum/rpms
fi
pushd /var/cache/yum/rpms

yum install -y epel-release

popd

########################################
:: updating currently installed packages
########################################

yum update -y

########################################
:: setting zone info to match host zone
########################################

if [[ -f "$HOST_ZONEINFO" ]]; then
    if [[ -f /etc/localtime ]]; then
        mv /etc/localtime /etc/localtime.bak
    elif [[ -L /etc/localtime ]]; then
        rm /etc/localtime
    fi
    ln -s "$HOST_ZONEINFO" /etc/localtime
fi

########################################
:: installing generic guest tooling
########################################

yum install -y bash-completion bc man git rsync mysql pv tree
rsync -av --ignore-existing $VAGRANT_DIR/guest/bin/ /usr/local/bin/

########################################
:: rsync in machine specific overrides
########################################
rsync -av --ignore-existing $VAGRANT_DIR/machine/etc/ $VAGRANT_DIR/guest/etc/
rsync -av --ignore-existing $VAGRANT_DIR/machine/scripts/ $VAGRANT_DIR/scripts/

########################################
:: installing configuration into /etc
########################################

mkdir -p /etc/profile.d/
rsync -av $VAGRANT_DIR/guest/etc/profile.d/ /etc/profile.d/

git config --global core.excludesfile /etc/.gitignore_global

########################################
:: key scanning for known hosts
########################################

# add github.com key so non-interactive clones will work later in provisioning
if [[ ! -f ~/.ssh/known_hosts ]] || [[ -z "$(grep github ~/.ssh/known_hosts)" ]]; then
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
fi
