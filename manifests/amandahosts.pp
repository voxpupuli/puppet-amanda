define amanda::amandahosts (
  $content,
  $ensure  = present,
  $order   = '20'
) {
  include amanda::params
  include amanda::virtual

  realize(Concat["${amanda::params::homedir}/.amandahosts"])

  if $ensure == present {
    concat::fragment { "amanda::amandahosts/${title}":
      target  => "${amanda::params::homedir}/.amandahosts",
      content => "${content}\n",
      order   => $order;
    }
  }
}
