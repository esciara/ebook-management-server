# encoding: UTF-8
#
# Cookbook Name:: ebook-management-system
# Recipe:: default
#
# Copyright (C) 2014 Emmanuel Sciara
#
# All rights reserved - Do Not Redistribute
#

%w(libtool fontconfig libxt6 libltdl7 vim).each do |pkg|
  package pkg
end

group 'calibre'

user 'calibre' do
  comment 'User to Run Calibre'
  home '/home/calibre'
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
