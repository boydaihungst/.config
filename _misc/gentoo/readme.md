sudo tar -cvpj /etc/portage /var/lib/portage/world | gpg -c -o portage*backup*$(date +%F).tar.bz2.gpg
sudo gpg -d portage*backup*...gpg | tar -xvj
