class amanda::virtual::server inherits amanda::virtual {
  include amanda::params

  # local variables used for better readability
  $server_provides_client = $amanda::params::server_provides_client
  $generic_package = $amanda::params::generic_package

  if $server_provides_client and !$generic_package {
    Package['amanda/client'] {
      ensure => absent,
    }
  }

  Xinetd::Service['amanda_tcp'] {
    server_args => "-auth=bsdtcp ${amanda::params::server_daemons}",
  }

}
