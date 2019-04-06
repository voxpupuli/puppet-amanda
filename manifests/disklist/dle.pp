define amanda::disklist::dle (
    $configs,
    $dumptype,
    $diskdevice = undef,
    $ensure     = present,
    $interface  = undef,
    $order      = 20,
    $spindle    = undef
    ) {
    include amanda::params
    include amanda::virtual

    $entries = regsubst($configs, '.*', "${title}@\\0")

    amanda::disklist { $entries:
        ensure     => $ensure,
        diskdevice => $diskdevice,
        dumptype   => $dumptype,
        interface  => $interface,
        order      => $order,
        spindle    => $spindle,
    }
}
