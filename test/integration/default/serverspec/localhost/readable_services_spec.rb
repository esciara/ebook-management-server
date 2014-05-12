# encoding: UTF-8
require 'spec_helper'

describe 'Ebook Management Server' do

  describe file('/usr/local/bin/linux-installer.py') do
    it { should be_file }
    it { should be_readable }
    it { should_not be_writable }
    it { should be_executable.by('owner') }
    it { should_not be_executable.by('group') }
    it { should_not be_executable.by('others') }
  end

  describe file('/opt/calibre') do
    it { should be_directory }
  end

  describe file('/opt/calibre/calibre') do
    it { should be_file }
  end

end
