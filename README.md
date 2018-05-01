# Amanda module for Puppet

[![Build Status](https://travis-ci.org/voxpupuli/puppet-amanda.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-collectd)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-amanda/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-collectd)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/amanda.svg)](https://forge.puppetlabs.com/puppet/collectd)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/amanda.svg)](https://forge.puppetlabs.com/puppet/collectd)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/amanda.svg)](https://forge.puppetlabs.com/puppet/collectd)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/amanda.svg)](https://forge.puppetlabs.com/puppet/collectd)

## Description

Provides Amanda Network Backup server and client configuration through Puppet

## Usage

The amanda module allows specifying parameterized classes that will do most of
the heavy lifting in a single definition (relying on sane defaults), or for
more custom configuration the utility defines can be used directly. What
follows is a minimal-effort configuration that trusts the module to figure out
the details.

```puppet
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
```

Of note is the `configs_source` parameter. While the amanda module will
install and configure server and client machines, it does not yet attempt to build
amanda configs using puppet code. Rather, that legwork is still left up to the
administrator, and the module will only ensure that the files which comprise
the config are present on the server.

If you need to create configs from templates or other sources, then by setting
`manage_configs_source` to `false` will disable extraction via the mechanism
below, you are then free to assign puppet file resources as appropriate to
create your configs.

Additional parameters are available for both the `amanda::server` and
`amanda::client` classes which are not documented here. At present the only
way to look up how to use them is to read the source.

## How Configs Work

Use the following Puppet DSL code to ensure the "daily" and "archive" configs
are created on an amanda backup server.

```puppet
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
```

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
specified in the `amanda::config` resource. For the example above, the files
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

## Additional Types

Besides the primary classes `amanda::server` and `amanda::client`, three utility
defines are included in the module.

### `Amanda::Amandahosts`

The `amanda::amandahosts` type manages the .amandahosts file, which controls
access to amanda services. The important parameter to this resource is
`content`, and the user must specify the full access line to include. For
example,

```puppet
amanda::amandahosts { 'replicator-amdump':
  content => "replicator.cat.pdx.edu backup amdump",
}
```

### `Amanda::Config`

The `amanda::config` type synchronizes a directory of files in a given module to
a client. A more detailed example is given in the preceding section.

```puppet
amanda::config { 'daily':
  ensure            => present,
  configs_source    => 'modules/data/amanda',
  configs_directory => '/etc/amanda',
}
```

### `Amanda::Ssh_authorized_key`

The `amanda::ssh_authorized_key` type is a convenience define used to install
ssh authentication on an amanda client. The important parameter for this type
is `key`.

```puppet
amanda::ssh_authorized_key { 'replicator':
  key => hiera('pubkey/backup@replicator'),
}
```

### `Amanda::Disklist::Dle`

The `amanda::disklist::dle` type is used to add/remove disk list entries
from the Amanda disklist(5) file, which is used by Amanda to determine which
disks will be backed up.

Requirements:

* Puppet `storeconfigs` must be enabled
* `amanda::config` must be used to synchronize configuration files with the
  `manage_dle` parameter set to `true`, i.e. `manage_dle => true`. This
  must be set for each `amanda::config` if more than one has been configured.

```puppet
amanda::disklist::dle { '/etc':
   configs  => 'daily',
   dumptype => 'dumptype',
}

amanda::disklist::dle { '/var':
   configs  => [ 'daily', 'weekly' ],
   dumptype => 'dumptype',
}

```

## Known Issues

* The module does not include tests

* The module does not allow overriding of the client/server package name(s)

## Contributors

* Darin Perusich <darin@darins.net>
* Jon Harker <jesusaurus@cat.pdx.edu>
* Reid Vandewiele <marut@cat.pdx.edu>
* William Van Hevelingen <blkperl@cat.pdx.edu>
