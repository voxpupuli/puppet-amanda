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

    assert_type(String, $config)
    assert_type(String, $disk)

    if $ensure == 'present' {
        @@concat::fragment { "amanda::disklist/${::fqdn}/${title}":
            target  => "${amanda::params::configs_directory}/${config}/disklist",
            order   => $order,
            content => "${::fqdn} ${disk} ${diskdevice} ${dumptype} ${spindle} ${interface}\n",
            tag     => 'amanda_dle',
        }
    }
}
