# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
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

require 'spec_helper'
require 'mount_helper'

mount_options =
  generate_mount_options(
    size: generate_mount_size('8m'),
    noexec: true,
    nosuid: true,
    nodev: true,
    noatime: true,
    nodiratime: true,
    mode: 755,
    uid: 1999,
    gid: 1999,
    inodes_option => generate_mount_inodes('999k')
  )

mount_with = {
  device: 'tmpfs',
  type: 'tmpfs'
}

mount_with[:options] = mount_options unless mount_options.empty?

describe file('/mnt/ramdisk3') do
  it { should be_directory }
  if platform == 'freebsd'
    it { should be_mounted }
  else
    it { should be_mounted.with(mount_with) }
    it { should be_readable.by_user('bob') }
  end
end

describe file('/etc/fstab') do
  its(:content) { should_not match %r{^tmpfs /mnt/ramdisk3 } }
end
