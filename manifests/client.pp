class amanda::client (
  $server     = "backup.$domain",
  $remoteuser = undef
) {
  include amanda
  include amanda::params

  if $remoteuser {
    $use_remoteuser = $remoteuser
  } else {
    $use_remoteuser = $amanda::params::user
  }

  realize(Ssh_authorized_key["amanda/defaultkey"])

  case $operatingsystem {
    "FreeBSD": { realize(Package["amanda/client"]) }
    "Solaris": { realize(Package["amanda"])        }
    "Ubuntu":  { realize(Package["amanda/client"]) }
    default:   { notify { "Undefined OS":; }       }
  }

  file {
    "${amanda::params::homedir}/.amandahosts":
      ensure  => file,
      owner   => $amanda::params::user,
      group   => $amanda::params::group,
      mode    => "600",
      content => "${server} ${use_remoteuser} amdump\n";
  }
}
