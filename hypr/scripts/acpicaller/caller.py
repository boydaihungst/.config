import sys
import os
import subprocess
import acpivalues

def SetPowerMode(powermode):
    if(powermode == "intelligent"):
        subprocess.getoutput("echo " + acpivalues.intelligent_cooling + acpivalues.acpi_destination)
    elif(powermode == "saving"):
        subprocess.getoutput("echo " + acpivalues.battery_saving + acpivalues.acpi_destination)
    elif(powermode == "extreme"):
        subprocess.getoutput("echo " + acpivalues.extreme_performance + acpivalues.acpi_destination)

def SetRapidCharge(rapidcharge):
    if(rapidcharge == "1"):
        subprocess.getoutput("echo " + acpivalues.rapid_charge_on + acpivalues.acpi_destination)
    elif(rapidcharge == "0"):
        subprocess.getoutput("echo " + acpivalues.rapid_charge_off + acpivalues.acpi_destination)

def SetBatteryConservation(batteryConservation):
    if(batteryConservation == "1"):
        subprocess.getoutput("echo " + acpivalues.battery_conservation_on + acpivalues.acpi_destination)
    elif(batteryConservation == "0"):
        subprocess.getoutput("echo " + acpivalues.battery_conservation_off + acpivalues.acpi_destination)

def VerifyModes():
    powermode = subprocess.getoutput(acpivalues.verify_powermode)
    print("Powermode: " + powermode)
    rapidcharge = subprocess.getoutput(acpivalues.verify_rapid_charge)
    print("Rapid charge: " + rapidcharge)
    batteryconservation = subprocess.getoutput(acpivalues.verify_battery_conservation)
    print("Battery conservation: " + batteryconservation)

def QuietVerify():
    powermode = subprocess.getoutput(acpivalues.verify_powermode)
    print(powermode)
    rapidcharge = subprocess.getoutput(acpivalues.verify_rapid_charge)
    print(rapidcharge)
    batteryconservation = subprocess.getoutput(acpivalues.verify_battery_conservation)
    print(batteryconservation)
