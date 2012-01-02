class amanda::virtual::server inherits amanda::virtual {
  include amanda::params

  # local variables used for better readability
  $serverprovidesclient = $amanda::params::serverprovidesclient
  $genericpackage = $amanda::params::genericpackage

  if $serverprovidesclient and !$genericpackage {
    Package["amanda/client"] {
      ensure => absent,
    }
  }

  Xinetd::Service["amanda_tcp"] {
    server_args => "-auth=bsdtcp ${amanda::params::serverdaemons}",
  }

}
