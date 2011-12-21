class amanda::server::xinetd {
  include amanda::params
  include xinetd

  Xinetd::Service {
    require => [
      User[$amanda::params::user],
      $amanda::params::genericpackage ? {
        undef   => Package["amanda/client"],
        default => Package["amanda"],
      },
    ],
  }

  xinetd::service {
    "amanda_indexd":
      servicename => "amandaidx",
      socket_type => "stream",
      protocol    => "tcp",
      wait        => "no",
      port        => "10082",
      user        => $amanda::params::user,
      group       => $amanda::params::group,
      server      => $amanda::params::amandaidxpath,
      server_args => "-auth=bsd amdump amindexd amidxtaped";
    "amanda_taped":
      servicename => "amidxtape",
      socket_type => "stream",
      protocol    => "tcp",
      wait        => "no",
      port        => "10083",
      user        => $amanda::params::user,
      group       => $amanda::params::group,
      server      => $amanda::params::amandatapedpath,
      server_args => "-auth=bsd amdump amindexd amidxtaped";
  }

}
