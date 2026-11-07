# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'amanda::client' do
  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<~PUPPET
        class { 'amanda::client':
          server => 'backup.example.com',
        }

        amanda::ssh_authorized_key { 'backup.example.com':
          key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC',
        }
      PUPPET
    end
  end

  describe package('amanda-client') do
    it { is_expected.to be_installed }
  end

  describe user(amanda_user) do
    it { is_expected.to exist }
    it { is_expected.to have_home_directory amanda_homedir }
  end

  describe file("#{amanda_homedir}/.amandahosts") do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by amanda_user }
    it { is_expected.to be_mode 600 }
    its(:content) { is_expected.to match(%r{^backup\.example\.com #{amanda_user} amdump$}) }
  end

  describe file("#{amanda_homedir}/.ssh/authorized_keys") do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match(%r{-auth=ssh amdump" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC #{amanda_user}/backup\.example\.com$}) }
  end

  describe file('/etc/dumpdates') do
    it { is_expected.to be_file }
  end

  describe port(10_080) do
    it { is_expected.to be_listening.with('tcp') }
  end
end
