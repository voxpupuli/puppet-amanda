define amanda::ssh_authorized_key (
  $key,
  $ensure  = present,
  $type    = undef,
  $options = undef
) {
  include amanda
  include amanda::params

  $default_type    = 'rsa'
  $default_options = [
    'no-port-forwarding',
    'no-X11-forwarding',
    'no-agent-forwarding',
    "command=\"${amanda::params::amandad_path} -auth=ssh amdump\"",
  ]

  if $options != undef {
    $options_real = $options
  } else {
    $options_real = $default_options
  }

  if $type != undef {
    $type_real = $type
  } else {
    $type_real = $default_type
  }

  ssh_authorized_key { "${amanda::params::user}/${title}":
    ensure  => $ensure,
    key     => $key,
    user    => $amanda::params::user,
    type    => $type_real,
    options => $options_real,
    require => File["${amanda::params::homedir}/.ssh/authorized_keys"];
  }

}

