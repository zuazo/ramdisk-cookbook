#!/usr/bin/env bats

@test "creates ramdisk4 directory" {
  [ -d '/mnt/ramdisk4' ]
}

@test "mounts ramdisk4" {
  mount | grep '^tmpfs on \/mnt\/ramdisk4'
}

@test "sets ramdisk4 disk space" {
  df -BM /mnt/ramdisk4 | grep -E '^tmpfs[[:space:]]+5M[[:space:]]'
}
