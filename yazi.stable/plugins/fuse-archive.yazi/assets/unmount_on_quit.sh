#!/usr/bin/env bash

# check if any other yazi instance is still running
if [ "$(pgrep -c yazi)" -le 1 ]; then
  # get mount points
  fuse_archive_mnt_points=$(findmnt --output TARGET --noheadings --list | grep "^${1}/yazi/fuse-archive" | sort -r)
  # Loop through each mount point and force unmount
  while IFS= read -r mnt_point; do
    if [[ -n "$mnt_point" ]]; then
      umount "$mnt_point"
    fi
  done <<<"$fuse_archive_mnt_points"
fi
