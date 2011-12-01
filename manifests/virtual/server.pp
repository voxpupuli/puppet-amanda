class amanda::virtual::server inherits amanda::virtual {
  include amanda::params

  if $amanda::params::serverprovidesclient {
    Package["amanda/client"] {
      ensure => absent,
    }
  }
}
