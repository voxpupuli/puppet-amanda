# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'amanda::server' do
  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<~PUPPET
        class { 'amanda::server':
          configs        => ['demo'],
          configs_source => 'amanda/server',
        }
      PUPPET
    end
  end

  describe package('amanda-server') do
    it { is_expected.to be_installed }
  end

  describe file('/etc/amanda/demo') do
    it { is_expected.to be_directory }
    it { is_expected.to be_owned_by amanda_user }
  end

  describe file('/etc/amanda/demo/amanda.conf') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match(%r{^org "pdxcat/amanda"$}) }
  end

  describe file("#{amanda_homedir}/.amandahosts") do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match(%r{^localhost root amindexd amidxtaped$}) }
  end

  describe port(10_080) do
    it { is_expected.to be_listening.with('tcp') }
  end
end
