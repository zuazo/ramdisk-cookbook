# encoding: UTF-8
#
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

def platform
  File.exist?('/etc/centos-release') ? 'centos' : os[:family].downcase
end

def platform_version
  os[:release].to_f
end

def default_mount_options
  { rw: true }
end

def inodes_option
  platform == 'freebsd' ? :inodes : :nr_inodes
end

def generate_mount_options(opts)
  options = default_mount_options.merge(opts)
  options.reject { |x| x == :relatime } # fix for CentOS 7
  if platform == 'freebsd'
    %w(rw size uid gid).each { |k| options.delete(k.to_sym) }
  end
  puts options.inspect
  options
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

def bytes2kbytes(bytes)
  case bytes
  when Fixnum, /^[0-9]+$/ then "#{(bytes.to_i / 1024).round}k"
  when /^[0-9]+m$/ then "#{(bytes.to_i * 1024).round}k"
  when /^[0-9]+g$/ then "#{(bytes.to_i * 1_048_576).round}k"
  else
    bytes
  end
end

def generate_mount_size(num)
  if (%w(centos debian).include?(platform) && platform_version >= 7) ||
     (%w(ubuntu).include?(platform) && platform_version >= 15) ||
     %w(fedora opensuse).include?(platform)
    bytes2kbytes(num)
  else
    num
  end
end

def generate_mount_inodes(num)
  if (%w(centos debian).include?(platform) && platform_version >= 7) ||
     (%w(ubuntu).include?(platform) && platform_version >= 15) ||
     %w(fedora suse).include?(platform)
    bytes2integer(num)
  else
    num
  end
end
