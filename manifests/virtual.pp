class amanda::virtual {
  include amanda::params

  case $::operatingsystem {
    'Solaris': { include amanda::virtual::solaris }
    default:   { } # do nothing
  }

  @user { $amanda::params::user:
    uid     => $amanda::params::uid,
    gid     => $amanda::params::group,
    home    => $amanda::params::homedir,
    shell   => $amanda::params::shell,
    groups  => $amanda::params::groups,
    comment => $amanda::params::comment,
    tag     => 'amanda_common',
  }

  File {
    owner   => $amanda::params::user,
    group   => $amanda::params::group,
    require => User[$amanda::params::user],
  }

  @file { '/etc/dumpdates':
    ensure => file,
    mode   => '0664',
    owner  => 'root',
  }
  @file { $amanda::params::homedir:
    ensure => directory,
    mode   => '0755';
  }
  @file { "${amanda::params::homedir}/.ssh":
    ensure => directory,
    mode   => '0700';
  }
  @file { "${amanda::params::homedir}/.ssh/config":
    mode    => '0644',
    content => "PreferredAuthentications=publickey\n";
  }
  @file { "${amanda::params::homedir}/.ssh/authorized_keys":
    mode => '0600';
  }
  @file { $amanda::params::amanda_directories:
    ensure => directory,
    mode   => '0700',
  }
  @file { $amanda::params::amanda_files:
    ensure => present,
    mode   => '0600',
  }

  ##
  # This variable is used because parameter defaults don't seem to descend
  # into if blocks.
  $post_package = [
    File['/etc/dumpdates'],
    File[$amanda::params::homedir],
    File["${amanda::params::homedir}/.ssh"],
    File["${amanda::params::homedir}/.ssh/config"],
    File["${amanda::params::homedir}/.ssh/authorized_keys"],
    File[$amanda::params::amanda_directories],
    File[$amanda::params::homedir],
    User[$amanda::params::user],
  ]

  if $amanda::params::generic_package {
    @package { 'amanda':
      name   => $amanda::params::generic_package,
      before => $post_package;
    }
  } else {
    @package { 'amanda/client':
      name   => $amanda::params::client_package,
      before => $post_package,
    }
    @package { 'amanda/server':
      name   => $amanda::params::server_package,
      before => $post_package,
    }
  }

  @concat { "${amanda::params::homedir}/.amandahosts":
    owner   => $amanda::params::user,
    group   => $amanda::params::group,
    mode    => '0600',
    require => File[$amanda::params::homedir],
  }

  Xinetd::Service {
    require => [
      User[$amanda::params::user],
      $post_package,
    ],
  }

  @xinetd::service { 'amanda_udp':
    service_name => 'amanda',
    socket_type  => 'dgram',
    protocol     => 'udp',
    port         => '10080',
    user         => $amanda::params::user,
    group        => $amanda::params::group,
    server       => $amanda::params::amandad_path,
    server_args  => "-auth=bsd ${amanda::params::client_daemons}",
  }
  @xinetd::service { 'amanda_tcp':
    service_name => 'amanda',
    socket_type  => 'stream',
    protocol     => 'tcp',
    port         => '10080',
    user         => $amanda::params::user,
    group        => $amanda::params::group,
    server       => $amanda::params::amandad_path,
    server_args  => "-auth=bsdtcp ${amanda::params::client_daemons}",
  }
  @xinetd::service { 'amanda_indexd':
    service_name => 'amandaidx',
    socket_type  => 'stream',
    protocol     => 'tcp',
    wait         => 'no',
    port         => '10082',
    xtype        => 'UNLISTED',
    user         => $amanda::params::user,
    group        => $amanda::params::group,
    server       => $amanda::params::amandaidx_path,
    server_args  => "-auth=bsdtcp ${amanda::params::server_daemons}",
  }
  @xinetd::service { 'amanda_taped':
    service_name => 'amidxtape',
    socket_type  => 'stream',
    protocol     => 'tcp',
    wait         => 'no',
    port         => '10083',
    xtype        => 'UNLISTED',
    user         => $amanda::params::user,
    group        => $amanda::params::group,
    server       => $amanda::params::amandataped_path,
    server_args  => "-auth=bsdtcp ${amanda::params::server_daemons}";
  }

}
