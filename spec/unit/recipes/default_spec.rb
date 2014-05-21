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

  %w(libtool fontconfig libxt6 libltdl7).each do |pkg|
    it "installs #{pkg} package" do
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'creates a calibre user (with the correct rights?)' do
    expect(chef_run).to create_user('calibre')
  end

  it 'creates a calibre group' do
    expect(chef_run).to create_group('calibre').with(members: ['calibre'])
  end

  it 'creates remote_file calibre-linux-installer.py with correct mode' do
    expect(chef_run).to create_remote_file_if_missing('/usr/local/bin/calibre-linux-installer.py').with(mode: '0544')
  end

  it 'runs the calibre-linux-installer.py script' do
    expect(chef_run).to run_execute('/usr/local/bin/calibre-linux-installer.py')
  end

  it 'creates a data directory for calibre owned by root:root' do
    expect(chef_run).to create_directory('/var/calibre').with(
      owner:  'root',
      group:  'root',
      mode:   '0644'
    )
  end

  it 'creates a service for calibre' do
    resource = chef_run.service('calibre-server')
    expect(resource).to do_nothing
  end

  it 'creates calibre start/stop script and starts the calibre content server as user calibre (currently root... to be changed)' do
    expect(chef_run).to create_cookbook_file('/etc/init.d/calibre-server').with(
      source: 'calibre-server.sh',
      owner: 'root',
      group: 'root',
      mode: '0755'
    )
    calibre_script_resource = chef_run.cookbook_file('/etc/init.d/calibre-server')
    expect(calibre_script_resource).to notify('service[calibre-server]').to(:enable).delayed
    expect(calibre_script_resource).to notify('service[calibre-server]').to(:start).delayed
  end

  it 'creates calibre default settings file' do
    expect(chef_run).to create_template('/etc/default/calibre-server').with(
      source: 'calibre-server.config.erb',
      owner: 'root',
      group: 'root',
      mode: '0644'
    )
    calibre_config_resource = chef_run.template('/etc/default/calibre-server')
    expect(calibre_config_resource).to notify('service[calibre-server]').to(:restart).delayed
  end

end
