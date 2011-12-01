class amanda::params {

  case $operatingsystem {
    "Ubuntu":  {
      $homedir              = "/var/lib/amanda"
      $uid                  = "59500"
      $user                 = "amandabackup"
      $group                = "disk"
      $groups               = [ "backup" ]
      $clientpackage        = "amanda-backup-client"
      $serverpackage        = "amanda-backup-server"
      $genericpackage       = "amanda"
      $serverprovidesclient = true  # since we're using zmanda packages
      $amandadpath          = "/usr/libexec/amanda/amandad"
      $amandadirectories    = [
        "/tmp/amanda",
        "/tmp/amanda/amandad",
      ]
    }
    "Solaris": {
      $homedir              = "/var/lib/amanda"
      $uid                  = "59500"
      $user                 = "amanda"
      $group                = "sys"
      $groups               = [ ]
      $clientpackage        = "amanda-client"
      $serverpackage        = "amanda-server"
      $genericpackage       = "amanda"
      $serverprovidesclient = true # there's only one package for solaris
      $amandadpath          = "/opt/csw/libexec/amanda/amandad"
      $amandadirectories    = [
        "/tmp/amanda",
        "/tmp/amanda/amandad",
      ]
    }
    "FreeBSD": {
      $homedir              = "/var/db/amanda"
      $uid                  = "59500"
      $user                 = "amanda"
      $group                = "amanda"
      $groups               = [ "operator" ]
      $clientpackage        = "misc/amanda-client"
      $serverpackage        = "misc/amanda-server"
      $genericpackage       = ""
      $serverprovidesclient = false # idunno
      $amandadpath          = "/usr/local/libexec/amanda/amandad"
      $amandadirectories    = [
        "/tmp/amanda",
        "/tmp/amanda/amandad",
        "/usr/local/var/amanda",
        "/usr/local/var/amanda/gnutar-lists",
      ]
    }
    default:   {
      $homedir              = "/var/lib/amanda"
      $uid                  = "59500"
      $user                 = "amandabackup"
      $group                = "backup"
      $groups               = [ ]
      $clientpackage        = "amanda-client"
      $serverpackage        = "amanda-server"
      $genericpackage       = "amanda"
      $serverprovidesclient = false # idunno
      $amandadpath          = "/usr/libexec/amanda/amandad"
      $amandadirectories    = [
        "/tmp/amanda",
        "/tmp/amanda/amandad",
      ]
    }
  }

  $defaultkeytype    = "rsa"
  $defaultkeyoptions = [
    "no-port-forwarding",
    "no-X11-forwarding",
    "no-agent-forwarding",
    "command=\"${amandadpath} -auth=ssh amdump\"",
  ]
  $defaultkey = "AAAAB3NzaC1yc2EAAAABIwAAAQEAuzggkXn3U4Pt9wG7/bCQNcXJJWWhCeqhcf\
MchN4OgkLEoUCUsUJDYfCZrDvK9hNYpTybMt/GE2xOTFrhOX9MGvX8LqADlUrHrX0WJuSdkxsONzTvq\
x8m24pIo0sdo3kRiS8PABr4S98fvO7JK0/3YXF7p7WwiZthegiIZI+ModfdLUTNxH6jceOtt8hCVx5C\
mykiQsJGEFtM2l0CgNrjD66NjHuadax8qmBdg5iTExPabPS1H1zbJ2FFMbxSuzs4xP9aodsw/1CMNx1\
IUe9L2lEbpA8LOgo7HYgh/TzXEfnujQyie+xWMOCVZHrcAvFn7bGol5zNGKtuVILsVgvVew=="

}
