# encoding: UTF-8
#
# Cookbook Name:: ramdisk
# Provider:: default
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

Chef::Provider.send(:include, Chef::Ramdisk::LwrpHelpers)

action :create do
  new_resource.updated_by_last_action(false) # avoid FC017
  assert_require_size
  uid_from_user
  gid_from_group
  mount_directory_run_action(:create)
  mount_resource_run_action(:mount)
  mount_resource_run_action(:enable) if new_resource.persist
  mount_resource_run_action(:remount) if remount?
end

action :delete do
  new_resource.updated_by_last_action(false) # avoid FC017
  mount_resource_run_action(:disable) if new_resource.persist
  mount_resource_run_action(:umount)
  mount_directory_run_action(:delete)
end
