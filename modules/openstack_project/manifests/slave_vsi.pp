# == Class: openstack_project::slave
#
class openstack_project::slave_vsi (
  $thin = false,
  $certname = $::fqdn,
  $ssh_key = '',
  $sysadmins = [],
  $token = 'XXX',
) {

  include openstack_project
  include openstack_project::tmpcleanup

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [],
    iptables_public_udp_ports => [],
    certname                  => $certname,
    sysadmins                 => $sysadmins,
  }

  class { 'jenkins::slave':
    ssh_key      => $ssh_key,
  }

  include jenkins::cgroups
  include ulimit
  ulimit::conf { 'limit_jenkins_procs':
    limit_domain => 'jenkins',
    limit_type   => 'hard',
    limit_item   => 'nproc',
    limit_value  => '8192'
  }

  include openstack_project::slave_common

  if (! $thin) {
    class {'openstack_project::thick_slave':
      token => $token,
    }
  }

  file { '/etc/sudoers.d/jenkins-vsi':
    ensure => present,
    source => 'puppet:///modules/openstack_project/jenkins/jenkins-vsi.sudo',
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
  }

  exec {"docker_group":
    unless => "/usr/bin/groups jenkins | /bin/grep docker",
    command => "/usr/sbin/usermod -aG docker jenkins",
    require => User['jenkins'],
  }

}
