# encoding: UTF-8
#
# Cookbook Name:: ramdisk
# Library:: lwrp_helpers
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

require 'etc'

class Chef
  module Ramdisk
    # Helper methods to use from default LWRP
    module LwrpHelpers
      extend Forwardable
      %w(uid gid).each do |m|
        def_delegator :new_resource, m
      end

      def assert_require_size
        return unless new_resource.size.nil?
        fail Exceptions::ValidationFailed, 'Required argument size is missing!'
      end

      def uid_from_user
        return unless uid.nil? && !new_resource.user.nil?
        uid(Etc.getpwnam(new_resource.user).uid)
      end

      def gid_from_group
        return unless gid.nil? && !new_resource.group.nil?
        gid(Etc.getgrnam(new_resource.group).gid)
      end

      def remount?
        return false unless node['ramdisk']['supports']['remount']
        resource = Chef::Ramdisk::MountResourceHelper.new(
          new_resource.path, 'tmpfs'
        )
        resource.load_current_resource
        resource.mount_options_changed?(mount_resource)
      end

      def default_mount_options
        node['ramdisk']['options']['default'].dup
      end

      def resource_method(meth)
        meth.sub(/^nr_/, '') # remove "nr_" prefix
      end

      def mount_options_flags
        flags = node['ramdisk']['options']['flags']
        flags.each_with_object(default_mount_options) do |f, opts|
          meth = resource_method(f)
          opts << f if new_resource.send(meth)
        end
      end

      def mount_options_variables
        vars = node['ramdisk']['options']['variables']
        vars.each_with_object([]) do |v, opts|
          meth = resource_method(v)
          unless new_resource.send(meth).nil?
            opts << "#{v}=#{new_resource.send(meth)}"
          end
        end
      end

      def mount_options
        mount_options_flags + mount_options_variables
      end

      def resource_run_action(r, actions)
        actions = [actions].flatten
        actions.each do |action|
          r.run_action(action)
          new_resource.updated_by_last_action(true) if r.updated_by_last_action?
        end
      end

      def mount_resource
        @mount_resource ||= mount new_resource.name do
          mount_point new_resource.path
          pass 0
          fstype 'tmpfs'
          device 'tmpfs'
          supports remount: node['ramdisk']['supports']['remount']
        end
      end

      def mount_resource_run_action(a)
        mount_resource.options(mount_options)
        mount_resource.action(:nothing)
        resource_run_action(mount_resource, a)
      end

      def directory_resource
        @directory_resource ||= directory new_resource.name do
          path new_resource.path
        end
      end

      def mount_directory_run_action(a)
        directory_resource.action(:nothing)
        resource_run_action(directory_resource, a)
      end
    end
  end
end
