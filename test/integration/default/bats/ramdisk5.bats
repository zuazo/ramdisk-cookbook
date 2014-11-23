#!/usr/bin/env bats

@test "creates ramdisk5 directory" {
  [ -d '/mnt/ramdisk5' ]
}

@test "mounts ramdisk5" {
  mount | grep '^tmpfs on \/mnt\/ramdisk5'
}

@test "sets ramdisk5 disk space" {
  df -BM /mnt/ramdisk5 | grep -E '^tmpfs[[:space:]]+10M[[:space:]]'
}
