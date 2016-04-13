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
      User::Virtual::Localuser['ying'],
      User::Virtual::Localuser['tiamarin'],
      User::Virtual::Localuser['marisidd'],
      User::Virtual::Localuser['sinhaank'],
      User::Virtual::Localuser['jeremybbrown'],
      User::Virtual::Localuser['infra'],
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

  ssh_authorized_key { 'puppet-remote-openswitch':
    ensure  => present,
    user    => 'root',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDFQTwSfcKow4pqDSewCcrU9XRziwi8CjZpDImbX8Rj62dfMwGeTqf+wIgMf6CQMXcw1sxpLwzs6w1LKcj9Z5jczfA2Cbo4CZULF2TBrUhdE/jj/W7oFsaDKLkvgZtClBGwP3hxJKJwpS0AXASGUCWm2/sM1QO9ZXcN9IjFzQDTqnT3PdrgdeyL7yBVDi4VPNxFt/JWAe0Pxfe6gnGKLverEdDtV3Jj9MOp4YFWmYmz4yH2bV1fTnjYUbpHb8cdjc7C/yU+zIFRGmNT/f4qFveJMRSxeh9qL5YrkAgAJHjHjjctrSuZLfkZ9RAkmjsYwedkzm+MKzplAAHzewqvP37r',
    options => [
      'from="puppetmaster.openswitch.net,15.126.130.36"',
    ],
    require => File['/root/.ssh'],
  }
  ssh_authorized_key { '/root/.ssh/authorized_keys':
    ensure  => absent,
    user    => 'root',
  }
  
  # Which Puppet do I take?
  # Take $puppet_version and pin to that version
  if ($::osfamily == 'Debian') {
    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '4BD6EC30',
      key_server => 'keys.gnupg.net',
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
