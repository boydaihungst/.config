## Fix suspend-then-hibernate and hybrid-sleep lenovo legion 5 2025 cpu AMD + iGPU amd + eGPU Nvidia

### Prerequisites:

- Installed Nvidia drivers: `yay -S lib32-nvidia-utils libvdpau linux-firmware-nvidia nvidia-hook nvidia-open nvidia-prime nvidia-settings nvidia-utils`
  Then reboot.

### Step 1: Create a swap partition:

Making a swap partition with Gparted

Boot your machine with the Live ISO and open Gparted. Select the last partition on your HDD (this can either be the Root partition or the Home partition, depending on how you partitioned your disk) and shrink the partition by leaving a disk space free equal to the size of your RAM or double the size, that’s up to you. Then select the free space and mark it as a swap partition, let Gparted do its work, and boot back into your installed system and swap should be recognized by systemd.

For other swap type: https://discovery.endeavouros.com/storage-and-partitions/adding-swap-after-installation/2021/03/

- Get UUID of swap partition from Gparted: `c9e3e688-8dfb-45ea-95d9-949b4b44618b`

- ADD swap to `/etc/fstab`: `UUID=c9e3e688-8dfb-45ea-95d9-949b4b44618b none swap defaults 0 0`

- Enable swap: `sudo swapon -a`

### Step 2: Edit `/etc/kernel/cmdline`:

- Get GPIO pins that interrupt the ACPI from suspend: https://wiki.archlinux.org/title/Power_management/Wakeup_triggers#Ryzen_7000_Series

  ```bash
  sudo su -
  echo 1 > /sys/power/pm_debug_messages
  systemctl suspend-then-hibernate
  ```

  Wait a little bit and after it auto wakes up, you can check the logs:

  ```bash
  sudo dmesg | grep GPIO
  ```

  it should return some lines like this:

  ```bash
  kernel: GPIO 4 is active: 0x30047ce0
  kernel: GPIO 89 is active: 0x30047ce0
  ```

  We get 2 pins 4 and 89 that are active, so we can ignore them: `gpiolib_acpi.ignore_interrupt=AMDI0030:00@4,AMDI0030:00@89`. If there are more pins, just add them to the list: `gpiolib_acpi.ignore_interrupt=AMDI0030:00@4,AMDI0030:00@89,AMDI0030:00@10,AMDI0030:00@11`

  Now you get this `gpiolib_acpi.ignore_interrupt=AMDI0030:00@4,AMDI0030:00@89`

- Get UUID of swap partition which is created in step 1 using Gparted (right mount click to the partition): `c9e3e688-8dfb-45ea-95d9-949b4b44618b` => `resume=UUID=c9e3e688-8dfb-45ea-95d9-949b4b44618b`

- Final result, append this to `/etc/kernel/cmdline` file:

  `resume=UUID=c9e3e688-8dfb-45ea-95d9-949b4b44618b amdgpu.dcdebugmask=0x10 nvidia_drm.modeset=1 acpi_osi=! "acpi_osi=Windows 2015" gpiolib_acpi.ignore_interrupt=AMDI0030:00@4,AMDI0030:00@89`

### Step 3: Copy files under `etc` to `/etc`, except `kernel/cmdline.example`

### Step 4: Enable hybrid-sleep service:

- Copy folder `usr` to `/usr`: `sudo cp -r usr /usr`

- Enable nvidia services:

  ```bash
  sudo systemctl enable nvidia-{hibernate,persistenced,powerd,resume,suspend,suspend-then-hibernate,hybrid-sleep}.service
  ```

- Now reboot and test it:

  ```bash
  systemctl suspend-then-hibernate
  # This may not works as expected, consider using suspend-then-hibernate instead

  systemctl hybrid-sleep
  ```

If the power button led blink, it means it works.

## Lenovo Vantage for legion 5 2025, other legion 5 versions should works, I guess.

For now only battery conservation works, not sure about rapid charging.

Prerequisites: Installed `acpi_call acpi`.  
For Archlinux: `sudo pacman -S acpi_call acpi`

```bash
chmod +x ./hypr/scripts/acpicaller/acpicaller.sh
sudo ./hypr/scripts/acpicaller/acpicaller.sh --powermode --batteryconservation --rapidcharge
```

Then select whatever mode you want to use. But keep in mind that rapid charge mode should be disable when using battery conservation mode on.

Battery Conservation Mode is a feature that limits battery charging to 55-60% (70-80% for legion 5 2025 R7000P) of its capacity to improve battery life, being most useful when the laptop tends to run on external power much of the time.

Credits to the original author of acpicaller: https://github.com/adramaxxx/dotfiles

## For function buttons

```dosini
# Check hypr/conf/bind.conf file
# Volume Controls
bindl = , XF86AudioMute, exec, $volumectl togmute
bindle = , XF86AudioRaiseVolume, exec, $volumectl --volume-step 1 up
bindle = , XF86AudioLowerVolume, exec, $volumectl --volume-step 1 down

# Backlight
bindle = , XF86MonBrightnessUp, exec, $brightnesschange 5%+
bindle = , XF86MonBrightnessDown, exec, $brightnesschange 5%-

# Toggle touchpad
bindl = , XF86TouchpadOff, exec, hyprctl -r keyword "device[elan06fa:00-04f3:327e-touchpad]:enabled" false
bindl = , XF86TouchpadOn, exec, hyprctl -r keyword "device[elan06fa:00-04f3:327e-touchpad]:enabled" true

bindl = , XF86Calculator, exec, galculator

# Media Controls
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioStop, exec, playerctl stop
bindl = , XF86AudioPrev, exec, playerctl previous
bindl = , XF86AudioNext, exec, playerctl next
# bind = , KEY_PLAYPAUSE, exec, playerctl play-pause
bindl = , XF86AudioPause, exec, playerctl pause
bindl = , XF86AudioStop, exec, playerctl stop
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPrev, exec, playerctl previous
bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bindl = , XF86WLAN, exec, nmcli radio wifi toggle
# Lenovo legion 5 copilot AI button
bindl = $mode SHIFT, XF86TouchpadOff, exec, $toggle_gemini
# Edit this with your script, I personally don't have a script to switch hdmi output
bindl = $mod, p, exec, notify-send "Switch Video Mode key pressed"
```
