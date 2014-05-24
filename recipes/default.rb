# encoding: UTF-8
#
# Cookbook Name:: ebook-management-system
# Recipe:: default
#
# Copyright (C) 2014 Emmanuel Sciara
#
# All rights reserved - Do Not Redistribute
#

lang='en_US.utf8'
lc_all='en_US.utf8'
language='en_US.utf8'

execute "Update locale" do
  command "update-locale LANG=#{lang} LC_ALL=#{lc_all} LANGUAGE=#{language}"
  user 'root'
  not_if { 
    locale = IO.read('/etc/default/locale')
    locale.include?("LANG=#{lang}") && locale.include?("LC_ALL=#{lc_all}") && locale.include?("LANGUAGE=#{language}")
  }
end

home_dir = '/home/calibre'
library_dir = "#{home_dir}/library"

%w(libtool fontconfig libxt6 libltdl7 vim build-essential ruby1.9.3).each do |pkg|
  package pkg
end

group 'calibre'

user 'calibre' do
  comment 'User to Run Calibre'
  home home_dir
  system true
  supports :manage_home => true
  gid 'calibre'
end

remote_file '/usr/local/bin/calibre-linux-installer.py' do
  source 'https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py'
  mode '0544'
  action :create_if_missing
end

execute '/usr/local/bin/calibre-linux-installer.py'

service 'calibre-server' do
  supports :restart => true
end

cookbook_file '/etc/init.d/calibre-server' do
  source 'calibre-server.sh'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :enable, 'service[calibre-server]'
  notifies :start, 'service[calibre-server]'
end

execute 'Adding an empty test book to the library' do
  command "calibredb add --title 'Empty Test Book' --empty test-book --with-library #{library_dir}"
  user 'calibre'
end
