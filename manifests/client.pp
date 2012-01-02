class amanda::client (
  $server     = "backup.$domain",
  $remoteuser = undef
) {
  include amanda
  include amanda::params
  include concat::setup

  if $remoteuser {
    $use_remoteuser = $remoteuser
  } else {
    $use_remoteuser = $amanda::params::user
  }

  realize(
    Ssh_authorized_key["amanda/defaultkey"],
  )

  # for solaris, which does not use xinetd, we don't manage a superserver.
  if $operatingsystem != "Solaris" {
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
