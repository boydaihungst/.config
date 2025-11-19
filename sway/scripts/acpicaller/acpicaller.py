#!/usr/bin/python
import sys
import argparse
import caller

if __name__ == "__main__":
    #print("imp4l3r python script for acpicalling on ideapad 5")
    #print("Switched to python because I got very very tired of bash")
    my_parser = argparse.ArgumentParser()
    my_parser.add_argument('--powermode', help='Three different modes, intelligent cooling, extreme performance or battery saving, given as: <intelligent, extreme, saving>')
    my_parser.add_argument('--batteryconservation', help="Requires true or false bit", default="")
    my_parser.add_argument('--rapidcharge', help="Requires true or false bit", default="")
    my_parser.add_argument('--verify', help="outputs current states of modes", action='store_true' )
    my_parser.add_argument('--quiet', help="mute some parts of execution", action='store_true' )

    args = my_parser.parse_args()
    caller.SetPowerMode(args.powermode)
    caller.SetBatteryConservation(args.batteryconservation)
    caller.SetRapidCharge(args.rapidcharge)
    if args.verify:
        caller.VerifyModes()
    elif len(sys.argv) == 1:
        my_parser.print_help()
    elif args.quiet:
        caller.QuietVerify()
