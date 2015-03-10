node default {
  class { 'openstack_project::puppetmaster':
    root_rsa_key => hiera('puppetmaster_root_rsa_key', 'XXX'),
    sysadmins    => hiera('sysadmins', []),
    version      => '3.6.',
    puppetdb     => false,
  }
}
