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
#        variable: $server_provides_client
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

  case $::osfamily {
    'Debian':  {
      $configs_directory      = '/etc/amanda'
      $homedir                = '/var/backups'
      $uid                    = '34'
      $user                   = 'backup'
      $comment                = 'backup'
      $shell                  = '/bin/sh'
      $group                  = 'backup'
      $groups                 = [ 'tape' ]
      $client_package         = 'amanda-client'
      $server_package         = 'amanda-server'
      $server_provides_client = false
      $amandad_path           = '/usr/lib/amanda/amandad'
      $amandaidx_path         = '/usr/lib/amanda/amindexd'
      $amandataped_path       = '/usr/lib/amanda/amidxtaped'
      $amanda_directories     = [
        '/var/amanda',
        '/var/amanda/gnutar-lists',
        '/var/log/amanda',
      ]
      $amanda_files           = [
      ]
    }
    'Solaris': {
      $configs_directory      = '/etc/amanda'
      $homedir                = '/var/lib/amanda'
      $uid                    = '59500'
      $user                   = 'amanda'
      $comment                = 'Amanda backup user'
      $shell                  = '/bin/sh'
      $group                  = 'sys'
      $groups                 = [ ]
      $xinetd_unsupported     = true
      $generic_package        = 'amanda'
      $server_provides_client = true # there's only one package for solaris
      $amandad_path           = '/opt/csw/libexec/amanda/amandad'
      $amandaidx_path         = '/opt/csw/libexec/amanda/amindexd'
      $amandataped_path       = '/opt/csw/libexec/amanda/amidxtaped'
      $amanda_directories     = [
        '/opt/csw/var/amanda/gnutar-lists',
      ]
      $amanda_files           = [
        '/opt/csw/var/amanda/amandates',
      ]
    }
    'RedHat':  {
      $configs_directory      = '/etc/amanda'
      $homedir                = '/var/lib/amanda'
      $uid                    = '33'
      $user                   = $::lsbmajdistrelease ? {
        '5'     => 'amanda',
        default => 'amandabackup',
      }
      $comment                = 'Amanda admin'
      $shell                  = '/bin/sh'
      $group                  = 'disk'
      $groups                 = [ ]
      $xinetd_unsupported     = true
      $generic_package        = undef
      $client_package         = 'amanda-client'
      $server_package         = 'amanda-server'
      $server_provides_client = false
      $amandad_path           = $::architecture ? {
        'x86_64' => '/usr/lib64/amanda/amandad',
        'i386'   => '/usr/lib/amanda/amandad',
      }
      $amandaidx_path         = $::architecture ? {
        'x86_64' => '/usr/lib64/amanda/amindexd',
        'i386'   => '/usr/lib/amanda/amindexd',
      }
      $amandataped_path       = $::architecture ? {
        'x86_64' => '/usr/lib64/amanda/amidxtaped',
        'i386'   => '/usr/lib/amanda/amidxtaped',
      }
      $amanda_directories     = [
      ]
      $amanda_files           = [
      ]
    }
    'FreeBSD': {
      $configs_directory      = '/usr/local/etc/amanda'
      $homedir                = '/var/db/amanda'
      $uid                    = '59500'
      $user                   = 'amanda'
      $comment                = 'Amanda backup user'
      $shell                  = '/bin/sh'
      $group                  = $::operatingsystemrelease ? {
        /^[4567]|^8\.[10]/ => 'operator', # FreeBSD versions < 8.2 suck
        default            => 'amanda',   # FreeBSD >= 8.2 uses amanda group
      }
      $groups                 = [ 'operator' ]
      $client_package         = 'misc/amanda-client'
      $server_package         = 'misc/amanda-server'
      $server_provides_client = false # idunno
      $amandad_path           = '/usr/local/libexec/amanda/amandad'
      $amandaidx_path         = '/usr/local/libexec/amanda/amindexd'
      $amandataped_path       = '/usr/local/libexec/amanda/amidxtaped'
      $amanda_directories     = [
        '/tmp/amanda',
        '/tmp/amanda/amandad',
        '/usr/local/var/amanda',
        '/usr/local/var/amanda/gnutar-lists',
      ]
      $amanda_files           = [
      ]
    }
    'Suse':  {
      $configs_directory      = '/etc/amanda'
      $homedir                = '/var/lib/amanda'
      $uid                    = '37'
      $user                   = 'amanda'
      $comment                = 'Amanda admin'
      $group                  = 'amanda'
      $groups                 = [ 'tape' ]
      $generic_package        = 'amanda'
      $server_provides_client = true  # there's only one package on suse
      $amandad_path           = '/usr/lib/amanda/amandad'
      $amandaidx_path         = '/usr/lib/amanda/amindexd'
      $amandataped_path       = '/usr/lib/amanda/amidxtaped'
      $amanda_directories     = [
        '/tmp/amanda',
        '/tmp/amanda/amandad',
      ]
      $amanda_files           = [
      ]
    }
    default:   {
      $configs_directory      = '/etc/amanda'
      $homedir                = '/var/lib/amanda'
      $uid                    = '59500'
      $user                   = 'amandabackup'
      $comment                = 'Amanda backup user'
      $shell                  = '/bin/sh'
      $group                  = 'backup'
      $groups                 = [ ]
      $xinetd_unsupported     = true
      $client_package         = 'amanda-client'
      $server_package         = 'amanda-server'
      $server_provides_client = false # idunno
      $amandad_path           = '/usr/libexec/amanda/amandad'
      $amandaidx_path         = '/usr/libexec/amanda/amindexd'
      $amandataped_path       = '/usr/libexec/amanda/amidxtaped'
      $amanda_directories     = [
        '/tmp/amanda',
        '/tmp/amanda/amandad',
      ]
      $amanda_files           = [
      ]
    }
  }

  $server_daemons = 'amdump amindexd amidxtaped'
  $client_daemons = 'amdump'
}
