# encoding: UTF-8
#
# Cookbook Name:: ramdisk_test
# Recipe:: default
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

group 'foo' do
  gid 1999
end

user 'bob' do
  uid 1999
  gid 1999
end

ramdisk '/mnt/ramdisk1' do
  size 10 * 1024 * 1024 # == 10m
end

ramdisk '/mnt/ramdisk2 (create)' do
  path '/mnt/ramdisk2'
  size '20m'
  action :create
end

ramdisk '/mnt/ramdisk2 (delete)' do
  path '/mnt/ramdisk2'
  action :delete
end

ramdisk '/mnt/ramdisk3' do
  size '8m'
  persist false
  # flags
  nosuid true
  nodev true
  noexec true
  noatime true
  nodiratime true
  # variables
  inodes '999k'
  mode '755'
  uid 1999
  gid 1999
end

ramdisk '/mnt/ramdisk4' do
  size '5m'
  user 'bob'
  group 'foo'
end

ramdisk '/mnt/ramdisk5 (initial)' do
  path '/mnt/ramdisk5'
  size '5m'
end

ramdisk '/mnt/ramdisk5 (resize)' do
  path '/mnt/ramdisk5'
  size '10m'
end
