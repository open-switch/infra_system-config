# == Class: openstack_project:analytics
#
class openstack_project::analytics (
  $sysadmins = [],
  $vhost_name = $::fqdn,
  $ssl_cert_file = '',
  $ssl_key_file = '',
  $ssl_chain_file = '/etc/ssl/certs/intermediate.pem',
  $ssl_cert_file_contents = '',
  $ssl_key_file_contents = '',
  $ssl_chain_file_contents = '',
) {

  if $ssl_cert_file == '' {
    $prv_ssl_cert_file = "/etc/ssl/certs/${vhost_name}.pem"
  }
  else {
    $prv_ssl_cert_file = $ssl_cert_file
  }
  if $ssl_key_file == '' {
    $prv_ssl_key_file = "/etc/ssl/private/${vhost_name}.key"
  }
  else {
    $prv_ssl_key_file = $ssl_key_file
  }

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443, 8086],
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

  exec{'retrieve_influxdb':
    command => "/usr/bin/wget -q https://dl.influxdata.com/influxdb/releases/influxdb_0.13.0_amd64.deb -O /root/influxdb_0.13.0_amd64.deb",
    creates => "/tmp/influxdb_0.13.0_amd64.deb",
  }

  file {'/root/influxdb_0.13.0_amd64.deb':
    mode => 0755,
    require => Exec["retrieve_influxdb"],
  }

  package { "influxdb":
    provider => dpkg,
    ensure   => latest,
    source   => "/root/influxdb_0.13.0_amd64.deb"
  }

  exec{'retrieve_grafana':
    command => "/usr/bin/wget -q https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.0-1468321182_amd64.deb -O /root/grafana_3.1.0-1468321182_amd64.deb",
    creates => "/root/grafana_3.1.0-1468321182_amd64.deb",
  }

  file {'/root/grafana_3.1.0-1468321182_amd64.deb':
    mode => 0755,
    require => Exec["retrieve_grafana"],
  }

  package { "grafana":
    provider => dpkg,
    ensure   => latest,
    source   => "/root/grafana_3.1.0-1468321182_amd64.deb"
  }

  apache::vhost { $vhost_name:
    port => 80,
    docroot => '/tmp',
    template => 'openstack_project/analytics.vhost.erb',
    ssl_cert_file => $prv_ssl_cert_file,
    ssl_key_file  => $prv_ssl_key_file,
    ssl_chain_file => $ssl_chain_file,
  }

  if $ssl_cert_file_contents != '' {
    file { $prv_ssl_cert_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_cert_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  if $ssl_key_file_contents != '' {
    file { $prv_ssl_key_file:
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      content => $ssl_key_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
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

}
