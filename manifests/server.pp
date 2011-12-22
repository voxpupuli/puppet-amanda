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
    Concat["${amanda::params::homedir}/.amandahosts"],
    Ssh_authorized_key["amanda/defaultkey"],
    Xinetd::Service["amanda_indexd"],
    Xinetd::Service["amanda_taped"],
    Xinetd::Service["amanda_tcp"],
    Xinetd::Service["amanda_udp"],
  )

  concat::fragment {
    "amanda::server::server_root@localhost":
      target  => "${amanda::params::homedir}/.amandahosts",
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
