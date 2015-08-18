# == Class: openstack_project::zuul_merger
#
class openstack_project::zuul_merger(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_ssh_host_key = '',
  $zuul_ssh_private_key = '',
  $zuul_url = "http://${::fqdn}/p",
  $sysadmins = [],
) {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => $sysadmins,
  }

  class { '::zuul':
    vhost_name           => $vhost_name,
    gearman_server       => $gearman_server,
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    zuul_ssh_private_key => $zuul_ssh_private_key,
    zuul_url             => $zuul_url,
    git_email            => 'jenkins@openswitch.net',
    git_name             => 'OpenSwitch Jenkins',
  }

  class { '::zuul::merger': }

  if $gerrit_ssh_host_key != '' {
    file { '/home/zuul/.ssh':
      ensure  => directory,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0700',
      require => Class['::zuul'],
    }
    file { '/home/zuul/.ssh/known_hosts':
      ensure  => present,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0600',
      content => "review.openswitch.net,15.126.134.181 ${gerrit_ssh_host_key}",
      replace => true,
      require => File['/home/zuul/.ssh'],
    }
  }
}
