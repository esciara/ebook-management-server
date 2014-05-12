# encoding: UTF-8
#
# Cookbook Name:: ebook-management-system
# Recipe:: default
#
# Copyright (C) 2014 Emmanuel Sciara
#
# All rights reserved - Do Not Redistribute
#

remote_file '/usr/local/bin/linux-installer.py' do
  source 'https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py'
  mode '0544'
  action :create_if_missing
end

execute '/usr/local/bin/linux-installer.py' do
end
