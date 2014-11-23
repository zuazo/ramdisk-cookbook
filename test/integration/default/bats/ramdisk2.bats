#!/usr/bin/env bats

@test "ramdisk2 directory does not exist" {
  ! [ -d '/mnt/ramdisk2' ]
}

@test "ramdisk2 is not mounted" {
  ! mount | grep '^tmpfs on \/mnt\/ramdisk2'
}
