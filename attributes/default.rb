# encoding: UTF-8
#
# Cookbook Name:: ramdisk
# Attributes:: default
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

default['ramdisk']['options']['default'] = %w(rw)
if node['platform'] == 'freebsd'
  default['ramdisk']['options']['flags'] =
    %w(nosuid noexec)
  default['ramdisk']['options']['variables'] =
    %w(mode uid gid size inodes)
  default['ramdisk']['supports']['remount'] = false
else
  default['ramdisk']['options']['flags'] =
    %w(nosuid nodev noexec noatime nodiratime)
  default['ramdisk']['options']['variables'] =
    %w(mode uid gid size nr_inodes mpol)
  default['ramdisk']['supports']['remount'] = true
end
