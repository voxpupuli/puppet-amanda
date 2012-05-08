# Amanda module for Puppet

## Description

Provides Amanda Network Backup server and client configuration through Puppet

## Usage

The amanda module allows specifying parameterized classes that will do most of
the heavy lifting in a single definition (relying on sane defaults), or for
more custom configuration the utility defines can be used directly. What
follows is a minimal-effort configuration that trusts the module to figure out
the details.

    node 'backup.cat.pdx.edu' {
      class { 'amanda::server':
        configs        => [ 'daily', 'archive' ],
        configs_source => 'modules/data/amanda',
      }
    }

    node 'client.cat.pdx.edu' {
      class { 'amanda::client':
        server => 'backup.cat.pdx.edu',
      }
    }

Of note is the `configs_source` parameter. While the amanda module will
install and configure server and client machines, it does not yet attempt to build
amanda configs using puppet code. Rather, that legwork is still left up to the
administrator, and the module will only ensure that the files which comprise
the config are present on the server.

Additional parameters are available for both the `amanda::server` and
`amanda::client` classes which are not documented here. At present the only
way to look up how to use them is to read the source.

## How Configs Work

Use the following Puppet DSL code to ensure the "daily" and "archive" configs
are created on an amanda backup server.

    node 'backup.cat.pdx.edu' {
      file { '/etc/amanda':
        ensure => directory;
      }

      amanda::config { 'daily':
        ensure            => present,
        configs_source    => 'modules/data/amanda',
        configs_directory => '/etc/amanda',
      }
      amanda::config { 'archive':
        ensure            => present,
        configs_source    => 'modules/data/amanda',
        configs_directory => '/etc/amanda',
      }
    }

Then place your config files in the "files" directory of the module specified
with the `configs_source` parameter. For the code above, files that make up
the "archive" and "daily" amanda configs should be placed in the `data` module
as per this example:

    data
    |-- files
    |   `-- amanda
    |       |-- daily
    |       |   |-- amanda.conf
    |       |   |-- chg-multi.conf
    |       |   |-- disklist
    |       |   `-- label-templates
    |       |       |-- 3hole.ps
    |       |       |-- 8.5x11.ps
    |       |       |-- DIN-A4.ps
    |       |       |-- DLT-A4.ps
    |       |       |-- DLT.ps
    |       |       |-- EXB-8500.ps
    |       |       |-- HP-DAT.ps
    |       |       `-- tapetypes.conf
    |       `-- archive
    |           |-- amanda.conf
    |           |-- chg-scsi.conf
    |           |-- disklist
    |           `-- dumptypes.conf
    |-- LICENSE
    `-- README

The contents of the `config` directory ("daily" or "archive") will be synced
as file resources to the location specified with the `configs_directory`
specified in the amanda::config resource. For the example above, the files
will be synced to the agent system as:

    /
    |-- etc
    |   |-- amanda
    |   |   |-- daily
    .   |   |   |-- amanda.conf
    .   .   |   |-- chg-multi.conf
    .   .   |   |-- disklist
        .   |   `-- label-templates
            |       |-- 3hole.ps
            |       |-- 8.5x11.ps
            |       |-- DIN-A4.ps
            |       |-- DLT-A4.ps
            |       |-- DLT.ps
            |       |-- EXB-8500.ps
            |       |-- HP-DAT.ps
            |       `-- tapetypes.conf
            `-- archive
                |-- amanda.conf
                |-- chg-scsi.conf
                |-- disklist
                `-- dumptypes.conf

## Known Issues

It doesn't have any kind of storeconfigs magic that could be used to
dynamically generate the disklist file. That would be pretty cool. Totally
haven't done it yet.

## Contributors

Darin Perusich <darin@darins.net>
Jon Harker <jesusaurus@cat.pdx.edu>
Reid Vandewiele <marut@cat.pdx.edu>
William Van Hevelingen <blkperl@cat.pdx.edu>
