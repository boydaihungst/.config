#!/bin/sh

echo -e "acpi caller script for thinkpad 5 \n"

echo -e '\t 1 intelligent cooling mode (0x0) \n'
echo -e '\t 2 extreme performance mode (0x1) \n'
echo -e '\t 3 battery saving mode (0x2) \n'
echo -e '\t 4 rapid charging mode on (0x1) \n'
echo -e '\t 5 rapid charging mode off (0x0) \n'
echo -e '\t 6 battery conservation mode on (0x1) \n'
echo -e '\t 7 battery conservation mode off (0x0) \n'

echo -n 'option : '
read OPTION

case $OPTION in
    1) echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' > /proc/acpi/call
        echo '\_SB.PCI0.LPC0.EC0.SPMO' > /proc/acpi/call
        ;;
    2) echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' > /proc/acpi/call
        echo '\_SB.PCI0.LPC0.EC0.SPMO' > /proc/acpi/call
        ;;
    3) echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' > /proc/acpi/call
        echo '\_SB.PCI0.LPC0.EC0.SPMO' > /proc/acpi/call
        ;;
    4) echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' > /proc/acpi/call
       echo '\_SB.PCI0.LPC0.EC0.QCHO' > /proc/acpi/call
        ;;
    5) echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' > /proc/acpi/call
        echo '\_SB.PCI0.LPC0.EC0.QCHO' > /proc/acpi/call
        ;;
    6) echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' > /proc/acpi/call
        echo '\_SB.PCI0.LPC0.EC0.BTSM' > /proc/acpi/call
        ;;
    7) echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' > /proc/acpi/call
        echo '\_SB.PCI0.LPC0.EC0.BTSM' > /proc/acpi/call
        ;;
esac
cat /proc/acpi/call | cut -d '' -f1
