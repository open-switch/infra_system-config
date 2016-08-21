class openstack_project::runner_slave (
  $certname = $::fqdn,
  $ssh_key = '',
  $aws_credentials_content = '',
  $aws_dynamic_key = '',
  $sysadmins = [],
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

  file { '/home/jenkins/.ssh/aws_dynamic.key':
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => 0600,
    content => $aws_dynamic_key,
  }
 
  file { '/home/jenkins/.aws':
    ensure => 'directory',
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0750', 
  }

  file { '/home/jenkins/.aws/credentials':
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0600',
    content => $aws_credentials_content,
    require => File['/home/jenkins/.aws'], 
  }

  file { '/home/jenkins/.aws/config':
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0600',
    content => template('openstack_project/aws_config.erb'),
    require => File['/home/jenkins/.aws'],
  }

  exec{'retrieve_vagrant':
    command => '/usr/bin/wget -q https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5_x86_64.deb -O /root/vagrant_1.8.5_x86_64.deb',
    creates => '/root/vagrant_1.8.5_x86_64.deb',
  }

  file{'/root/vagrant_1.8.5_x86_64.deb':
    mode => 0755,
    require => Exec["retrieve_vagrant"],
  }

  package { "vagrant":
    provider => dpkg,
    ensure   => latest,
    source   => "/root/vagrant_1.8.5_x86_64.deb"
  }

  exec{'install_vagrant_aws':
    environment => ["HOME=/home/jenkins"], 
    command => "/usr/bin/vagrant plugin install vagrant-aws",
    require => package["vagrant"],
  }
}
