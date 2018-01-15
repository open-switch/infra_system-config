# == Class: openstack_project::wiki
#
class openstack_project::wiki (
  $mysql_root_password = '',
  $sysadmins = [],
  $vhost_name = $::fqdn,
  $ssl_chain_file_contents = ''
) {

  package { ['openssl', 'ssl-cert', 'subversion']:
    ensure => present;
  }

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => $sysadmins,
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

  $prv_ssl_cert_file = "/etc/ssl/certs/${vhost_name}.pem"
  $prv_ssl_key_file = "/etc/ssl/private/${vhost_name}.key"
  $ssl_chain_file = '/etc/ssl/certs/intermediate.pem'

  apache::vhost { $vhost_name:
    port => 80,
    docroot => '/tmp',
    template => 'openstack_project/wiki.vhost.erb',
    ssl_cert_file => $prv_ssl_cert_file,
    ssl_key_file  => $prv_ssl_key_file,
    ssl_chain_file => $ssl_chain_file,
  }

  file { $prv_ssl_cert_file:
    ensure => 'link'
    target => "/etc/letsencrypt/live/${vhost_name}/cert.pem",
    before => Apache::Vhost[$vhost_name],
  }

  file { $prv_ssl_key_file:
    ensure => 'link'
    target => "/etc/letsencrypt/live/${vhost_name}/privkey.pem",
    before => Apache::Vhost[$vhost_name],
  }

  if $ssl_chain_file_contents != '' {
    file { $ssl_chain_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_chain_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  cron { 'certbot':
    command => 'certbot renew --renew-hook "/usr/sbin/apache2ctl graceful"',
    user => 'root',
    hour => [1, 13],
    minute => 6,
  }
}
