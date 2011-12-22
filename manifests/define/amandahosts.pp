define amanda::define::amandahosts (
  $ensure         = "present",
  $content
) {
  include amanda::params
  include amanda::virtual

  realize(Concat["${amanda::params::homedir}/.amandahosts"])

  concat::fragment {
    "amanda::define::amandahosts::$title":
      target  => "${amanda::params::homedir}/.amandahosts",
      content => $content,
      order   => "20";
  }
}
