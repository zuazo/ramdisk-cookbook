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
require 'mount_resource_helper'

describe Chef::Ramdisk::MountResourceHelper, order: :random do
  let(:fixtures_dir) { ::File.join(::File.dirname(__FILE__), '..', 'fixtures') }
  let(:resource_helper) { described_class.new(mount_point, device) }
  let(:device) { 'tmpfs' }
  let(:mount_point) { '/mnt/ramdisk1' }
  before do
    allow(::File).to receive(:exist?).and_call_original
    allow(::File).to receive(:exist?).with(mount_point).and_return(false)
  end

  context '#bytes2integer' do
    {
      '2g' => 2 * 1024 * 1024 * 1024,
      '2m' => 2 * 1024 * 1024,
      '2k' => 2 * 1024,
      2 => 2
    }.each do |size, bytes|
      it "returns #{bytes} for #{size.inspect}" do
        expect(resource_helper.bytes2integer(size)).to eq(bytes)
      end
    end
  end

  context '#parse_options' do

    it 'supports string options' do
      opts = 'rw,nosuid,size=8192k,mode=755, nodiratime'
      expect(resource_helper.parse_options(opts)).to eq(
        'nosuid' => true,
        'size' => 8_388_608,
        'mode' => '755',
        'nodiratime' => true
      )
    end

    it 'supports array options' do
      opts = %w(rw nosuid size=8192k mode=755 nodiratime)
      expect(resource_helper.parse_options(opts)).to eq(
        'nosuid' => true,
        'size' => 8_388_608,
        'mode' => '755',
        'nodiratime' => true
      )
    end

    it 'supports hash options' do
      opts = {
        rw: true,
        nosuid: true,
        size: '8192k',
        mode: 755,
        nodiratime: true
      }
      expect(resource_helper.parse_options(opts)).to eq(
        'nosuid' => true,
        'size' => 8_388_608,
        'mode' => 755,
        'nodiratime' => true
      )
    end

    it 'supports unknown options format' do
      opts = Object.new
      expect(resource_helper.parse_options(opts)).to eq(opts)
    end

    %w(rw relatime seclabel rootcontext).each do |option|
      it "ignores #{option} option" do
        opts = { 'noatime' => true, option => true }
        expect(resource_helper.parse_options(opts)).to eq('noatime' => true)
      end
    end # each ignored option
  end

  [
    'CentOS 6.6',
    'CentOS 7.0',
    'Debian 7.7',
    'FreeBSD 10.0',
    'Fedora 19'
  ].each do |os|
    fixture_file = os.downcase.gsub(/[^a-z0-9]/, '')

    context "with #{os}" do
      before do
        mount = 'mount'
        fixtures = IO.read(::File.join(fixtures_dir, "mount_#{fixture_file}"))
        allow(mount).to receive(:stdout).and_return(fixtures)
        allow(resource_helper.class).to receive(:shell_out!).with('mount')
          .and_return(mount)
      end

      context 'with ramdisk3' do
        let(:mount_point) { '/mnt/ramdisk3' }

        # There is no need for FreeBSD support because it does not support
        # remount (2014-10)
        context '#load_current_resource' do
          it 'runs without errors' do
            resource_helper.load_current_resource
          end

          it 'sets fstype', unless: os.start_with?('FreeBSD') do
            resource_helper.load_current_resource
            expect(resource_helper.resource.fstype).to eq('tmpfs')
          end

          it 'sets options', unless: os.start_with?('FreeBSD') do
            resource_helper.load_current_resource
            options = resource_helper.resource.options
            %w(
              rw noexec nosuid nodev noatime nodiratime mode=755 uid=1999
              gid=1999
            ).each do |opt|
              expect(options).to include(opt)
            end
          end

          context 'when mount point exists' do
            before do
              allow(::File).to receive(:exist?).with(mount_point)
                .and_return(true)
            end

            it 'calls File#realpath' do
              # allow(::File).to receive(:realpath).and_call_original
              expect(::File).to receive(:realpath).with(mount_point)
                .at_least(1).times.and_return(mount_point)
              resource_helper.load_current_resource
            end
          end
        end

        context '#mount_options_changed?', unless: os.start_with?('FreeBSD') do
          let(:new_resource) do
            r = Chef::Resource::Mount.new(mount_point)
            r.mount_point(mount_point)
            r.device(device)
            r.fstype(device)
            r
          end
          before { resource_helper.load_current_resource }

          context 'with different fstype' do
            before { new_resource.fstype('ext4') }
            it 'returns true for different fstype' do
              expect(resource_helper.mount_options_changed?(new_resource))
                .to eq(true)
            end
          end # context with different fstype

          context 'with the same mount options' do
            before do
              new_resource.options(%w(
                rw nosuid nodev noexec noatime size=8192k nr_inodes=1022976
                mode=755 uid=1999 gid=1999 nodiratime
              ))
            end

            it 'returns true' do
              expect(resource_helper.mount_options_changed?(new_resource))
                .to eq(false)
            end
          end
        end # context #mount_options_changed?
      end # context with ramdisk3
    end # context with os
  end # each os
end
