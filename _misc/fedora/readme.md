```bash
systemctl --user enable --now \
          gpg-agent.socket \
          gpg-agent-ssh.socket \
          gpg-agent-extra.socket
```

```bash
systemctl --user list-unit-files --state enabled
UNIT FILE                      STATE   PRESET
dbus-broker.service            enabled enabled
fumon.service                  enabled enabled
hypridle.service               enabled disabled
hyprpaper.service              enabled disabled
hyprpolkitagent.service        enabled disabled
mpDris2.service                enabled disabled
obex.service                   enabled enabled
pactl-auto-switch-sink.service enabled disabled
systemd-tmpfiles-setup.service enabled enabled
wireplumber.service            enabled enabled
xdg-user-dirs.service          enabled enabled
dbus.socket                    enabled enabled
gpg-agent-extra.socket         enabled disabled
gpg-agent-ssh.socket           enabled disabled
gpg-agent.socket               enabled disabled
mpd.socket                     enabled disabled
pipewire-pulse.socket          enabled enabled
pipewire.socket                enabled enabled
grub-boot-success.timer        enabled enabled
systemd-tmpfiles-clean.timer   enabled enabled
trash-empty.timer              enabled disabled
```

```
repo id                                             repo name
copr:copr.fedorainfracloud.org:dejan:lazygit        Copr repo for lazygit owned by dejan
copr:copr.fedorainfracloud.org:lionheartp:Hyprland  Copr repo for Hyprland owned by lionheartp
copr:copr.fedorainfracloud.org:pesader:showmethekey Copr repo for showmethekey owned by pesader
fedora                                              Fedora 44 - x86_64
fedora-cisco-openh264                               Fedora 44 openh264 (From Cisco) - x86_64
home_justkidding                                    home:justkidding (Fedora_44)
rpmfusion-free                                      RPM Fusion for Fedora 44 - Free
rpmfusion-free-updates                              RPM Fusion for Fedora 44 - Free - Updates
rpmfusion-nonfree                                   RPM Fusion for Fedora 44 - Nonfree
rpmfusion-nonfree-tainted                           RPM Fusion for Fedora 44 - Nonfree tainted
rpmfusion-nonfree-updates                           RPM Fusion for Fedora 44 - Nonfree - Updates
updates                                             Fedora 44 - x86_64 - Updates
vivaldi                                             vivaldi
```
