class amanda::virtual::solaris inherits amanda::virtual {

  User[$amanda::params::user] {
    profiles => [
      "ZFS File System Management",
      "ZFS Storage Management",
    ],
  }

  Package["amanda"] {
    provider  => blastwave,
    adminfile => $solaris::pkgget::adminfile,
  }

}
