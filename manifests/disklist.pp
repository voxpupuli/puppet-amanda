define amanda::disklist (
    $diskdevice,
    $dumptype,
    $ensure,
    $interface,
    $order,
    $spindle
    ) {
    include ::amanda::params
    include ::amanda::virtual

    $config = regsubst($title, '^.*@', '')
    $disk   = regsubst($title, '@[^@]*$', '')

    validate_string($config)
    validate_string($disk)

    @@concat::fragment { "amanda::disklist/${::fqdn}/${title}":
        ensure  => $ensure,
        target  => "${amanda::params::configs_directory}/${config}/disklist",
        order   => $order,
        content => "${::fqdn} ${disk} ${diskdevice} ${dumptype} ${spindle} ${interface}\n",
        tag     => 'amanda_dle',
    }
}
