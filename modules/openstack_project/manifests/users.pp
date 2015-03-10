# == Class: openstack_project::users
#
class openstack_project::users {
  # Make sure we have our UID/GID account minimums for dynamic users set higher
  # than we'll use for static assignments, so as to avoid future conflicts.
  include openstack_project::params
  file { '/etc/login.defs':
    ensure => present,
    source => $::openstack_project::params::login_defs,
  }
  User::Virtual::Localuser {
    require => File['/etc/login.defs']
  }

  @user::virtual::localuser { 'dompegam':
    realname => 'Diego Dompe',
    sshkeys  => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDV7iwGBrjEh6IEpHN/eS2TrRySGi43+ZHsdtLs5GG0vzYsqSwCZgQB3XHmdQZ3MYkkEGx9fdqfhJ8kV9edeOjlA1TczVw1kwfOT3MjjWPvR2QVuFN9W45gMM3WrA0EQZGY4jM93CfMbby11xnJ1NvNcuWqG1qYwe9SNCJJaDmtVtN3jH3DpF7hr8ke8hH3YMOdsFjqJyP8LvuJKd3LI2ZD/V7tdu513oHqo8RATyMHuUtEE094q22J+fkYGPtSSSG2ctXFThJR74nTXfbNA7LG6TcnadOTOkmh4dqKzmRnao3gHyu/oGpQxkY7cL2gXnx9Fwyr0r4Sm7vXXzI3o7kd',
    key_id   => 'dompegam@Aleph1Linux',
    uid      => 2000,
    gid      => 2000,
  }
}
