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

  if $amanda::params::genericpackage {
    realize(Package["amanda"])
  } else {
    realize(Package["amanda/client"])
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
