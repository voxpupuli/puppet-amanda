define amanda::disklist::dle (
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

    $entries = regsubst($configs, '.*', "${title}@\\0")

    amanda::disklist { $entries:
        diskdevice => $diskdevice,
        dumptype   => $dumptype,
        ensure     => $ensure,
        interface  => $interface,
        order      => $order,
        spindle    => $spindle
    }
}
