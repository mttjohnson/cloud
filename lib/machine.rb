##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

require 'utils'

# Virtual Box Configuration
def provider_vb conf
  if defined? CONF_VB_ENABLE and CONF_VB_ENABLE == true
    conf.vm.provider :virtualbox do |provider, conf|
      provider.memory = 4096
      provider.cpus = 2

      conf.vm.network :private_network, type: 'dhcp'
      conf.vm.box = 'bento/centos-6.7'
    end
  end
end

# Digital Ocean Configuration
def provider_do conf
  if defined? CONF_DO_TOKEN
    assert_plugin 'vagrant-digitalocean'
    
    conf.vm.provider :digital_ocean do |provider, conf|
      provider.token           = CONF_DO_TOKEN
      provider.image           = CONF_DO_IMAGE
      provider.region          = CONF_DO_REGION
      provider.size            = CONF_DO_SIZE
      provider.ssh_key_name    = CONF_DO_PK_NAME
      provider.backups_enabled = true

      conf.ssh.private_key_path = CONF_DO_PK_PATH
      conf.vm.box = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
    end
  end
end

# AWS Configuration
def provider_aws conf
  if defined? CONF_AWS_KEY_ID and defined? CONF_AWS_KEY_SECRET
    assert_plugin 'vagrant-aws'
    conf.vm.provider :aws do |provider, conf|
      provider.ami               = CONF_AWS_AMI
      provider.access_key_id     = CONF_AWS_KEY_ID
      provider.secret_access_key = CONF_AWS_KEY_SECRET
      provider.keypair_name      = CONF_AWS_PK_NAME

      if defined? CONF_AWS_SESSION_TOKEN
        provider.session_token = CONF_AWS_SESSION_TOKEN
      end

      conf.ssh.username          = 'cloud'
      conf.ssh.private_key_path  = CONF_AWS_PK_PATH
      conf.vm.box = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
    end
  end
end

# Rackspace Cloud Configuration
def provider_rack conf
  if defined? CONF_RAX_USERNAME and defined? CONF_RAX_API_KEY
    assert_plugin 'vagrant-rackspace'
    conf.vm.provider :rackspace do |provider, conf|
      provider.username         = CONF_RAX_USERNAME
      provider.api_key          = CONF_RAX_API_KEY
      provider.rackspace_region = CONF_RAX_REGION
      provider.flavor           = CONF_RAX_FLAVOR
      provider.image            = CONF_RAX_IMAGE
      provider.key_name         = CONF_RAX_UPLOADED_KEY_NAME
      provider.public_key_path  = CONF_RAX_PK_PUB_PATH
      conf.ssh.private_key_path = CONF_RAX_PK_PATH
      provider.init_script      = CONF_RAX_INIT_SCRIPT
    end
  end
end

def machine_fullstack_vm node, host: nil, ip: nil, php_version: nil, mysql_version: nil
  # if no period in supplied host, tack on the configured CLOUD_DOMAIN
  unless host =~ /.*\..*/
    host = host + '.' + CLOUD_DOMAIN
  end
  node.vm.hostname = host
  
  bootstrap_sh node, [
      'node',
      'feature/group-www-shared',
      'feature/npm',
      'feature/sshd',
      'feature/ssh',
      'feature/sendmail',
      'feature/nginx',
      'feature/varnish',
      'feature/mysqld',
      'feature/php',
      'feature/letsencrypt',
      'feature/devtools',
      'feature/redis',
      'feature/user-remove-apache',
      'feature/user-www-data'
    ], {
      ssl_dir: '/etc/ssl',
      php_version: php_version,
      mysql_version: mysql_version
  }
end

def machine_synced_etc node, path
  node.vm.synced_folder path, VAGRANT_DIR + '/machine/etc', type: 'rsync', rsync__args: [ '--archive', '-z', '--copy-links' ]
end

def machine_synced_scripts node, path
  node.vm.synced_folder path, VAGRANT_DIR + '/machine/scripts', type: 'rsync', rsync__args: [ '--archive', '-z', '--copy-links' ]
end

def configure_sh conf, env = {}
  conf.vm.provision :shell, run: 'always' do |conf|
    env = {
      vagrant_dir: VAGRANT_DIR
    }.merge(env)
    exports = generate_exports env

    conf.name = 'configure.sh'
    conf.inline = %-#{exports} #{VAGRANT_DIR}/scripts/configure.sh-
  end
end
