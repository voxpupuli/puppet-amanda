define amanda::disklist (
    $configs,
    $diskdevice = undef,
    $dumptype,
    $ensure     = present,
    $interface  = undef,
    $order      = 20,
    $spindle    = undef
    ) {
    include amanda::params
    include amanda::virtual

    concat::fragment { "amanda::disklist/$title":
        target  => "$amanda::params::configs_directory/$configs/disklist",
        ensure  => $ensure,
        order   => $order,
        content => "$fqdn $name $diskdevice $dumptype $spindle $interface\n",
        tag     => "amanda_dle",
    }
}
