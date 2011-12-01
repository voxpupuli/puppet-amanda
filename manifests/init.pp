#
# Example usage:
#
# Do:
#
# file { "/etc/amanda":
#   ensure => directory;
# }
#
# amanda::config { "rolling":
#   ensure  => "present",
#   confdir => "/etc/amanda";
# }
#
# Then place your config files in the "files" directory of the module,
# in one of:
#
#   amanda/files/<fqdn>/<config>/*
#   amanda/files/default/<config>/*
#
# The contents of the config directory will be synced to the confdir you
# specify in the amanda::config resource.

class amanda {
  include amanda::params
  include amanda::virtual

  realize(
    File["/etc/dumpdates"],
    File["${amanda::params::homedir}"],
    File["${amanda::params::homedir}/.ssh"],
    File["${amanda::params::homedir}/.ssh/config"],
    File["${amanda::params::homedir}/.ssh/authorized_keys"],
    File[$amanda::params::amandadirectories],
    File[$amanda::params::homedir],
    User[$amanda::params::user],
  )
}
