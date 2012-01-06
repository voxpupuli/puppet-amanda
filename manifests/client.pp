class amanda::client (
  $remoteuser = undef,
  $server     = "backup.$domain",
  $xinetd     = "true"
) {
  include amanda
  include amanda::params
  include concat::setup

  if $remoteuser {
    $use_remoteuser = $remoteuser
  } else {
    $use_remoteuser = $amanda::params::user
  }

  # for solaris, which does not use xinetd, we don't manage a superserver.
  if ($xinetd == "true" and $operatingsystem != "Solaris") {
    realize(
      Xinetd::Service["amanda_tcp"],
      Xinetd::Service["amanda_udp"],
    )
  }

  if $amanda::params::genericpackage {
    realize(Package["amanda"])
  } else {
    realize(Package["amanda/client"])
  }

  amanda::define::amandahosts {
    "amanda::client::amdump_${use_remoteuser}@${server}":
      content => "${server} ${use_remoteuser} amdump\n",
      order   => "00";
  }

}
