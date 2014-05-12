# encoding: UTF-8
require 'spec_helper'

describe 'ebook-management-server::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      log_level: :error
    )
    Chef::Config.force_logger true
    runner.converge('recipe[ebook-management-server::default]')
  end

  it 'creates remote_file linux-installer.py with correct mode' do
    expect(chef_run).to create_remote_file_if_missing('/usr/local/bin/linux-installer.py').with(mode: '0544')
  end

  it 'runs the linux-installer.py python script' do
    expect(chef_run).to run_execute('/usr/local/bin/linux-installer.py')
  end
end
