class amanda::virtual {
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

}
