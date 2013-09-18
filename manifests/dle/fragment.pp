#
define amanda::dle::fragment (
    $ensure = present,
    $order  = 20,
    $configs,
    $content,
) {
    include amanda::params
    include amanda::virtual

    notify { $name: }

    concat::fragment { "amanda::dle/${title}":
        target  => "${amanda::params::configs_directory}/${name}/disklist",
        ensure  => $ensure,
        order   => $order,
        content => "${::fqdn} ${content}\n",
        tag     => "amanda_dle",
    }
}

