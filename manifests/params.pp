#
# Packages seem to be grossly inconsistent across operating systems.
# Therefore, the following slightly complicated set of variables is
# used in order to determine which packages to install based on
# client/server combinations.
#
#        variable: $clientpackage
#            type: string
#     description: package to install when realizing amanda::client
#
#        variable: $serverpackage
#            type: string
#     description: package to install when realizing amanda::server
#
#        variable: $serverprovidesclient
#            type: boolean
#     description: set to true if it is the case that the server
#                  package conflicts with the client package.
#
#        variable: $genericpackage
#            type: string
#     description: if set, this variable overrides clientpackage
#                  and serverpackage. any time either of those packages
#                  would have been realized, this one is realized
#                  instead.
#
class amanda::params {

  case $operatingsystem {
    "Ubuntu":  {
      $homedir              = "/var/lib/amanda"
      $uid                  = "59500"
      $user                 = "amandabackup"
      $shell                = "/bin/sh"
      $group                = "disk"
      $groups               = [ "backup", "tape" ]
      $clientpackage        = "amanda-backup-client"
      $serverpackage        = "amanda-backup-server"
      $serverprovidesclient = true  # since we're using zmanda packages
      $amandadpath          = "/usr/libexec/amanda/amandad"
      $amandaidxpath        = "/usr/libexec/amanda/amindexd"
      $amandatapedpath      = "/usr/libexec/amanda/amidxtaped"
      $amandadirectories    = [
        "/tmp/amanda",
        "/tmp/amanda/amandad",
        "/var/amanda",
        "/var/amanda/gnutar-lists",
      ]
    }
    "Solaris": {
      $homedir              = "/var/lib/amanda"
      $uid                  = "59500"
      $user                 = "amanda"
      $shell                = "/bin/sh"
      $group                = "sys"
      $groups               = [ ]
      $genericpackage       = "amanda"
      $serverprovidesclient = true # there's only one package for solaris
      $amandadpath          = "/opt/csw/libexec/amanda/amandad"
      $amandaidxpath        = "/opt/csw/libexec/amanda/amindexd"
      $amandatapedpath      = "/opt/csw/libexec/amanda/amidxtaped"
      $amandadirectories    = [
        "/tmp/amanda",
        "/tmp/amanda/amandad",
      ]
    }
    "FreeBSD": {
      $homedir              = "/var/db/amanda"
      $uid                  = "59500"
      $user                 = "amanda"
      $shell                = "/bin/sh"
      $group                = "amanda"
      $groups               = [ "operator" ]
      $clientpackage        = "misc/amanda-client"
      $serverpackage        = "misc/amanda-server"
      $serverprovidesclient = false # idunno
      $amandadpath          = "/usr/local/libexec/amanda/amandad"
      $amandaidxpath        = "/usr/local/libexec/amanda/amindexd"
      $amandatapedpath      = "/usr/local/libexec/amanda/amidxtaped"
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
      $shell                = "/bin/sh"
      $group                = "backup"
      $groups               = [ ]
      $clientpackage        = "amanda-client"
      $serverpackage        = "amanda-server"
      $serverprovidesclient = false # idunno
      $amandadpath          = "/usr/libexec/amanda/amandad"
      $amandaidxpath        = "/usr/libexec/amanda/amindexd"
      $amandatapedpath      = "/usr/libexec/amanda/amidxtaped"
      $amandadirectories    = [
        "/tmp/amanda",
        "/tmp/amanda/amandad",
      ]
    }
  }

  $serverdaemons = "amdump amindexd amidxtaped"
  $clientdaemons = "amdump"
}
