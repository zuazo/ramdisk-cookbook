Ramdisk Cookbook
================
[![Cookbook Version](https://img.shields.io/cookbook/v/ramdisk.svg?style=flat)](https://supermarket.chef.io/cookbooks/ramdisk)
[![Dependency Status](http://img.shields.io/gemnasium/zuazo/ramdisk-cookbook.svg?style=flat)](https://gemnasium.com/zuazo/ramdisk-cookbook)
[![Code Climate](http://img.shields.io/codeclimate/github/zuazo/ramdisk-cookbook.svg?style=flat)](https://codeclimate.com/github/zuazo/ramdisk-cookbook)
[![Build Status](http://img.shields.io/travis/zuazo/ramdisk-cookbook/0.2.1.svg?style=flat)](https://travis-ci.org/zuazo/ramdisk-cookbook)
[![Coverage Status](http://img.shields.io/coveralls/zuazo/ramdisk-cookbook/0.2.1.svg?style=flat)](https://coveralls.io/r/zuazo/ramdisk-cookbook?branch=0.2.1)

This cookbook manages tmpfs RAM disks with [Chef](https://www.chef.io/).

Requirements
============

## Supported Platforms

This cookbook has been tested on the following platforms:

* CentOS
* Debian
* Fedora
* FreeBSD
* RedHat
* Ubuntu

FreeBSD support is somewhat limited due to its current implementation: the *remount* is not supported on this platform and some mount options are ignored.

Please, [let us know](https://github.com/zuazo/ramdisk-cookbook/issues/new?title=I%20have%20used%20it%20successfully%20on%20...) if you use it successfully on any other platform.

## Required Applications

* Ruby `1.9.3` or higher.

Resources
=========

## ramdisk[path]

Creates or deletes a RAM disk.

If you change the RAM disk size, the `ramdisk` resource will try to remount the disk without umounting.

### ramdisk Actions

* `create`: Creates a RAM disk (*default*).
* `delete`: Deletes a RAM disk.

### ramdisk Parameters

| Parameter  | Default          | Description                       |
|:-----------|:-----------------|:----------------------------------|
| path       | *name parameter* | tmpfs RAM disk mount path.
| size       | `nil`            | Size of the filesystem (**required**). The size is given in bytes. Also accepts a suffix *k*, *m* or *g*.
| persist    | `true`           | Whether to persist the RAM disk. **Note:** The data will not persist between reboots. This only creates the RAM disk on each boot.
| nosuid     | `false`          | Do not allow set-user-identifier or set-group-identifier bits to take effect.
| nodev      | `false`          | Do not interpret character or block special devices on the filesystem.
| noexec     | `false`          | Do not allow direct execution of any binaries on the mounted filesystem.
| noatime    | `false`          | Do not update inode access times on this filesystem.
| nodiratime | `false`          | Do not update directory inode access times on this filesystem.
| inodes     | `nil`            | The maximum number of inodes for this instance.
| mode       | `nil`            | Set initial permissions of the root directory.
| uid        | `nil`            | The user id.
| gid        | `nil`            | The group id.
| user       | `nil`            | The same as *uid*, but using user names.
| group      | `nil`            | The same as *gid*, but using group names.
| mpol       | `nil`            | Set the NUMA memory allocation policy for all files in that instance.

Attributes
==========

These attributes are primarily intended to support the different platforms. Do not touch them unless you know what you are doing.

| Attribute                                 | Default      | Description                       |
|:------------------------------------------|:-------------|:----------------------------------|
| `node['ramdisk']['options']['default']`   | `['rw']`     | Minimal default mount options to set.
| `node['ramdisk']['options']['flags']`     | *calculated* | Supported mount flag options: `nosuid`, `noexec`, ...
| `node['ramdisk']['options']['variables']` | *calculated* | Supported mount variable options: `size`=, `mode`=, `uid`=, ...
| `node['ramdisk']['supports']['remount']`  | *calculated* | Whether mount remount operation is supported.

Usage
=====

## Including in the metadata

Before using this cookbook, remember to put it as a dependency in your metadata:

```ruby
# metadata.rb
depends 'ramdisk'
```

## Basic Example

Create a 10MB tmpfs RAM disk:

```ruby
ramdisk '/mnt/ramdisk1' do
  size '10m'
end

```

## A Complex Example

Create a tmpfs RAM disk setting some options and the owner user:

```ruby
ramdisk '/tmp/secure_bob_ramdisk' do
  size '1g'
  user 'bob'
  group 'bob'
  persist false
  nosuid true
  nodev true
  noexec true
  noatime true
  inodes '999k'
  mode '750'
end
```

Testing
=======

See [TESTING.md](https://github.com/zuazo/ramdisk-cookbook/blob/master/TESTING.md).

## ChefSpec Matchers

### ramdisk(path)

Helper method for locating a `ramdisk` resource in the collection.

```ruby
resource = chef_run.ramdisk('/mnt/ramdisk1')
expect(resource).to notify('service[java-app]').to(:restart)
```

### create_ramdisk(path)

Assert that the Chef run creates a ramdisk.

```ruby
expect(chef_run).to create_ramdisk('/mnt/ramdisk1')
```

### delete_ramdisk(name)

Assert that the Chef run deletes a ramdisk.

```ruby
expect(chef_run).to delete_ramdisk('/mnt/ramdisk1')
```

Contributing
============

Please do not hesitate to [open an issue](https://github.com/zuazo/ramdisk-cookbook/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/zuazo/ramdisk-cookbook/blob/master/CONTRIBUTING.md).

TODO
====

See [TODO.md](https://github.com/zuazo/ramdisk-cookbook/blob/master/TODO.md).

License and Author
==================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@zuazo.org>)
| **Contributor:**     | [Hendrik Bergunde](https://github.com/hendrikb)
| **Copyright:**       | Copyright (c) 2015, Xabier de Zuazo
| **Copyright:**       | Copyright (c) 2014, Onddo Labs, SL.
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
