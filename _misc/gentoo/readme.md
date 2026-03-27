sudo tar -cvpj /etc/portage /var/lib/portage/world | gpg -c -o portage*backup*$(date +%F).tar.bz2.gpg
sudo gpg -d portage*backup*...gpg | tar -xvj

sudo rc-update del nvidia-powerd
sudo rc-update add nvidia-persistenced default

only use suspend-then-hibernate
