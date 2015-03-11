# == Class: openstack_project::base
#
class openstack_project::base(
  $certname              = $::fqdn,
  $install_users         = true,
  $pin_puppet            = '3.',
  $ca_server             = undef,
) {
  if ($::osfamily == 'Debian') {
    include apt
  }
  include openstack_project::params
  include openstack_project::users
  include sudoers

  case $pin_puppet {
    '2.7.': {
      $pin_facter = '1.'
      $pin_puppetdb = '1.'
    }
    /^3\./: {
      $pin_facter = '2.'
      $pin_puppetdb = '2.'
    }
    default: {
      fail("Puppet version not supported")
    }
  }

  file { '/etc/profile.d/Z98-byobu.sh':
    ensure => absent,
  }

  package { 'popularity-contest':
    ensure => absent,
  }

  package { 'git':
    ensure => present,
  }

  if ($::operatingsystem == 'Fedora') {

    package { 'hiera':
      ensure   => latest,
      provider => 'gem',
    }

    exec { 'symlink hiera modules' :
      command     => 'ln -s /usr/local/share/gems/gems/hiera-puppet-* /etc/puppet/modules/',
      path        => '/bin:/usr/bin',
      subscribe   => Package['hiera'],
      refreshonly => true,
    }

  }

  package { $::openstack_project::params::packages:
    ensure => present
  }

  include pip
  $desired_virtualenv = '1.11.4'

  if (( versioncmp($::virtualenv_version, $desired_virtualenv) < 0 )) {
    $virtualenv_ensure = $desired_virtualenv
  } else {
    $virtualenv_ensure = present
  }
  package { 'virtualenv':
    ensure   => $virtualenv_ensure,
    provider => pip,
    require  => Class['pip'],
  }
  file { '/etc/pip.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/pip.conf',
    replace => true,
  }

  if ($install_users) {
    package { $::openstack_project::params::user_packages:
      ensure => present
    }

    realize (
      User::Virtual::Localuser['dompegam'],
    )
  }

  if ! defined(File['/root/.ssh']) {
    file { '/root/.ssh':
      ensure => directory,
      mode   => '0700',
    }
  }

  ssh_authorized_key { 'puppet-remote-2014-04-17':
    ensure  => absent,
    user    => 'root',
  }
  ssh_authorized_key { 'puppet-remote-2014-05-24':
    ensure  => absent,
    user    => 'root',
  }
  ssh_authorized_key { 'puppet-remote-2014-09-11':
    ensure  => absent,
    user    => 'root',
  }
  ssh_authorized_key { 'puppet-remote-2014-09-15':
    ensure  => absent,
    user    => 'root',
  }

  ssh_authorized_key { 'puppet-remote-openhalon':
    ensure  => present,
    user    => 'root',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCeCaJ5QTGzj8vNabcAJy8cAnt+apr2i8Kz7XHLJ2l9/8bYjuIpivnHI3vfxZ7GDQLicVDeESw/UVY0mz1DuoycyvJorFBIYuiveDWpByMbdT+bwJLbPRPNYdUZJGBlgwLL8DSa38xgWbEef7KB+UbDuydba1n5OnBUih6Gzm4KhBZIGLjvc3uJAuGjKouixAHw6jxeTS5visSK0JxG27npkv0/3PZy46RN2cp9XNtc3zKD2u6P0pPabx5lM9XNMleRsRuaxOMumDh1qx2aYGfoWYg4dTMYYNE/1FZYuRshwymaQ7aUECWTRr4kMyBlFOZYiifdLX04olA61W9sD/cT',
    options => [
      'from="puppetmaster.openstacklocal"',
    ],
    require => File['/root/.ssh'],
  }
  ssh_authorized_key { '/root/.ssh/authorized_keys':
    ensure  => absent,
    user    => 'root',
  }

  # DNS-less network
  host { 'puppetmaster':
    ip => '10.0.0.5',
    host_aliases => [ 'puppetmaster.openstacklocal' ]
  }
  host { 'review':
    ip => '10.0.0.6',
    host_aliases => [ 'review.openstacklocal' ]
  }
  host { 'puppetdb':
    ip => '10.0.0.7',
    host_aliases => [ 'puppetdb.openstacklocal' ]
  }
  
  # Which Puppet do I take?
  # Take $puppet_version and pin to that version
  if ($::osfamily == 'Debian') {
    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '4BD6EC30',
      key_server => 'pgp.mit.edu',
    }

    file { '/etc/apt/apt.conf.d/80retry':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/80retry',
      replace => true,
    }

    file { '/etc/apt/apt.conf.d/90no-translations':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/90no-translations',
      replace => true,
    }

    file { '/etc/apt/preferences.d/00-puppet.pref':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('openstack_project/00-puppet.pref.erb'),
      replace => true,
    }

    file { '/etc/default/puppet':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/puppet.default',
      replace => true,
    }

  }

  if ($::operatingsystem == 'CentOS') {
    file { '/etc/yum.repos.d/puppetlabs.repo':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/centos-puppetlabs.repo',
      replace => true,
    }
    file { '/etc/yum.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/yum.conf',
      replace => true,
    }
  }

  $puppet_version = $pin_puppet
  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('openstack_project/puppet.conf.erb'),
    replace => true,
  }

  service { 'puppet':
    ensure => stopped,
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
