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

require 'spec_helper'
require 'mount_helper'

mount_options =
  generate_mount_options(
    size: generate_mount_size(10 * 1024 * 1024)
  )

mount_with = {
  device: 'tmpfs',
  type: 'tmpfs'
}

mount_with[:options] = mount_options unless mount_options.empty?

describe file('/mnt/ramdisk1') do
  it { should be_directory }
  if platform == 'freebsd'
    it { should be_mounted }
  else
    it { should be_mounted.with(mount_with) }
  end
end

describe file('/etc/fstab') do
  its(:content) do
    should match %r{^tmpfs\s+/mnt/ramdisk1\s+tmpfs\s+.*size=10485760\s+0\s+0$}
  end
end
