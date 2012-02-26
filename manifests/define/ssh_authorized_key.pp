define amanda::define::ssh_authorized_key (
  $key,
  $ensure  = "present",
  $type    = "rsa",
  $options = undef
) {
  include amanda
  include amanda::params

  $defaulttype    = "rsa"
  $defaultoptions = [
    "no-port-forwarding",
    "no-X11-forwarding",
    "no-agent-forwarding",
    "command=\"${amanda::params::amandadpath} -auth=ssh amdump\"",
  ]

  if $options {
    $useoptions = $options
  } else {
    $useoptions = $defaultoptions
  }

  if $type {
    $usetype = $type
  } else {
    $usetype = $defaulttype
  }

  ssh_authorized_key {
    "${amanda::params::user}/${title}":
      key     => $key,
      user    => $amanda::params::user,
      type    => $usetype,
      options => $useoptions,
      require => File["${amanda::params::homedir}/.ssh/authorized_keys"];
  }

}

