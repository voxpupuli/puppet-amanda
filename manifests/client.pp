class amanda::client (
  String           $ensure           = 'present',
  Optional[String] $remote_user      = undef,
  String           $server           = "backup.${facts['networking']['domain']}",
  Boolean          $xinetd           = true,
  Boolean          $export_host_keys = false,
) {
  include amanda
  include amanda::params

  if $remote_user != undef {
    $remote_user_real = $remote_user
  } else {
    $remote_user_real = $amanda::params::user
  }

  # for systems that don't use xinetd, don't use xinetd
  if (("x${xinetd}" == 'xtrue') and !$amanda::params::xinetd_unsupported) {
    realize(
      Xinetd::Service['amanda_tcp'],
      Xinetd::Service['amanda_udp'],
    )
  }

  if $amanda::params::generic_package {
    realize(Package['amanda'])
  } else {
    realize(Package['amanda/client'])
  }

  amanda::amandahosts { "amanda::client::amdump_${remote_user_real}@${server}":
    ensure  => $ensure,
    content => "${server} ${remote_user_real} amdump",
    order   => '00';
  }

  if ($export_host_keys) {
    ## export our ssh host keys
    @@sshkey { "${::clientcert}_amanda": # lint:ignore:legacy_facts
      ensure       => $ensure,
      host_aliases => [$facts['networking']['fqdn'],$facts['networking']['ip']],
      key          => $::sshrsakey, # lint:ignore:legacy_facts
      type         => 'ssh-rsa',
      target       => "${amanda::params::homedir}/.ssh/known_hosts",
      tag          => 'amanda_client_host_keys',
    }
  }
}
