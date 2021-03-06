# == Class: openstack_project::slave_common
#
# Common configuration between openstack_project::slave and
# openstack_project::single_use_slave
class openstack_project::slave_common(
  $sudo         = false,
  $project_config_repo = 'https://git.openswitch.net/infra/project-config',
){
#  vcsrepo { '/opt/requirements':
#    ensure   => latest,
#    provider => git,
#    revision => 'master',
#    source   => 'https://git.openstack.org/openstack/requirements',
#  }

  include wget

  class { 'project_config':
    url  => $project_config_repo,
  }

  file { '/mnt/jenkins':
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0755',
  }

  file { '/usr/local/jenkins/slave_scripts':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => [File['/usr/local/jenkins'],
                $::project_config::config_dir],
    source  => $::project_config::jenkins_scripts_dir,
  }

  file { '/home/jenkins/.pydistutils.cfg':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    source  => 'puppet:///modules/openstack_project/pydistutils.cfg',
    require => Class['jenkins::slave'],
  }

  if ($sudo == true) {
    file { '/etc/sudoers.d/jenkins-sudo':
      ensure => present,
      source => 'puppet:///modules/openstack_project/jenkins-sudo.sudo',
      owner  => 'root',
      group  => 'root',
      mode   => '0440',
    }
  }

  file { '/etc/sudoers.d/jenkins-sudo-grep':
    ensure => present,
    source => 'puppet:///modules/openstack_project/jenkins-sudo-grep.sudo',
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
  }

  wget::fetch { 'https://storage.googleapis.com/git-repo-downloads/repo':
    destination => '/usr/local/bin/repo',
    before      => File['/usr/local/bin/repo'],
  }

  file { '/usr/local/bin/repo':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Temporary for debugging glance launch problem
  # https://lists.launchpad.net/openstack/msg13381.html
  # NOTE(dprince): ubuntu only as RHEL6 doesn't have sysctl.d yet
  if ($::osfamily == 'Debian') {

    file { '/etc/sysctl.d/10-ptrace.conf':
      ensure => present,
      source => 'puppet:///modules/jenkins/10-ptrace.conf',
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
    }

    exec { 'ptrace sysctl':
      subscribe   => File['/etc/sysctl.d/10-ptrace.conf'],
      refreshonly => true,
      command     => '/sbin/sysctl -p /etc/sysctl.d/10-ptrace.conf',
    }
  }

  # install linux-headers depending on OS version
  case $::osfamily {
    'RedHat': {
      $header_packages = ['kernel-devel', 'kernel-headers']
    }
    'Debian': {
      if ($::operatingsystem == 'Debian') {
          # install depending on kernel release
          $header_packages = [ "linux-headers-${::kernelrelease}", ]
      }
      else {
        $header_packages = ['linux-headers-virtual', 'linux-headers-generic']
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}.")
    }
  }

  package { $header_packages:
    ensure => present
  }
}
