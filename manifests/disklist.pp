define amanda::disklist (
    $diskdevice,
    $dumptype,
    $ensure,
    $interface,
    $order,
    $spindle
    ) {
    include amanda::params
    include amanda::virtual

    $config = regsubst($title, '^.*@', '')
    $disk   = regsubst($title, '@[^@]*$', '')

    concat::fragment { "amanda::disklist/${title}":
        target  => "${amanda::params::configs_directory}/${config}/disklist",
        ensure  => $ensure,
        order   => $order,
        content => "${::fqdn} ${disk} ${diskdevice} ${dumptype} ${spindle} ${interface}\n",
        tag     => "amanda_dle",
    }
}
