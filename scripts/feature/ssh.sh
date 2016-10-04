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
:: feature - ssh
########################################

# create key/pair on node for use as a deploy key
[[ ! -f ~/.ssh/id_rsa ]] && ssh-keygen -N '' -t rsa -f ~/.ssh/id_rsa

# append authorized_keys to correct location if we have one to import
if [[ -f /vagrant/etc/ssh/authorized_keys ]]; then
    cat /vagrant/etc/ssh/authorized_keys >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

# TODO make sure current user's public key is authorized

# install ssh key/pair and authorized_keys on node
if [[ -f $VAGRANT_DIR/guest/etc/ssh/id_rsa ]]; then
  
  mv $VAGRANT_DIR/guest/etc/ssh/id_rsa ~/.ssh/
  mv $VAGRANT_DIR/guest/etc/ssh/id_rsa.pub ~/.ssh/
  
  chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
fi