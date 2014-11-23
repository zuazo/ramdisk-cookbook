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
require 'chef/exceptions'
require 'lwrp_helpers'
require 'support/fake_provider'
require 'mount_resource_helper'

describe Chef::Ramdisk::LwrpHelpers, order: :random do
  let(:path) { '/mnt/ramdisk1' }
  let(:node) do
    node = Chef::Node.new
    Dir.glob("#{::File.dirname(__FILE__)}/../../attributes/*.rb") do |f|
      node.from_file(f)
    end
    node
  end
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:new_resource) { Chef::Resource.new(path, run_context) }
  let(:provider) { Chef::FakeProvider.new(new_resource, run_context) }
  flags = %w(nosuid nodev noexec noatime nodiratime)
  vars = %w(mode uid gid size nr_inodes mode mpol)
  before do
    allow(new_resource).to receive(:path).and_return(new_resource.name)
    flags.each do |f|
      allow(new_resource).to receive(f).and_return(nil)
    end
    vars.each do |v|
      meth = v.sub(/^nr_/, '')
      allow(new_resource).to receive(meth).and_return(nil)
    end
  end

  describe '#uid_from_user' do
    let(:user) { Etc::Passwd.new('bob', nil, 1999) }
    before do
      allow(new_resource).to receive(:uid).with(1999)
      allow(Etc).to receive(:getpwnam).with('bob').and_return(user)
    end
    after { provider.uid_from_user }

    context 'with new_resource#user not set' do
      before do
        allow(new_resource).to receive(:uid).with(no_args).and_return(nil)
        allow(new_resource).to receive(:user).with(no_args).and_return(nil)
      end

      it 'does not set new_resource#uid' do
        expect(new_resource).to_not receive(:uid).with(anything)
      end

    end # context with new_resource#user not set

    context 'with new_resource#uid set' do
      before do
        allow(new_resource).to receive(:uid).with(no_args).and_return(1999)
        allow(new_resource).to receive(:user).with(no_args).and_return('bob')
      end

      it 'does not set new_resource#uid' do
        expect(new_resource).to_not receive(:uid).with(anything)
      end

    end # context with new_resource#uid set

    context 'with new_resource#user set' do
      before do
        allow(new_resource).to receive(:uid).with(no_args).and_return(nil)
        allow(new_resource).to receive(:user).with(no_args).and_return('bob')
      end

      it 'gets the system uid' do
        expect(Etc).to receive(:getpwnam).with('bob').once.and_return(user)
      end

      it 'sets new_resource#uid' do
        expect(new_resource).to receive(:uid).with(1999).once
      end
    end # context with new_resource#user set
  end # describe #uid_from_user

  describe '#gid_from_group' do
    let(:group) { Etc::Group.new('foo', nil, 1999) }
    before do
      allow(new_resource).to receive(:gid).with(1999)
      allow(Etc).to receive(:getgrnam).with('foo').and_return(group)
    end
    after { provider.gid_from_group }

    context 'with new_resource#group not set' do
      before do
        allow(new_resource).to receive(:gid).with(no_args).and_return(nil)
        allow(new_resource).to receive(:group).with(no_args).and_return(nil)
      end

      it 'does not set new_resource#gid' do
        expect(new_resource).to_not receive(:gid).with(anything)
      end

    end # context with new_resource#group not set

    context 'with new_resource#gid set' do
      before do
        allow(new_resource).to receive(:gid).with(no_args).and_return(1999)
        allow(new_resource).to receive(:group).with(no_args).and_return('foo')
      end

      it 'does not set new_resource#gid' do
        expect(new_resource).to_not receive(:gid).with(anything)
      end

    end # context with new_resource#gid set

    context 'with new_resource#group set' do
      before do
        allow(new_resource).to receive(:gid).with(no_args).and_return(nil)
        allow(new_resource).to receive(:group).with(no_args).and_return('foo')
      end

      it 'gets the system uid' do
        expect(Etc).to receive(:getgrnam).with('foo').once.and_return(group)
      end

      it 'sets new_resource#gid' do
        expect(new_resource).to receive(:gid).with(1999).once
      end
    end # context with new_resource#group set
  end # describe #gid_from_group

  describe '#remount?' do
    let(:mount_resource_helper) { 'mount_resource_helper' }
    let(:result) { 'result' }
    before do
      allow(Chef::Ramdisk::MountResourceHelper).to receive(:new)
        .and_return(mount_resource_helper)
      allow(mount_resource_helper).to receive(:load_current_resource)
      allow(mount_resource_helper).to receive(:mount_options_changed?)
        .and_return(true)
      allow(mount_resource_helper).to receive(:mount_options_changed?)
        .with(any_args).and_return(result)
    end

    context 'without remount support' do
      before { node.set['ramdisk']['supports']['remount'] = false }

      it 'returns false' do
        expect(provider.remount?).to eq(false)
      end
    end # without remount support

    # TODO
    context 'with remount support' do
      before { node.set['ramdisk']['supports']['remount'] = true }
      after { provider.remount? }

      it 'creates new MountResourceHelper instance' do
        expect(Chef::Ramdisk::MountResourceHelper).to receive(:new)
          .with(path, 'tmpfs').once.and_return(mount_resource_helper)
      end

      it 'calls MountResourceHelper#load_current_resource' do
        expect(mount_resource_helper).to receive(:load_current_resource)
          .with(no_args).once
      end

      it 'calls MountResourceHelper#mount_options_changed?' do
        expect(mount_resource_helper).to receive(:mount_options_changed?)
          .with(provider.mount_resource).once.and_return(true)
      end

      it 'returns MountResourceHelper#mount_options_changed?' do
        expect(provider.remount?).to eq(result)
      end
    end # with remount support
  end # describe #remount?

  describe '#assert_require_size' do
    before do
      allow(new_resource).to receive(:size).and_return(nil)
    end

    context 'with size set' do
      before { allow(new_resource).to receive(:size).and_return(10) }
      it 'raises no error' do
        expect { provider.assert_require_size }.to_not raise_error
      end
    end # context with size set

    context 'with no size set' do
      before do
        allow(new_resource).to receive(:size).and_return(nil)
      end

      it 'raises an error' do
        expect { provider.assert_require_size }.to raise_error(
            Chef::Exceptions::ValidationFailed,
            'Required argument size is missing!'
        )
      end

    end # context with size set
  end # describe #assert_require_size

  describe '#mount_options_flags' do
    before do
      flags.each do |f|
        allow(new_resource).to receive(f).and_return("#{f}1")
      end
    end
    flags.each do |f|
      context "with #{f} flag" do
        it "calls new_resource##{f}" do
          expect(new_resource).to receive(f).once.and_return('ok')
          provider.mount_options_flags
        end

        it 'returns flag' do
          expect(provider.mount_options_flags).to include(f)
        end

        context 'when not set' do
          before { allow(new_resource).to receive(f).and_return(nil) }

          it 'does not return flag' do
            expect(provider.mount_options_flags).to_not include(f)
          end
        end # context when not set
      end # context with f flag
    end # flags each f

    it 'returns an array of flags' do
      expect(provider.mount_options_flags).to be_a(Array)
    end
  end # describe #mount_options_flags

  describe '#mount_options_variables' do
    before do
      vars.each do |v|
        meth = v.sub(/^nr_/, '')
        allow(new_resource).to receive(meth).and_return("#{v}1")
      end
    end
    vars.each do |v|
      meth = v.sub(/^nr_/, '')
      context "with #{v} var" do
        it "calls new_resource##{meth}" do
          expect(new_resource).to receive(meth).twice.and_return('ok')
          provider.mount_options_variables
        end

        it 'returns var' do
          expect(provider.mount_options_variables).to include("#{v}=#{v}1")
        end

        context 'when not set' do
          before { allow(new_resource).to receive(meth).and_return(nil) }

          it 'does not return var' do
            expect(provider.mount_options_variables).to_not include("#{v}=")
          end
        end # context when not set
      end # context with v var
    end # vars each v

    it 'returns an array of vars' do
      expect(provider.mount_options_variables).to be_a(Array)
    end
  end # describe #mount_options_variables

  describe '#mount_options' do
    let(:flags) { %w(flags) }
    let(:variables) { %w(var1=val1) }
    before do
      allow(provider).to receive(:mount_options_flags).and_return(flags)
      allow(provider).to receive(:mount_options_variables).and_return(variables)
    end

    it 'merges flags and variables options' do
      expect(provider.mount_options).to eq(flags + variables)
    end

  end # describe #mount_options

  describe '#resource_run_action' do
    let(:r) { new_resource }
    actions = %w(action1 action2)
    before do
      actions.each do |action|
        allow(r).to receive(:run_action).with(action)
      end
      allow(new_resource).to receive(:updated_by_last_action)
      allow(new_resource).to receive(:updated_by_last_action?).and_return(true)
    end
    after { provider.resource_run_action(r, actions) }

    actions.each do |action|
      context "with #{action} action" do
        it "calls run_action(#{action})" do
          expect(r).to receive(:run_action).with(action).once
        end
      end
    end # each action

    context 'with updated_by_last_action' do
      before do
        allow(new_resource).to receive(:updated_by_last_action?)
          .and_return(true)
      end

      it 'calls #updated_by_last_action' do
        expect(new_resource).to receive(:updated_by_last_action).with(true)
          .twice
      end
    end # context with updated_by_last_action

    context 'without updated_by_last_action' do
      before do
        allow(new_resource).to receive(:updated_by_last_action?)
          .and_return(false)
      end

      it 'calls #updated_by_last_action' do
        expect(new_resource).to_not receive(:updated_by_last_action).with(true)
      end
    end # context without updated_by_last_action
  end # describe #resource_run_action

  describe '#mount_resource_run_action' do
    let(:mount) { 'Chef::Resource::Mount' }
    let(:mount_options) { %w(option1 option2=val2) }
    before do
      allow(mount).to receive(:node).and_return(node)
      allow(mount).to receive(:new_resource).and_return(new_resource)
      allow(provider).to receive(:mount) do |&block|
        mount.instance_eval(&block)
      end.and_return(mount)
      allow(provider).to receive(:mount_options).and_return(mount_options)
      %w(supports mount_point pass fstype device options action).each do |meth|
        allow(mount).to receive(meth)
      end
      allow(mount).to receive(:run_action)
      allow(mount).to receive(:updated_by_last_action?).and_return(true)
    end
    after { provider.mount_resource_run_action([:mount, :enable]) }

    it 'creates the mount resource' do
      expect(provider).to receive(:mount).with(new_resource.name).once
    end

    it 'sets mount resource mount_point property to resource path' do
      expect(mount).to receive(:mount_point).with(new_resource.path).once
    end

    it 'sets mount resource options property' do
      expect(mount).to receive(:options).with(mount_options).once
    end

    {
      pass: 0,
      fstype: 'tmpfs',
      device: 'tmpfs',
      action: :nothing
    }.each do |property, value|
      it "sets mount resource #{property} property to #{value.inspect}" do
        expect(mount).to receive(property).with(value).once
      end
    end # each property, value

    it 'runs mount resource mount action' do
      expect(mount).to receive(:run_action).with(:mount)
    end

    it 'runs mount resource enable action' do
      expect(mount).to receive(:run_action).with(:enable)
    end

    context 'when mount resource updated' do
      before do
        allow(mount).to receive(:updated_by_last_action?).and_return(true)
      end

      it 'updates current resource last action' do
        expect(new_resource).to receive(:updated_by_last_action).with(true)
          .twice
      end
    end # context when mount resource updated

    context 'when mount resource not updated' do
      before do
        allow(mount).to receive(:updated_by_last_action?).and_return(false)
      end

      it 'doest not update current resource last action' do
        expect(new_resource).not_to receive(:updated_by_last_action)
      end
    end # context when mount resource updated
  end # describe #mount_resource_run_action

  describe '#mount_directory_run_action' do
    let(:directory) { 'Chef::Resource::Directory' }
    before do
      allow(directory).to receive(:new_resource).and_return(new_resource)
      allow(provider).to receive(:directory) do |&block|
        directory.instance_eval(&block)
      end.and_return(directory)
      allow(new_resource).to receive(:path).and_return(new_resource.name)
      %w(path action).each { |meth| allow(directory).to receive(meth) }
      allow(directory).to receive(:run_action)
      allow(directory).to receive(:updated_by_last_action?).and_return(true)
    end
    after { provider.mount_directory_run_action(:create) }

    it 'creates the directory resource' do
      expect(provider).to receive(:directory).with(new_resource.name).once
    end

    it 'sets directory resource path property' do
      expect(directory).to receive(:path).with(new_resource.name).once
    end

    it 'sets directory resource action property to nothing' do
      expect(directory).to receive(:action).with(:nothing).once
    end

    it 'runs directory resource create action' do
      expect(directory).to receive(:run_action).with(:create)
    end

    context 'when directory resource updated' do
      before do
        allow(directory).to receive(:updated_by_last_action?).and_return(true)
      end

      it 'updates current resource last action' do
        expect(new_resource).to receive(:updated_by_last_action).with(true).once
      end
    end # context when directory resource updated

    context 'when directory resource not updated' do
      before do
        allow(directory).to receive(:updated_by_last_action?).and_return(false)
      end

      it 'doest not update current resource last action' do
        expect(new_resource).not_to receive(:updated_by_last_action)
      end
    end # context when directory resource updated
  end # describe #mount_directory_run_action
end
