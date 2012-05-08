define amanda::config (
  $ensure                   = present,
  $config                   = $title,
  $configs_directory        = undef,
  $manage_configs_directory = true,
  $configs_source           = 'modules/amanda/server',
  $owner                    = undef,
  $group                    = undef,
  $file_mode                = '0644',
  $directory_mode           = '0755'
) {
  include amanda::params

  if $configs_directory != undef {
    $configs_directory_real = $configs_directory
  } else {
    $configs_directory_real = "$amanda::params::configs_directory/$config"
  }

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

  if ($ensure == 'present') {
    $ensure_directory = 'directory'
  } elsif ($ensure == 'absent') {
    $ensure_directory = 'absent'
  } else {
    fail("invalid ensure parameter: $ensure")
  }

  if (
    $manage_configs_directory
    and !defined(File["amanda::config:$configs_directory_real"])
  ) {
    file { "amanda::config:$configs_directory_real":
      ensure => $ensure_directory,
      path   => $configs_directory_real,
      owner  => $owner_real,
      group  => $group_real,
      mode   => $directory_mode,
    }
  }

  $params = {
    'ensure'            => $ensure,
    'owner'             => $owner_real,
    'group'             => $group_real,
    'file_mode'         => $file_mode,
    'directory_mode'    => $directory_mode,
    'configs_directory' => $configs_directory_real,
  }

  create_amanda_config_files($config, $configs_source, $params)

}
