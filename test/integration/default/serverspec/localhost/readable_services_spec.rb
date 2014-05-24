# encoding: UTF-8
require 'spec_helper'

describe 'Ebook Management Server' do

  context 'loale should be set properly' do
    describe command('echo $LANG') do
      its(:stdout) { should match 'en_US.utf8' }
    end
    describe command('echo $LC_ALL') do
      its(:stdout) { should match 'en_US.utf8' }
    end
  end

  home_dir = '/home/calibre'
  library_dir = "#{home_dir}/library"

  context 'The environment should be set up' do
    %w(libtool fontconfig libxt6 libltdl7 vim).each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end

  context 'A calibre group should be created to run calibre' do
    describe group('calibre') do
      it { should exist }
    end
  end

  context 'A calibre user should be created to run calibre with proper homedir' do
    # TODO: check that user is system user
    describe user('calibre') do
      it { should exist }
      it { should belong_to_group 'calibre' }
      it { should have_home_directory home_dir }
    end
    describe file(home_dir) do
      it { should be_directory }
    end
  end

  context 'Caliber installation script should be present' do
    describe file('/usr/local/bin/calibre-linux-installer.py') do
      it { should be_file }
      it { should be_readable }
      it { should_not be_writable }
      it { should be_executable.by('owner') }
      it { should_not be_executable.by('group') }
      it { should_not be_executable.by('others') }
    end
  end

  context 'Caliber should be installed' do
    describe file('/opt/calibre') do
      it { should be_directory }
    end

    describe file('/opt/calibre/calibre') do
      it { should be_file }
    end
  end

  context 'An empty library should be created' do
    describe file(library_dir) do
      it { should be_directory }
    end

    describe file("#{library_dir}/metadata.db") do
      it { should be_file }
    end
  end

  context 'A calibre script should be created' do
    describe file('/etc/init.d/calibre-server') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_readable }
      it { should be_writable.by('owner') }
      it { should_not be_writable.by('group') }
      it { should_not be_writable.by('others') }
      it { should be_executable }
    end
  end

  context 'Caliber should be set up as a service and running' do
    describe service('calibre-server') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'Caliber should run with the calibre user' do
    describe process('calibre-server') do
      it { should be_running }
      its('user') { should == 'calibre' }
    end
  end

  context 'An empty book should be added to the library' do
    describe command("calibredb list --with-library #{library_dir}") do
      its(:stdout) { should match(/Empty Test Book/) }
    end
  end

end
