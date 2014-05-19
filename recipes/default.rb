# encoding: UTF-8
#
# Cookbook Name:: ebook-management-system
# Recipe:: default
#
# Copyright (C) 2014 Emmanuel Sciara
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'

%w(libtool fontconfig libxt6 libltdl7).each do |pkg|
  package pkg
end

include_recipe 'locale'

user 'calibre'

group 'calibre' do
  members 'calibre'
end

remote_file '/usr/local/bin/calibre-linux-installer.py' do
  source 'https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py'
  mode '0544'
  action :create_if_missing
end

execute '/usr/local/bin/calibre-linux-installer.py'

directory '/var/calibre' do
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file "#{Chef::Config[:file_cache_path]}/calibre-empty-library.tar" do
  source 'calibre-empty-library.tar'
  owner 'root'
  group 'root'
  mode '0444'
end

execute 'Extracting empty library to calibre data directory /var/calibre' do
  cwd Chef::Config[:file_cache_path]
  command <<-COMMAND
    tar -C /var/calibre -xf calibre-empty-library.tar
    chown -R calibre /var/calibre
  COMMAND
  creates '/var/calibre/Calibre Library'
end

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

template '/etc/default/calibre-server' do
  source 'calibre-server.config.erb'
  owner 'root'
  group 'root'
  mode '0444'
  notifies :restart, 'service[calibre-server]'
end
