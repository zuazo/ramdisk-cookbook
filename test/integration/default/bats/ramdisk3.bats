#!/usr/bin/env bats

@test "creates ramdisk3 directory" {
  [ -d '/mnt/ramdisk3' ]
}

@test "mounts ramdisk3" {
  mount | grep '^tmpfs on \/mnt\/ramdisk3'
}

@test "sets ramdisk3 disk space" {
  df -BM /mnt/ramdisk3 | grep -E '^tmpfs[[:space:]]+8M[[:space:]]'
}
