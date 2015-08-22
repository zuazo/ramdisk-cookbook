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
  let(:chef_runner) { ChefSpec::SoloRunner.new(step_into: %w(ramdisk)) }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }

  context 'ramdisk_test cookbook' do
    before do
      user = Etc::Passwd.new('bob', nil, 1999)
      group = Etc::Group.new('foo', nil, 1999)
      allow(Etc).to receive(:getpwnam).with('bob').and_return(user)
      allow(Etc).to receive(:getgrnam).with('foo').and_return(group)
    end

    context 'ramdisk[/mnt/ramdisk1]' do
      it 'creates ramdisk1 directory' do
        expect(chef_run).to create_directory('/mnt/ramdisk1')
      end

      it 'mounts ramdisk1' do
        expect(chef_run).to mount_mount('/mnt/ramdisk1')
          .with_pass(0)
          .with_fstype('tmpfs')
          .with_device('tmpfs')
      end

      it 'adds ramdisk1 to fstab' do
        expect(chef_run).to enable_mount('/mnt/ramdisk1')
      end

      it 'mounts ramdisk1 with the correct size' do
        expect(chef_run).to mount_mount('/mnt/ramdisk1')
          .with_options(%w(rw size=10485760))
      end
    end # context ramdisk[/mnt/ramdisk1]

    context 'ramdisk[/mnt/ramdisk2]' do
      it 'creates ramdisk2 directory' do
        expect(chef_run).to create_directory('/mnt/ramdisk2')
      end

      it 'mounts ramdisk2' do
        expect(chef_run).to mount_mount('/mnt/ramdisk2 (create)')
          .with_mount_point('/mnt/ramdisk2')
      end

      it 'adds ramdisk2 to fstab' do
        expect(chef_run).to enable_mount('/mnt/ramdisk2 (create)')
          .with_mount_point('/mnt/ramdisk2')
      end

      it 'umounts ramdisk2' do
        expect(chef_run).to umount_mount('/mnt/ramdisk2 (delete)')
          .with_mount_point('/mnt/ramdisk2')
      end

      it 'removes ramdisk2 from fstab' do
        expect(chef_run).to disable_mount('/mnt/ramdisk2 (delete)')
          .with_mount_point('/mnt/ramdisk2')
      end

      it 'deletes ramdisk2 directory' do
        expect(chef_run).to delete_directory('/mnt/ramdisk2 (delete)')
          .with_path('/mnt/ramdisk2')
      end
    end # context ramdisk[/mnt/ramdisk2]

    context 'ramdisk[/mnt/ramdisk3]' do
      it 'creates /mnt/ramdisk3 directory' do
        expect(chef_run).to create_directory('/mnt/ramdisk3')
      end

      it 'creates ramdisk3' do
        expect(chef_run).to mount_mount('/mnt/ramdisk3')
      end

      it 'does not add ramdisk3 to the fstab' do
        expect(chef_run).to_not enable_mount('/mnt/ramdisk3')
      end

      it 'mounts ramdisk3 with full options' do
        expect(chef_run).to mount_mount('/mnt/ramdisk3')
          .with_options(%w(
            rw nosuid nodev noexec noatime nodiratime mode=755 uid=1999 gid=1999
            size=8m nr_inodes=999k
          ))
      end
    end # context ramdisk[/mnt/ramdisk3]

    context 'ramdisk[/mnt/ramdisk4]' do
      it 'creates /mnt/ramdisk4 directory' do
        expect(chef_run).to create_directory('/mnt/ramdisk4')
      end

      it 'creates ramdisk4' do
        expect(chef_run).to mount_mount('/mnt/ramdisk4')
      end

      it 'adds ramdisk4 to the fstab' do
        expect(chef_run).to enable_mount('/mnt/ramdisk4')
      end

      it 'mounts ramdisk4 with full options' do
        expect(chef_run).to mount_mount('/mnt/ramdisk4')
          .with_options(%w(rw uid=1999 gid=1999 size=5m))
      end
    end # context ramdisk[/mnt/ramdisk4]

    context 'ramdisk[/mnt/ramdisk5] (initial)' do
      it 'creates /mnt/ramdisk5 directory' do
        expect(chef_run).to create_directory('/mnt/ramdisk5 (initial)')
          .with_path('/mnt/ramdisk5')
      end

      it 'creates ramdisk5' do
        expect(chef_run).to mount_mount('/mnt/ramdisk5 (initial)')
          .with_mount_point('/mnt/ramdisk5')
      end

      it 'adds ramdisk5 to the fstab' do
        expect(chef_run).to enable_mount('/mnt/ramdisk5 (initial)')
          .with_mount_point('/mnt/ramdisk5')
      end

      it 'mounts ramdisk5 with the correct size' do
        expect(chef_run).to mount_mount('/mnt/ramdisk5 (initial)')
          .with_options(%w(rw size=5m))
      end
    end # context ramdisk[/mnt/ramdisk5] (initial)

    context 'ramdisk[/mnt/ramdisk5] (resize)' do
      it 'creates /mnt/ramdisk5 directory' do
        expect(chef_run).to create_directory('/mnt/ramdisk5 (resize)')
          .with_path('/mnt/ramdisk5')
      end

      it 'creates ramdisk5' do
        expect(chef_run).to remount_mount('/mnt/ramdisk5 (resize)')
          .with_mount_point('/mnt/ramdisk5')
      end

      it 'remounts ramdisk5 with the correct size' do
        expect(chef_run).to remount_mount('/mnt/ramdisk5 (resize)')
          .with_options(%w(rw size=10m))
      end
    end # context ramdisk[/mnt/ramdisk5] (initial)
  end # context ramdisk_test cookbook
end
