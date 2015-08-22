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

require 'chef/mixin/shell_out'

class Chef
  module Ramdisk
    # Resource Helper class to read current mount options from the system
    class MountResourceHelper
      extend Chef::Mixin::ShellOut

      unless defined?(Chef::Ramdisk::MountResourceHelper::IGNORE_OPTIONS)
        IGNORE_OPTIONS = %w(rw relatime seclabel rootcontext)
      end

      attr_reader :resource

      def initialize(mount_point, device)
        @resource = Chef::Resource::Mount.new(device)
        @resource.mount_point(mount_point)
        @resource.device(device)
      end

      def bytes2integer(bytes)
        case bytes
        when /^[0-9]+k$/ then bytes.to_i * 1024
        when /^[0-9]+m$/ then bytes.to_i * 1_048_576
        when /^[0-9]+g$/ then bytes.to_i * 1_073_741_824
        else
          bytes.to_i
        end
      end

      def parse_options_string(options)
        parse_options_array(options.split(/, */))
      end

      def parse_options_array(options)
        options.each_with_object({}) do |option, memo|
          key, value = option.split('=', 2)
          key = key.sub(/^nr_/, '') # remove "nr_" prefix
          memo[key] = value.nil? ? true : value
        end
      end

      def parse_options_hash(options)
        options.each_with_object({}) do |(key, value), memo|
          key = key.to_s.sub(/^nr_/, '') # remove "nr_" prefix
          memo[key] = value
        end
      end

      def parse_options_to_hash(options)
        case options
        when String then parse_options_string(options)
        when Array then parse_options_array(options)
        when Hash then parse_options_hash(options)
        else
          options
        end
      end

      def ignore_options(options)
        return options unless options.respond_to?(:reject)
        options.reject { |x| IGNORE_OPTIONS.include?(x) }
      end

      def options_to_integers(options)
        return options unless options.respond_to?(:key?)
        %w(size inodes).each_with_object(options) do |key, memo|
          memo[key] = bytes2integer(memo[key]) if memo.key?(key)
        end
      end

      def parse_options(options)
        result = parse_options_to_hash(options)
        result = ignore_options(result)
        options_to_integers(result)
      end

      def real_mount_point
        if ::File.exist?(@resource.mount_point)
          ::File.realpath(@resource.mount_point)
        else
          @resource.mount_point
        end
      end

      def load_current_resource
        self.class.shell_out!('mount').stdout.each_line do |line|
          case line
          when /^#{Regexp.escape(@resource.device)}\s+on\s+
                #{Regexp.escape(real_mount_point)}\s+
                type\s+(\S+)\s+[(](\S+)[)]$/x
            @resource.fstype(Regexp.last_match[1])
            @resource.options(Regexp.last_match[2])
          end
        end
      end

      def mount_options_changed?(new)
        @resource.fstype != new.fstype ||
          parse_options(@resource.options) != parse_options(new.options)
      end
    end
  end
end
