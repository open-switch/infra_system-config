# == Class: openstack_project::review_dev
#
class openstack_project::review_dev (
  $github_oauth_token = '',
  $github_project_username = '',
  $github_project_password = '',
  $mysql_host = '',
  $mysql_password = '',
  $email_private_key = '',
  # Register SSL keys and pass their contents in.
  $ssl_cert_file = "/etc/ssl/certs/${::fqdn}.pem",
  $ssl_cert_file_contents = '',
  $ssl_key_file = "/etc/ssl/private/${::fqdn}.key",
  $ssl_key_file_contents = '',
  $ssl_chain_file = '/etc/ssl/certs/intermediate.pem',
  $ssl_chain_file_contents = '',
  $contactstore = false,
  $contactstore_appsec = '',
  $contactstore_pubkey = '',
  $ssh_dsa_key_contents = '',
  $ssh_dsa_pubkey_contents = '',
  $ssh_rsa_key_contents = '',
  $ssh_rsa_pubkey_contents = '',
  $ssh_project_rsa_key_contents = '',
  $ssh_project_rsa_pubkey_contents = '',
  $smtpserver = 'localhost',
  $smtpuser = '',
  $smtppass = '',
  $oauth_github_client_id = '',
  $oauth_github_client_secret = '',
  $lp_sync_consumer_key = '',
  $lp_sync_token = '',
  $lp_sync_secret = '',
  $sysadmins = [],
  $swift_username = '',
  $swift_password = '',
  $project_config_repo = '',
  $projects_config = 'openstack_project/review-dev.projects.ini.erb',
) {

  realize (
    User::Virtual::Localuser['dompegam'],
  )

  class { 'project_config':
    url  => $project_config_repo,
    base => 'dev/',
  }

  class { 'openstack_project::gerrit':
    vhost_name                      => 'review-dev.openswitch.net',
    canonicalweburl                 => 'https://review-dev.openswitch.net',
    ssl_cert_file                       => $ssl_cert_file,
    ssl_key_file                        => $ssl_key_file,
    ssl_chain_file                      => $ssl_chain_file,
    ssl_cert_file_contents              => $ssl_cert_file_contents,
    ssl_key_file_contents               => $ssl_key_file_contents,
    ssl_chain_file_contents             => $ssl_chain_file_contents,
    ssh_dsa_key_contents            => $ssh_dsa_key_contents,
    ssh_dsa_pubkey_contents         => $ssh_dsa_pubkey_contents,
    ssh_rsa_key_contents            => $ssh_rsa_key_contents,
    ssh_rsa_pubkey_contents         => $ssh_rsa_pubkey_contents,
    ssh_project_rsa_key_contents    => $ssh_project_rsa_key_contents,
    ssh_project_rsa_pubkey_contents => $ssh_project_rsa_pubkey_contents,
    email                           => 'review@openswitch.net',
    logo                            => 'puppet:///modules/openstack_project/openswitch-dev.png',
    war                             =>
      'https://archive.openswitch.net/gerrit/gerrit-2.12.2.ops.war',
    contactstore                    => $contactstore,
    contactstore_appsec             => $contactstore_appsec,
    contactstore_pubkey             => $contactstore_pubkey,
    contactstore_url                =>
      'https://review-dev.openstack.org/fakestore',
    acls_dir                        => $::project_config::gerrit_acls_dir,
    notify_impact_file              => $::project_config::gerrit_notify_impact_file,
    projects_file                   => $::project_config::jeepyb_project_file,
    projects_config                 => $projects_config,
    github_username                 => 'openstack-gerrit-dev',
    github_oauth_token              => $github_oauth_token,
    github_project_username         => $github_project_username,
    github_project_password         => $github_project_password,
    smtpserver                      => $smtpserver,
    smtpuser                        => $smtpuser,
    smtppass                        => $smtppass,
    oauth_github_client_id          => $oauth_github_client_id,
    oauth_github_client_secret      => $oauth_github_client_secret,
    mysql_host                      => $mysql_host,
    mysql_password                  => $mysql_password,
    email_private_key               => $email_private_key,
    sysadmins                       => $sysadmins,
    gitweb                          => true,
    cgit                            => false,
    swift_username                  => $swift_username,
    swift_password                  => $swift_password,
    replication                         => [
#      {
#        name                 => 'github',
#        url                  => 'git@github.com:',
#        authGroup            => 'Anonymous Users',
#        replicationDelay     => '1',
#        replicatePermissions => false,
#        mirror               => true,
#      },
      {
        name                 => 'local',
        url                  => 'file:///opt/lib/git/',
        replicationDelay     => '1',
        threads              => '4',
        mirror               => true,
      },
    ],
    require                         => $::project_config::config_dir,
  }

  gerrit::plugin { 'javamelody':
    version => 'e00d5af',
  }

  gerrit::plugin { 'gerrit-oauth-provider':
    base_url => "https://archive.openswitch.net/gerrit/",
    version => '2.11.3',
  }

  package { 'python-launchpadlib':
    ensure => present,
  }
  file { '/home/gerrit2/.launchpadlib':
    ensure  => directory,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0775',
    require => User['gerrit2'],
  }
  file { '/home/gerrit2/.launchpadlib/creds':
    ensure  => present,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0600',
    content => template('openstack_project/gerrit_lp_creds.erb'),
    replace => true,
    require => User['gerrit2'],
  }

  include bup
  bup::site { 'rs-ord':
    backup_user   => 'bup-review-dev',
    backup_server => 'ci-backup-rs-ord.openstack.org',
  }
}
