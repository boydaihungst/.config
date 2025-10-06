Fix suspend-then-hibernate and hybrid-sleep lenovo legion 5 2025 cpu AMD + iGPU amd + eGPU Nvidia

Prerequisites:

- Installed Nvidia drivers: `yay -S lib32-nvidia-utils libvdpau linux-firmware-nvidia nvidia-hook nvidia-open nvidia-prime nvidia-settings nvidia-utils`
  Then reboot.

Step 1: Create a swap partition:

Making a swap partition with Gparted

Boot your machine with the Live ISO and open Gparted. Select the last partition on your HDD (this can either be the Root partition or the Home partition, depending on how you partitioned your disk) and shrink the partition by leaving a disk space free equal to the size of your RAM or double the size, that’s up to you. Then select the free space and mark it as a swap partition, let Gparted do its work, and boot back into your installed system and swap should be recognized by systemd.

For other swap type: https://discovery.endeavouros.com/storage-and-partitions/adding-swap-after-installation/2021/03/

- Get UUID of swap partition from Gparted: `c9e3e688-8dfb-45ea-95d9-949b4b44618b`

- ADD swap to `/etc/fstab`: `UUID=c9e3e688-8dfb-45ea-95d9-949b4b44618b none swap defaults 0 0`

- Enable swap: `sudo swapon -a`

Step 2: Edit `/etc/kernel/cmdline`:

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

Step 3: Copy files under `etc` to `/etc`, except `kernel/cmdline.example`
Step 4: Enable hybrid-sleep service:

- Copy folder `usr` to `/usr`: `sudo cp -r usr /usr`

- Enable nvidia services:

  ```bash
  sudo systemctl enable nvidia-{hibernate,persistenced,powerd,resume,suspend,suspend-then-hibernate,hybrid-sleep}.service
  ```

- Now reboot and test it:

  ```bash
  systemctl sleep-then-hibernate
  # or
  systemctl hybrid-sleep
  ```

If the power botton led blink, it means it works.
