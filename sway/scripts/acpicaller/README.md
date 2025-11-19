# Usage

To use this script you would invoke it as follows

```sh
$ acpicaller --powermode --batteryconservation --rapidcharge
```

Where powermode has three different options: intelligent, extreme and saving.
Batteryconservation and rapidcharge are set using the bits, so for instance, to enable rapid charge and disable battery conservation you would invoke a command such as:

```sh
$ acpicaller --rapidcharge 1 --batteryconservation 0
```

The verification bits are as follows:

- Power mode intelligent cooling: 0x0
- Power mode extreme performance: 0x1
- Power mode battery saving: 0x2
- Battery conservation enabled: 0x1
- Battery conservation disabled: 0x0
- Rapid charge enabled: 0x1
- Rapid charge disabled: 0x0

For a more detailed explanation please head to (insert link)

Credits to the original author of acpicaller: https://github.com/adramaxxx/dotfiles
