# frozen_string_literal: true

require 'spec_helper'

describe 'amanda' do
  let(:facts) do
    {
      networking: {
        fqdn: 'amanda.example.test',
        ip: '192.0.2.10',
      },
      os: {
        architecture: 'x86_64',
        family: 'RedHat',
        name: 'RedHat',
        release: {
          major: '8',
        },
      },
    }
  end

  let(:pre_condition) do
    <<~PUPPET
      amanda::config { ['daily', 'weekly']:
        configs_directory     => '/etc/amanda',
        manage_configs_source => false,
        manage_dle            => true,
      }

      amanda::disklist::dle { '/home':
        configs  => ['daily'],
        dumptype => 'standard',
      }

      amanda::disklist::dle { '/var':
        configs  => ['weekly'],
        dumptype => 'standard',
      }
    PUPPET
  end

  it 'adds each DLE fragment to its matching configuration disklist' do
    home_fragment = contain_concat__fragment('amanda::disklist/amanda.example.test//home@daily')
    var_fragment = contain_concat__fragment('amanda::disklist/amanda.example.test//var@weekly')

    expect(exported_resources).to home_fragment.with(target: '/etc/amanda/daily/disklist')
    expect(exported_resources).to var_fragment.with(target: '/etc/amanda/weekly/disklist')
  end
end
