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
    Concat["${amanda::params::homedir}/.amandahosts"],
    Ssh_authorized_key["amanda/defaultkey"],
    Xinetd::Service["amanda_tcp"],
    Xinetd::Service["amanda_udp"],
  )

  if $amanda::params::genericpackage {
    realize(Package["amanda"])
  } else {
    realize(Package["amanda/client"])
  }


  concat::fragment {
    "amanda::client::amdump_${use_remoteuser}@${server}":
      target  => "${amanda::params::homedir}/.amandahosts",
      content => "${server} ${use_remoteuser} amdump\n",
      order   => "00";
  }
}
