class amanda::virtual {
  include concat::setup
  include amanda::params

  case $operatingsystem {
    "FreeBSD": { include amanda::virtual::freebsd }
    "Solaris": { include amanda::virtual::solaris }
    default:   { }
  }

  @user {
    "${amanda::params::user}":
      uid     => $amanda::params::uid,
      gid     => $amanda::params::group,
      home    => $amanda::params::homedir,
      groups  => $amanda::params::groups,
      comment => "Amanda backup user",
      tag     => "amanda_common";
  }

  File {
    owner   => $amanda::params::user,
    group   => $amanda::params::group,
  }

  @file {
    "/etc/dumpdates":
      ensure => file,
      mode   => "664",
      owner  => "root";
    "${amanda::params::homedir}":
      ensure => directory,
      mode   => "755";
    "${amanda::params::homedir}/.ssh":
      ensure => directory,
      mode   => "700";
    "${amanda::params::homedir}/.ssh/config":
      mode    => "644",
      content => "PreferredAuthentications=publickey\n";
    "${amanda::params::homedir}/.ssh/authorized_keys":
      mode    => "600";
    $amanda::params::amandadirectories:
      ensure => directory,
      mode   => "700",
  }

  Package {
    ensure => present,
    before => [
      File["/etc/dumpdates"],
      File["${amanda::params::homedir}"],
      File["${amanda::params::homedir}/.ssh"],
      File["${amanda::params::homedir}/.ssh/config"],
      File["${amanda::params::homedir}/.ssh/authorized_keys"],
      File[$amanda::params::amandadirectories],
      File[$amanda::params::homedir],
      User[$amanda::params::user],
    ]
  }

  if $amanda::params::genericpackage {
    @package {
      "amanda":
        name   => $amanda::params::genericpackage;
    }
  } else {
    @package {
      "amanda/client":
        name   => $amanda::params::clientpackage;
      "amanda/server":
        name   => $amanda::params::serverpackage;
    }
  }

  @ssh_authorized_key {
    "amanda/defaultkey":
      user    => $amanda::params::user,
      key     => $amanda::params::defaultkey,
      type    => $amanda::params::defaultkeytype,
      options => $amanda::params::defaultkeyoptions,
      require => File["${amanda::params::homedir}/.ssh/authorized_keys"];
  }

  @concat {
    "${amanda::params::homedir}/.amandahosts":
      owner => $amanda::params::user,
      group => $amanda::params::group,
      mode  => "600";
  }

  Xinetd::Service {
    require => [
      User[$amanda::params::user],
      $amanda::params::genericpackage ? {
        undef   => Package["amanda/client"],
        default => Package["amanda"],
      },
    ],
  }

  @xinetd::service {
    "amanda_udp":
      servicename => "amanda",
      socket_type => "dgram",
      protocol    => "udp",
      port        => "10080",
      user        => $amanda::params::user,
      group       => $amanda::params::group,
      server      => $amanda::params::amandadpath,
      server_args => "-auth=bsdtcp ${amanda::params::clientdaemons}";
    "amanda_tcp":
      servicename => "amanda",
      socket_type => "stream",
      protocol    => "tcp",
      port        => "10080",
      user        => $amanda::params::user,
      group       => $amanda::params::group,
      server      => $amanda::params::amandadpath,
      server_args => "-auth=bsdtcp ${amanda::params::clientdaemons}";
    "amanda_indexd":
      servicename => "amandaidx",
      socket_type => "stream",
      protocol    => "tcp",
      wait        => "no",
      port        => "10082",
      user        => $amanda::params::user,
      group       => $amanda::params::group,
      server      => $amanda::params::amandaidxpath,
      server_args => "-auth=bsdtcp ${amanda::params::serverdaemons}";
    "amanda_taped":
      servicename => "amidxtape",
      socket_type => "stream",
      protocol    => "tcp",
      wait        => "no",
      port        => "10083",
      user        => $amanda::params::user,
      group       => $amanda::params::group,
      server      => $amanda::params::amandatapedpath,
      server_args => "-auth=bsdtcp ${amanda::params::serverdaemons}";
  }

}
