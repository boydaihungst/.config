Compress and encrypt gentoo portage packages, settings
`sudo tar -cvpj /etc/portage /var/lib/portage/world | gpg -c -o portage_backup_$(date +%F).tar.bz2.gpg`

Decompress and extract
`sudo gpg -d portage_backup_...gpg | tar -xvj`

## Partitions

/dev/nvme0n1p5: TYPE="vfat"
/dev/nvme0n1p8: LABEL="boot" TYPE="ext4"
/dev/nvme0n1p6: TYPE="crypto_LUKS" PARTLABEL="Gentoo"
/dev/mapper/root: LABEL="rootfs" TYPE="btrfs"

Check fstab

## This prevent nvida card laptop from black screen when hibernate

Enable secureboot with sbctl and build kernel to auto sign nvidia driver otherwise open-source driver won't start at boot

```bash
sudo emerge --config sys-kernel/gentoo-kernel
sudo rc-update del nvidia-powerd
sudo rc-update add nvidia-persistenced default
```

only use suspend-then-hibernate. hybrid-sleep is not working
Disable any power management app, TLP, power-profiles-daemon, etc, otherwise hibernate will not work (black screen)

## Use lightdm as default display manager

check lightdm.conf
