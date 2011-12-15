define amanda::define::config::file (
  $resource_description = $name,
  $ensure               = "present",
  $owner                = undef,
  $group                = undef,
  $filemode             = "644",
  $dirmode              = "755"
) {
  include amanda::params

  $resource_array = split($resource_description, ":")
  $type           = $resource_array[0]
  $agent_path     = $resource_array[1]
  $master_path    = $resource_array[2]
  if !$owner { $use_owner = $amanda::params::user  }
  if !$group { $use_group = $amanda::params::group }

  file { "${agent_path}":
    owner  => $use_owner,
    group  => $use_group,
    source => "puppet://${server}/${master_path}",
    mode   => $type ? {
      "file"      => $filemode,
      "directory" => $dirmode,
    },
    ensure => $ensure ? {
      "present" => $type,
      "absent"  => absent,
    },
  }
}
