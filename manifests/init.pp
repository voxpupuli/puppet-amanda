#
# Example usage:
#
# Server 'backup.cat.pdx.edu':
#
#   class { 'amanda::server':
#     configs        => ['daily', 'weekly'],
#     configs_source => 'modules/data/amanda',
#   }
#
#   Place amanda config files in:
#     data/files/amanda/daily/
#     data/files/amanda/weekly/
#
#   All files stored in the specified directories will be realized as file
#   resources and included in the catalog. They will be synced to the OS
#   appropriate location (e.g. /etc/amanda/daily).
#
# Client 'www1.cat.pdx.edu':
#
#   class { 'amanda::client':
#     server => 'backup.cat.pdx.edu',
#   }
#
# Manual Configuration:
#
#   file { '/etc/amanda':
#     ensure => directory;
#   }
#
#   amanda::config { 'rolling':
#     configs_directory => '/etc/amanda',
#     configs_source    => 'modules/amandaconf',
#   }
#
# Then place your config files in the "files" directory of the amandaconf
# module.
#
#   amandaconf/files/rolling/
#
# The contents of the 'rolling' directory in the module files will be synced
# to the configs_directory you specify in the amanda::config resource, e.g.
# /etc/amanda/rolling/.
#
class amanda {
  include amanda::params
  include amanda::virtual

  realize(
    File['/etc/dumpdates'],
    File["${amanda::params::homedir}/.ssh"],
    File["${amanda::params::homedir}/.ssh/config"],
    File["${amanda::params::homedir}/.ssh/authorized_keys"],
    File[$amanda::params::amanda_directories],
    File[$amanda::params::amanda_files],
    File[$amanda::params::homedir],
    User[$amanda::params::user],
  )
}
