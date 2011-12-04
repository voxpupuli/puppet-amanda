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

  if $amanda::params::genericpackage {
    realize(Package["amanda"])
  } else {
    realize(Package["amanda/server"])
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
