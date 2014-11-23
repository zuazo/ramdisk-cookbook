#!/usr/bin/env bats

@test "creates ramdisk1 directory" {
  [ -d '/mnt/ramdisk1' ]
}

@test "mounts ramdisk1" {
  mount | grep '^tmpfs on \/mnt\/ramdisk1'
}

@test "sets ramdisk1 disk space" {
  df -BM /mnt/ramdisk1 | grep -E '^tmpfs[[:space:]]+10M[[:space:]]'
}
