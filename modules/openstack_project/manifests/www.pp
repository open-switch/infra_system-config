# == Class: openstack_project::www
#
class openstack_project::www (
  $mysql_root_password = '',
  $sysadmins = [],
  $ssl_cert_file_contents = '',
  $ssl_key_file_contents = '',
  $ssl_chain_file_contents = ''
) {

  package { ['openssl', 'ssl-cert', 'subversion', 'php5-cli']:
    ensure => present;
  }

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => $sysadmins,
  }

#  class { 'mediawiki':
#    role                      => 'all',
#    mediawiki_location        => '/srv/mediawiki/w',
#    mediawiki_images_location => '/srv/mediawiki/images',
#    site_hostname             => $::fqdn,
#    ssl_cert_file             => "/etc/ssl/certs/${::fqdn}.pem",
#    ssl_key_file              => "/etc/ssl/private/${::fqdn}.key",
#    ssl_chain_file            => '/etc/ssl/certs/intermediate.pem',
#    ssl_cert_file_contents    => $ssl_cert_file_contents,
#    ssl_key_file_contents     => $ssl_key_file_contents,
#    ssl_chain_file_contents   => $ssl_chain_file_contents,
#  }

  class { 'composer':
    command_name => 'composer',
    target_dir   => '/usr/local/bin'
  }

#  file { '/srv/www':
#    ensure  => directory,
#    owner   => 'www-data',
#    group   => 'www-data',
#  }

  exec { 'composer-run':
    environment => [ "COMPOSER_HOME=/usr/local/bin" ],
    command => "/usr/local/bin/composer create-project silverstripe/installer /srv/www/ 3.1.13",
    cwd     => '/srv/www/',
    user    => root,
    group   => root,
    timeout => 0,
    creates => "/srv/www"
    require => [Package['git'], Package['php5-cli']],
  }

  include apache

  a2mod { 'rewrite':
    ensure => present,
  }
  a2mod { 'proxy':
    ensure => present,
  }
  a2mod { 'proxy_http':
    ensure => present,
  }

  apache::vhost { $::fqdn:
    port     => 80,
    priority => '50',
    docroot  => '/srv/www',
    require  => File['/srv/www'],
  }

  class { 'mysql::server':
    config_hash => {
      'root_password'  => $mysql_root_password,
      'default_engine' => 'InnoDB',
      'bind_address'   => '127.0.0.1',
    }
  }
  include mysql::server::account_security

  mysql_backup::backup { 'www':
    require => Class['mysql::server'],
  }

#  include bup
#  bup::site { 'rs-ord':
#    backup_user   => 'bup-www',
#    backup_server => 'ci-backup-rs-ord.openstack.org',
#  }

#  class { '::elasticsearch':
#    es_template_config => {
#      'bootstrap.mlockall'               => true,
#      'discovery.zen.ping.unicast.hosts' => ['localhost'],
#    },
#    version            => '1.3.2',
#    heap_size          => '1g',
#  }

}
