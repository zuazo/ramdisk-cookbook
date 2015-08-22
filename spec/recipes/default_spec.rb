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

describe 'ramdisk_test::default', order: :random do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  context 'ramdisk_test cookbook' do
    before do
      user = Etc::Passwd.new('bob', nil, 1999)
      group = Etc::Group.new('foo', nil, 1999)
      allow(Etc).to receive(:getpwnam).with('bob').and_return(user)
      allow(Etc).to receive(:getgrnam).with('foo').and_return(group)
    end

    it 'creates foo group' do
      expect(chef_run).to create_group('foo')
        .with_gid(1999)
    end

    it 'creates bob user' do
      expect(chef_run).to create_user('bob')
        .with_uid(1999)
        .with_gid(1999)
    end

    it 'creates ramdisk1' do
      expect(chef_run).to create_ramdisk('/mnt/ramdisk1')
        .with_size(10 * 1024 * 1024)
    end

    it 'creates ramdisk2' do
      expect(chef_run).to create_ramdisk('/mnt/ramdisk2 (create)')
        .with_path('/mnt/ramdisk2')
        .with_size('20m')
    end

    it 'deletes ramdisk2' do
      expect(chef_run).to delete_ramdisk('/mnt/ramdisk2 (delete)')
        .with_path('/mnt/ramdisk2')
    end

    it 'creates ramdisk3' do
      expect(chef_run).to create_ramdisk('/mnt/ramdisk3')
        .with_persist(false)
        .with_nosuid(true)
        .with_nodev(true)
        .with_noexec(true)
        .with_noatime(true)
        .with_nodiratime(true)
        .with_inodes('999k')
        .with_mode('755')
        .with_uid(1999)
        .with_gid(1999)
    end

    it 'creates ramdisk4' do
      expect(chef_run).to create_ramdisk('/mnt/ramdisk4')
        .with_user('bob')
        .with_group('foo')
    end

    it 'creates ramdisk5' do
      expect(chef_run).to create_ramdisk('/mnt/ramdisk5 (initial)')
        .with_path('/mnt/ramdisk5')
        .with_size('5m')
    end

    it 'resizes ramdisk5' do
      expect(chef_run).to create_ramdisk('/mnt/ramdisk5 (resize)')
        .with_path('/mnt/ramdisk5')
        .with_size('10m')
    end
  end # context ramdisk_test cookbook
end
