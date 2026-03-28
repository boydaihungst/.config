Compress and encrypt gentoo portage packages, settings
`sudo tar -cvpj /etc/portage /var/lib/portage/world | gpg -c -o portage_backup_$(date +%F).tar.bz2.gpg`

Decompress and extract
`sudo gpg -d portage*backup*...gpg | tar -xvj`

# This prevent nvida card laptop from black screen when hibernate

```
sudo rc-update del nvidia-powerd
sudo rc-update add nvidia-persistenced default
```

only use suspend-then-hibernate. hybrid-sleep is not working
