rpm -qa --qf '%{NAME}\n' | sort -u > fedora-packages.txt
dnf repoquery --userinstalled --qf '%{name}' | sort -u > fedora-userinstalled.txt

sudo dnf install $(cat fedora-userinstalled.txt)
