# == Class: openstack_project::jenkins
#
class openstack_project::jenkins (
  $vhost_name = $::fqdn,
  $jenkins_jobs_password = '',
  $jenkins_jobs_username = 'gerrig', # This is not a typo, well it isn't anymore.
  $jenkins_git_url = 'https://git.openstack.org/openstack-infra/jenkins-job-builder',
  $jenkins_git_revision = '49be71864aaa5ca2096383ce7eb838c375e9a33c',
  $manage_jenkins_jobs = true,
  $ssl_cert_file = '',
  $ssl_key_file = '',
  $ssl_chain_file = '/etc/ssl/certs/intermediate.pem',
  $ssl_cert_file_contents = '',
  $ssl_key_file_contents = '',
  $ssl_chain_file_contents = '',
  $jenkins_ssh_public_key = $openstack_project::jenkins_ssh_key,
  $jenkins_ssh_private_key = '',
  $zmq_event_receivers = [],
  $sysadmins = [],
  $project_config_repo = '',
) inherits openstack_project {
  include openstack_project

  $iptables_rule = regsubst ($zmq_event_receivers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 8888 -s \1 -j ACCEPT')
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_rules6           => $iptables_rule,
    iptables_rules4           => $iptables_rule,
    sysadmins                 => $sysadmins,
  }

  # Set defaults here because they evaluate variables which you cannot
  # do in the class parameter list.
  if $ssl_cert_file == '' {
    $prv_ssl_cert_file = "/etc/ssl/certs/${vhost_name}.pem"
  }
  else {
    $prv_ssl_cert_file = $ssl_cert_file
  }
  if $ssl_key_file == '' {
    $prv_ssl_key_file = "/etc/ssl/private/${vhost_name}.key"
  }
  else {
    $prv_ssl_key_file = $ssl_key_file
  }

  class { '::jenkins::master':
    vhost_name              => $vhost_name,
    serveradmin             => 'webmaster@openswitch.net',
    logo                    => 'openswitch.png',
    ssl_cert_file           => $prv_ssl_cert_file,
    ssl_key_file            => $prv_ssl_key_file,
    ssl_chain_file          => $ssl_chain_file,
    ssl_cert_file_contents  => $ssl_cert_file_contents,
    ssl_key_file_contents   => $ssl_key_file_contents,
    ssl_chain_file_contents => $ssl_chain_file_contents,
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_ssh_public_key  => $jenkins_ssh_public_key,
  }

  jenkins::plugin { 'build-timeout':
    version => '1.14',
  }
  jenkins::plugin { 'copyartifact':
    version => '1.22',
  }
  jenkins::plugin { 'dashboard-view':
    version => '2.3',
  }
  jenkins::plugin { 'gearman-plugin':
    version => '0.1.1',
  }
  jenkins::plugin { 'git':
    version => '1.1.23',
  }
  jenkins::plugin { 'greenballs':
    version => '1.12',
  }
  jenkins::plugin { 'extended-read-permission':
    version => '1.0',
  }
  jenkins::plugin { 'zmq-event-publisher':
    version => '0.0.3',
  }
#  TODO(jeblair): release
#  jenkins::plugin { 'scp':
#    version => '1.9',
#  }
  jenkins::plugin { 'jobConfigHistory':
    version => '1.13',
  }
  jenkins::plugin { 'monitoring':
    version => '1.40.0',
  }
  jenkins::plugin { 'nodelabelparameter':
    version => '1.2.1',
  }
  jenkins::plugin { 'notification':
    version => '1.4',
  }
  jenkins::plugin { 'openid':
    version => '1.5',
  }
  jenkins::plugin { 'postbuildscript':
    version => '0.16',
  }
  jenkins::plugin { 'publish-over-ftp':
    version => '1.7',
  }
  jenkins::plugin { 'simple-theme-plugin':
    version => '0.2',
  }
  jenkins::plugin { 'timestamper':
    version => '1.3.1',
  }
  jenkins::plugin { 'token-macro':
    version => '1.5.1',
  }
  jenkins::plugin { 'downstream-ext':
    version => '1.8',
  }
  jenkins::plugin { 'test-results-analyzer':
    version => '0.2.1',
  }
  jenkins::plugin { 'multiple-scms':
    version => '0.5',
  }
  jenkins::plugin { 'conditional-buildstep':
    version => '1.3.3',
  }
  jenkins::plugin { 'envinject':
    version => '1.92.1',
  }
  jenkins::plugin { 'flexible-publish':
    version => '0.15.2',
  }
  jenkins::plugin { 'parameterized-trigger':
    version => '2.29',
  }
  jenkins::plugin { 'ssh-agent':
    version => '1.8',
  }
  jenkins::plugin { 'ssh-credentials':
    version => '1.11',
  }
  jenkins::plugin { 'publish-over-ssh':
    version => '1.13',
  }
  jenkins::plugin { 'build-token-root':
    version => '1.3',
  }
  jenkins::plugin { 'validating-string-parameter':
    version => '2.3',
  }
  jenkins::plugin { 'build-flow-plugin':
    version => '0.18',
  }

  if $manage_jenkins_jobs == true {
    class { 'project_config':
      url  => $project_config_repo,
    }

    class { '::jenkins::job_builder':
      url          => "https://${vhost_name}/",
      username     => $jenkins_jobs_username,
      password     => $jenkins_jobs_password,
      git_revision => $jenkins_git_revision,
      git_url      => $jenkins_git_url,
      config_dir   => $::project_config::jenkins_job_builder_config_dir,
      require      => $::project_config::config_dir,
    }

    file { '/etc/default/jenkins':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/openstack_project/jenkins/jenkins.default',
    }
  }
}
