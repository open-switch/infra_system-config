# == Class: openstack_project::ticket
#
class openstack_project::ticket {

  include openstack_project::params

  file { '/etc/login.defs':
    ensure => present,
    source => $::openstack_project::params::login_defs,
  }
  # global users
  User::Virtual::Localuser {
    require => File['/etc/login.defs']
  }

  # local users
  user { 'michael':
    ensure => present,
    home => '/home/michael',
    groups  => ['sudo'],
    shell   => '/bin/bash',
    uid     => '3000',
    gid     => '3000',
    managehome => true,
  }

  ssh_authorized_key { 'michael_key':
  user => 'michael',
  type => 'rsa',
  key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCb4Ssy/U8pHXIFV6oalxGh5hXuCIS/4YYijyUnbf8KX7tGB0kZVhdCA92ztZGuUlqbDSu2sCFwPKllNqanKDW+9Z6pClGDmIToc6hmMovkAarY4hVtvIZRUKDnhzi56kegXpxbMqPHeEWXQLM8S6GOYScPeLFFyY+8+eRQjsliTnIBobPVHs/dDSNey7WkfH4/O/BSjpmvBiGdrssL4WQhQtyX0V7J7iAv3l4V/OBHjI+tJjSlNZhGLVruoSQd9vhX1rx3hOoP+HWnBLh/kDuMXA+oUDzbuofNF34twXMMlMBnWQFz/DeA+2zxbJSSv6GH6BMH9euWC3bB7Qq6Pk9d',
  }
}
