# encoding: UTF-8
require 'spec_helper'

describe 'Ebook Management Server' do

  context 'The environment should be set up' do
    %w(libtool fontconfig libxt6 libltdl7).each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end

  context 'A calibre user should be created to run calibre' do
    describe user('calibre') do
      it { should exist }
      # it should have the correct rights (used to run calibre server without root)'
    end
  end

  context 'A calibre group should be created to run calibre' do
    describe group('calibre') do
      it { should exist }
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

  context 'A default settings file should be created for calibre' do
    describe file('/etc/default/calibre-server') do
      it { should be_file }
    end
  end

  context 'A calibre script should be created' do
    describe file('/etc/init.d/calibre-server') do
      it { should be_file }
      it { should be_readable }
      it { should be_writable.by('owner') }
      it { should_not be_writable.by('group') }
      it { should_not be_writable.by('others') }
      it { should be_executable }
    end
  end

  context 'Caliber should be set up as a service with default settings' do
    describe service('calibre-server') do
      it { should be_enabled }
    end
  end

  context 'Caliber should run with the calibre user' do
    describe process('calibre-server') do
      it { should be_running }
      its('user') { should == 'root' }
    end
  end

end
