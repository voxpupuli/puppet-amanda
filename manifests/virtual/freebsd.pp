class amanda::virtual::freebsd inherits amanda::virtual {

#  User[$amanda::params::user] {
#    profiles => [
#      "ZFS File System Management",
#      "ZFS Storage Management",
#    ],
#  }

  Package["amanda/client"] {
    name      => "misc/amanda-client",
    provider  => freebsd,
  }

}
