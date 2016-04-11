class amanda::server (
  $configs                  = [],
  $configs_directory        = undef,
  $manage_configs_directory = true,
  $configs_source           = 'modules/amanda/server/example',
  $mode                     = '0644',
  $group                    = undef,
  $owner                    = undef,
  $xinetd                   = true,
  $manage_dle               = false,
  $export_host_keys         = false,
) {
  include ::amanda
  include ::amanda::params
  include ::amanda::virtual::server

  if $owner != undef {
    $owner_real = $owner
  } else {
    $owner_real = $amanda::params::user
  }

  if $group != undef {
    $group_real = $group
  } else {
    $group_real = $amanda::params::group
  }

  if $configs_directory != undef {
    $configs_directory_real = $configs_directory
  } else {
    $configs_directory_real = $amanda::params::configs_directory
  }

  if $amanda::params::generic_package {
    realize(Package['amanda'])
  } else {
    realize(Package['amanda/server'])
  }

  # for systems that don't use xinetd, don't use xinetd
  if (("x${xinetd}" == 'xtrue') and !$amanda::params::xinetd_unsupported) {
    realize(
      Xinetd::Service['amanda_indexd'],
      Xinetd::Service['amanda_taped'],
      Xinetd::Service['amanda_tcp'],
      Xinetd::Service['amanda_udp'],
    )
  }

  amanda::amandahosts { 'amanda::server::server_root@localhost':
    content => 'localhost root amindexd amidxtaped',
    order   => '10';
  }

  amanda::config { $configs:
    ensure                   => present,
    manage_configs_directory => $manage_configs_directory,
    configs_directory        => $configs_directory,
    configs_source           => $configs_source,
    owner                    => $owner_real,
    group                    => $group_real,
    mode                     => $mode,
    manage_dle               => $manage_dle,
  }

  if ($export_host_keys) {
    ## import client ssh hosy keys into known_hosts
    SshKey <<| tag == 'amanda_client_host_keys' |>>
  }

}
