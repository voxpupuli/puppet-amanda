class amanda::server (
  $configs       = [],
  $confdir       = "/etc/amanda",
  $dirmode       = "755",
  $filemode      = "644",
  $managedirs    = "true",
  $confsrcmodule = "amanda",
  $confsrcroot   = undef,
  $owner         = undef,
  $group         = undef
) {
  include amanda
  include amanda::params
  include amanda::virtual::server

  if $owner {
    $use_owner = $owner
  } else {
    $use_owner = $amanda::params::user
  }

  if $group {
    $use_group = $group
  } else {
    $use_group = $amanda::params::group
  }

  if $managedirs == "true" {
    file {
      $confdir:
        ensure => directory,
        owner  => $use_owner,
        group  => $use_group,
        mode   => $dirmode;
    }
  }

  if $amanda::params::genericpackage {
    realize(Package["amanda"])
  } else {
    realize(Package["amanda/server"])
  }

  realize(
    Ssh_authorized_key["amanda/defaultkey"],
  )

  # for solaris, which does not use xinetd, we don't manage a superserver.
  if $operatingsystem != "Solaris" {
    realize(
      Xinetd::Service["amanda_indexd"],
      Xinetd::Service["amanda_taped"],
      Xinetd::Service["amanda_tcp"],
      Xinetd::Service["amanda_udp"],
    )
  }

  amanda::define::amandahosts {
    "amanda::server::server_root@localhost":
      content => "localhost root amindexd amidxtaped\n",
      order   => "10";
  }

  amanda::define::config {
    $configs:
      ensure         => present,
      confdir        => $confdir,
      confsrcmodule  => $confsrcmodule,
      confsrcroot    => $confsrcroot,
      owner          => $use_owner,
      group          => $use_group,
      filemode       => $filemode,
      dirmode        => $dirmode;
  }

}
