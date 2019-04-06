class { 'amanda::server':
  configs        => [ 'example' ],
  configs_source => 'modules/amanda/server',
}
