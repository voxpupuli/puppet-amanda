#
define amanda::dle (
    $configs,
    $diskdevice = undef,
    $dumptype,
    $ensure     = present,
    $interface  = undef,
    $order      = 20,
    $spindle    = undef
    ) {

    amanda::dle::fragment { $configs:
        ensure  => $ensure,
        content => "$name $diskdevice $dumptype $spindle $interface",
        order   => $order,
    }
}

