#!/usr/bin/env python3
"""
Rapoo VT3 Pro Max / VT3 Max Gen-2 Battery Reader for Linux

Reads battery percentage and charging status from Rapoo gaming mice
connected via 2.4GHz USB dongle. No kernel module or proprietary driver needed.

Supported devices (VID 0x24AE):
  - VT3 Pro Max (PID 0x1244)
  - VT3 Pro (PID 0x1215)
  - VT3 Max Gen-2 (PID 0x3102)
  - VT9 Pro (PID 0x1417)
  - VT9 Pro Mini (PID 0x3103)

Battery report protocol (0xBB, 7 bytes):
  Byte 0: 0xBB  - Report marker
  Byte 1: 0xB0  - Status flags
  Byte 2: 0x81  - Mode flags
  Byte 3: 0x20  - Polling/connection info
  Byte 4: 0x03  - Connection type (2.4GHz)
  Byte 5: 0x00/0x01/0x02  - Charging state (transition/discharging/charging)
  Byte 6: 0x00-0x64  - Battery percentage (0-100)

The mouse sends battery reports approximately every 3 seconds, but the
battery percentage itself only changes every 5-10 minutes (firmware design).

A second report type (0xBC, 10 bytes) may appear during cable plug/unplug
transitions and is ignored by this script.

Usage:
    rapoo-battery              # Read battery once
    rapoo-battery --watch      # Monitor continuously
    rapoo-battery --json       # JSON output (generic)
    rapoo-battery --waybar     # Waybar-compatible JSON output
    rapoo-battery --raw        # Show raw report bytes
"""

import os
import sys
import time
import json
import argparse
import subprocess

RAPOO_VID = 0x24AE
RAPOO_PIDS = [0x1215, 0x1244, 0x3102, 0x1417, 0x3103]

BATTERY_REPORT_MARKER = 0xBB
CHARGING_STATE_CHARGING = 0x02
CHARGING_STATE_DISCHARGING = 0x01
CHARGING_STATE_TRANSITION = 0x00

DEFAULT_TIMEOUT = 15
DEFAULT_WATCH_INTERVAL = 5


def find_rapoo_hidraw():
    """Find the hidraw device for the Rapoo mouse vendor interface.

    The dongle exposes two HID interfaces. Interface 0 is the standard mouse
    (absolute position, buttons, wheel). Interface 1 contains vendor-defined
    HID collections including the battery status report.

    Returns the device path (e.g. /dev/hidraw7) or None.
    """
    try:
        result = subprocess.run(
            ["lsusb", "-d", f"{RAPOO_VID:04x}:"],
            capture_output=True, text=True, timeout=5,
        )
        if not result.stdout.strip():
            return None
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass

    fallback = None

    for entry in sorted(os.listdir("/dev")):
        if not entry.startswith("hidraw"):
            continue
        full_path = f"/dev/{entry}"
        try:
            result = subprocess.run(
                ["udevadm", "info", "-q", "property", "-n", full_path],
                capture_output=True, text=True, timeout=5,
            )
            props = {}
            for line in result.stdout.strip().splitlines():
                if "=" in line:
                    key, val = line.split("=", 1)
                    props[key] = val

            vid = int(props.get("ID_VENDOR_ID", "0"), 16)
            pid = int(props.get("ID_MODEL_ID", "0"), 16)

            if vid != RAPOO_VID or pid not in RAPOO_PIDS:
                continue

            ifnum = props.get("ID_USB_INTERFACE_NUM", "")
            if ifnum in ("1", "01"):
                return full_path
            elif fallback is None:
                fallback = full_path
        except (subprocess.TimeoutExpired, FileNotFoundError, ValueError):
            continue

    return fallback


def open_device(dev_path):
    """Open a hidraw device for reading. Returns file descriptor or None."""
    try:
        return os.open(dev_path, os.O_RDWR | os.O_NONBLOCK)
    except PermissionError:
        print(f"ERROR: Permission denied accessing {dev_path}", file=sys.stderr)
        print("Run with sudo, or set up a udev rule:", file=sys.stderr)
        print("  echo 'KERNEL==\"hidraw*\", ATTRS{idVendor}==\"24ae\", MODE=\"0666\"' | sudo tee /etc/udev/rules.d/99-rapoo-mouse.rules", file=sys.stderr)
        print("  sudo udevadm control --reload-rules && sudo udevadm trigger", file=sys.stderr)
        return None
    except OSError as e:
        print(f"ERROR: Cannot open {dev_path}: {e}", file=sys.stderr)
        return None


def parse_report(data):
    """Parse a battery report from raw HID data.

    Returns (battery_percent, is_charging) or None if not a valid battery report.

    Handles multiple report types:
    - 0xBB (7 bytes): Battery status report (the one we want)
    - 0xBC (10 bytes): Transition report sent during cable plug/unplug (ignored)
    """
    if not data or len(data) < 7:
        return None

    report_id = data[0]
    if report_id != BATTERY_REPORT_MARKER:
        return None

    battery = data[6]
    if battery > 100:
        return None

    charging_byte = data[5]
    if charging_byte == CHARGING_STATE_TRANSITION:
        return None

    is_charging = charging_byte == CHARGING_STATE_CHARGING
    return (battery, is_charging)


def read_one_report(fd):
    """Try to read and parse one battery report from an open file descriptor.

    Returns (battery_percent, is_charging, raw_data) or None.
    """
    try:
        data = os.read(fd, 256)
        if data:
            parsed = parse_report(data)
            if parsed is not None:
                return (parsed[0], parsed[1], data)
    except BlockingIOError:
        pass
    return None


