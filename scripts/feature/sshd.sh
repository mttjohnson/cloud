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
:: feature - sshd
########################################

# setup sshusers group and authorize vagrant ssh user (typically 'vagrant' but on Digital Ocean it's 'root')
groupadd sshusers
usermod -a -G sshusers $(whoami)

# copy guest etc configs
if [[ -f /etc/ssh/sshd_config ]] && [[ -f $VAGRANT_DIR/guest/etc/ssh/sshd_config ]]; then
    mv /etc/ssh/sshd_config /etc/ssh/sshd_config.provision-bak
    cp $VAGRANT_DIR/guest/etc/ssh/sshd_config /etc/ssh/sshd_config
    chmod 600 /etc/ssh/sshd_config
fi

# reload ssh daemon since we have a custom config it needs to load
service sshd reload
