include amanda::params

class { 'amanda::server':
  configs        => [ 'demo' ],
  configs_source => 'modules/amanda/server',
}

class { 'amanda::client':
  server => 'localhost',
}

exec { 'amanda::test::demo':
  provider => shell,
  user     => $amanda::params::user,
  path     => '/bin:/usr/bin:/usr/sbin',
  command  => 'for i in 1 2 3 4 5 6 7 8 9; do mkdir /tmp/slot$i; amlabel demo V00$i slot $i; done; mkdir /tmp/amanda_demo;',
  require  => Class['amanda::server'],
  creates  => '/tmp/slot1',
}