def read_battery(dev_path, timeout=DEFAULT_TIMEOUT):
    """Open device, wait for a battery report, return dict or None."""
    fd = open_device(dev_path)
    if fd is None:
        return None

    deadline = time.time() + timeout
    while time.time() < deadline:
        result = read_one_report(fd)
        if result is not None:
            os.close(fd)
            return {"battery": result[0], "charging": result[1], "raw": result[2]}
        time.sleep(0.05)

    os.close(fd)
    return None


def format_bar(percent, charging=False):
    """Return a colored ASCII battery bar string."""
    filled = percent // 5
    empty = 20 - filled

    if charging:
        color = "\033[96m"
        icon = "++"
    elif percent > 75:
        color = "\033[92m"
        icon = "  "
    elif percent > 20:
        color = "\033[93m"
        icon = "  "
    else:
        color = "\033[91m"
        icon = "!!"

    reset = "\033[0m"
    return f"{color}{icon}[{'=' * filled}{'-' * empty}] {percent:3d}%{reset}"


def format_status_line(pct, chg, count=None, raw_hex=None):
    """Build a single-line status string."""
    ts = time.strftime("%H:%M:%S")
    bar = format_bar(pct, chg)
    state = "\u26a1 CHARGING" if chg else "ON BATTERY"
    parts = [f"[{ts}]", bar, state]
    if count is not None:
        parts.append(f"#{count}")
    if raw_hex:
        parts.append(f"Raw: {raw_hex}")
    return "  ".join(parts)


def main():
    parser = argparse.ArgumentParser(
        description="Read battery level and charging status from Rapoo gaming mice",
    )
    parser.add_argument(
        "--watch", "-w", action="store_true",
        help="Monitor battery continuously (updates on every new report)",
    )
    parser.add_argument(
        "--device", "-d", default=None,
        help="Specify hidraw device path (default: auto-detect)",
    )
    parser.add_argument(
        "--interval", "-i", type=int, default=DEFAULT_WATCH_INTERVAL,
        help=f"Max seconds to wait between report refreshes in watch mode (default: {DEFAULT_WATCH_INTERVAL})",
    )
    parser.add_argument(
        "--json", action="store_true",
        help="Output as JSON",
    )
    parser.add_argument(
        "--waybar", action="store_true",
        help="Output as Waybar-compatible JSON (text, percentage, alt, tooltip, class)",
    )
    parser.add_argument(
        "--raw", action="store_true",
        help="Include raw report hex in output",
    )
    args = parser.parse_args()

    # --- Device discovery ---
    dev_path = args.device or find_rapoo_hidraw()
    if not dev_path:
        print("ERROR: No Rapoo mouse found.", file=sys.stderr)
        print("Make sure the USB dongle is connected.", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(dev_path):
        print(f"ERROR: Device {dev_path} does not exist.", file=sys.stderr)
        sys.exit(1)

    # --- Watch mode ---
    if args.watch:
        cols = 80
        try:
            cols = os.get_terminal_size().columns
        except OSError:
            pass

        print(f"Monitoring Rapoo mouse on {dev_path}")
        print("Press Ctrl+C to stop.\n")

        fd = open_device(dev_path)
        if fd is None:
            sys.exit(1)

        last_pct = None
        last_chg = None
        last_raw = None
        report_count = 0
        last_line = ""

        try:
            while True:
                # Drain all pending reports, keep the latest
                result = None
                while True:
                    r = read_one_report(fd)
                    if r is None:
                        break
                    result = r

                if result is not None:
                    pct, chg, raw = result
                    report_count += 1
                    last_pct = pct
                    last_chg = chg
                    last_raw = raw

                if last_pct is not None:
                    line = format_status_line(
                        last_pct, last_chg,
                        count=report_count,
                        raw_hex=last_raw.hex() if args.raw else None,
                    )
                else:
                    line = f"[{time.strftime('%H:%M:%S')}] Waiting for report..."

                if line != last_line:
                    padded = line.ljust(cols)
                    sys.stdout.write(f"\r{padded}\033[K")
                    sys.stdout.flush()
                    last_line = line

                time.sleep(0.25)
        except KeyboardInterrupt:
            os.close(fd)
            print()

        return

    # --- Single-shot mode ---
    result = None
    for _ in range(5):
        result = read_battery(dev_path)
        if result is not None:
            break
        time.sleep(0.5)

    if result is None:
        print("ERROR: No battery report received within timeout.", file=sys.stderr)
        print("Make sure the mouse is powered on and the dongle is connected.", file=sys.stderr)
        sys.exit(1)

    if args.waybar:
        pct = result["battery"]
        chg = result["charging"]
        output = {
            "text": f"{pct}%",
            "percentage": pct,
            "alt": "charging" if chg else "discharging",
            "tooltip": f"Rapoo Mouse: {pct}% — {'Charging' if chg else 'On Battery'}",
            "class": "charging" if chg else ("critical" if pct <= 15 else ("warning" if pct <= 30 else "discharging")),
        }
        print(json.dumps(output))
    elif args.json:
        output = {
            "battery_percent": result["battery"],
            "charging": result["charging"],
            "state": "charging" if result["charging"] else "discharging",
            "device": dev_path,
        }
        if args.raw:
            output["raw_report"] = result["raw"].hex()
        print(json.dumps(output))
    else:
        pct = result["battery"]
        chg = result["charging"]
        bar = format_bar(pct, chg)
        state = "Charging" if chg else "On Battery"
        print(f"Rapoo Mouse: {bar}  {state}")
        if args.raw:
            raw = result["raw"]
            print(f"Raw report: {raw.hex()}")
            print(f"  Byte 5 (state):  0x{raw[5]:02X} = {'charging' if chg else 'discharging'}")
            print(f"  Byte 6 (battery): 0x{raw[6]:02X} = {pct}%")


if __name__ == "__main__":
    main()
