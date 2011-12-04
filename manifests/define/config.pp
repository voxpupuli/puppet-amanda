define amanda::define::config (
  $ensure         = "present",
  $config         = $name,
  $confdir        = "/etc/amanda/${name}",
  $confsrcmodule  = "amanda",
  $confsrcroot    = undef,
  $owner          = undef,
  $group          = undef,
  $filemode       = "644",
  $dirmode        = "755"
) {
  include amanda::params

  $files = amanda_config_files($config, $confdir, $confsrcmodule, $confsrcroot)

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

  file {
    "$confdir/$config":
      ensure => directory,
      owner  => $use_owner,
      group  => $use_group,
      mode   => $dirmode,
  }

  amanda::define::config::file {
    $files:
      ensure   => $ensure,
      owner    => $use_owner,
      group    => $use_group,
      filemode => $filemode,
      dirmode  => $dirmode,
      require  => File["$confdir/$config"],
  }
}
