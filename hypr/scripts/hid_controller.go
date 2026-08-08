package main

import (
	"bufio"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/sstallion/go-hid")

// ==========================================
// Fan Data Parsing (From Reference Code)
// ==========================================

// FanData struct
type FanData struct {
	ReportID     uint8  // Report ID
	MagicSync    uint16 // Magic sync 0x5AA5
	Command      uint8  // Command code
	Status       uint8  // Status byte
	GearSettings uint8  // Max gear and set gear
	CurrentMode  uint8  // Current mode
	Reserved1    uint8  // Reserved byte
	CurrentRPM   uint16 // Real-time RPM
	TargetRPM    uint16 // Target RPM
	MaxGear      uint8  // Max gear (Parsed from GearSettings)
	SetGear      uint8  // Set gear (Parsed from GearSettings)
}

// parseGearSettings parses the gear settings
func parseGearSettings(gearByte uint8) (maxGear, setGear string) {
	maxGearCode := (gearByte >> 4) & 0x0F
	setGearCode := gearByte & 0x0F

	// Mode mapping: 2=Standard, 4=Strong, 6=Overclock
	maxGearMap := map[uint8]string{
		0x2: "Standard",
		0x4: "Strong",
		0x6: "Overclock",
	}

	// Gear mapping: 8=Silent, A=Standard, C=Strong, E=Overclock
	setGearMap := map[uint8]string{
		0x8: "Silent",
		0xA: "Standard",
		0xC: "Strong",
		0xE: "Overclock",
	}

	if val, ok := maxGearMap[maxGearCode]; ok {
		maxGear = val
	} else {
		maxGear = fmt.Sprintf("Unknown(0x%X)", maxGearCode)
	}

	if val, ok := setGearMap[setGearCode]; ok {
		setGear = val
	} else {
		setGear = fmt.Sprintf("Unknown(0x%X)", setGearCode)
	}

	return
}

// parseWorkMode parses the working mode
func parseWorkMode(mode uint8) string {
	switch mode {
	case 0x04:
		return "Gear Mode"
	case 0x05:
		return "Auto Mode (Real-time RPM)"
	default:
		return fmt.Sprintf("Unknown Mode(0x%02X)", mode)
	}
}

// parseFanData parses the HID data packet
func parseFanData(data[]byte) *FanData {
	length := len(data)
	if length < 11 {
		return nil
	}

	// Check magic sync
	magic := binary.BigEndian.Uint16(data[1:3])
	if magic != 0x5AA5 {
		return nil
	}

	fanData := &FanData{
		ReportID:     data[0],
		MagicSync:    magic,
		Command:      data[3],
		Status:       data[4],
		GearSettings: data[5],
		CurrentMode:  data[6],
		Reserved1:    data[7],
	}

	// Parse RPM (Little Endian)
	if length >= 10 {
		fanData.CurrentRPM = binary.LittleEndian.Uint16(data[8:10])
	}
	if length >= 12 {
		fanData.TargetRPM = binary.LittleEndian.Uint16(data[10:12])
	}

	return fanData
}

// displayFanData displays the parsed fan data
func displayFanData(fanData *FanData) {
	fmt.Println("\n=== Fan Data Parse ===")
	fmt.Printf("Report ID: 0x%02X\n", fanData.ReportID)
	fmt.Printf("Magic Sync: 0x%04X\n", fanData.MagicSync)
	fmt.Printf("Command Code: 0x%02X\n", fanData.Command)
	fmt.Printf("Status Byte: 0x%02X\n", fanData.Status)

	maxGear, setGear := parseGearSettings(fanData.GearSettings)
	fmt.Printf("Gear Settings: 0x%02X (Max Gear: %s, Set Gear: %s)\n",
		fanData.GearSettings, maxGear, setGear)

	fmt.Printf("Current Mode: %s (0x%02X)\n", parseWorkMode(fanData.CurrentMode), fanData.CurrentMode)
	fmt.Printf("Reserved Byte: 0x%02X\n", fanData.Reserved1)
	fmt.Printf("Real-time RPM: %d RPM\n", fanData.CurrentRPM)
	fmt.Printf("Target RPM: %d RPM\n", fanData.TargetRPM)
	fmt.Println("======================")
}

// ==========================================
// BS2PRO HID Controller
// ==========================================

// DeviceMatch holds simplified info for discovered devices
type DeviceMatch struct {
	VendorID  uint16
	ProductID uint16
	Name      string
}

// BS2ProController defines the main controller logic
type BS2ProController struct {
	device    *hid.Device
	vendorID  uint16
	productID uint16
}

// FindDevices searches for all possible BS2PRO HID devices
func (c *BS2ProController) FindDevices() []DeviceMatch {
	var devices[]DeviceMatch
	fmt.Println("Searching for BS2PRO HID devices...")

	// Add known BS2PRO device information (using 0x37D7 as corrected in reference)
	knownDevices :=[]DeviceMatch{
		{0x37D7, 0x1002, "FlyDigi BS2PRO"},
	}

	searchTerms :=[]string{"BS2PRO", "FLYDIGI", "FLY", "CONTROLLER", "GAMEPAD"}

	// Also check common gamepad vendor IDs
	commonVendors :=[]uint16{
		0x2DC8, // 8BitDo
		0x045E, // Microsoft
		0x054C, // Sony
		0x057E, // Nintendo
		0x0F0D, // Hori
		0x28DE, // Valve
		0x37D7, // FlyDigi
	}

	hid.Enumerate(0, 0, func(info *hid.DeviceInfo) error {
		vid := info.VendorID
		pid := info.ProductID
		mfr := info.MfrStr
		prod := info.ProductStr

		// 1. First check known devices
		for _, kd := range knownDevices {
			if vid == kd.VendorID && pid == kd.ProductID {
				devices = append(devices, DeviceMatch{vid, pid, kd.Name})
				fmt.Println("Found known BS2PRO device:")
				fmt.Printf("  Vendor ID: 0x%04X\n", vid)
				fmt.Printf("  Product ID: 0x%04X\n", pid)
				fmt.Printf("  Manufacturer: %s\n", mfr)
				fmt.Printf("  Product Name: %s\n", prod)
				fmt.Println(strings.Repeat("-", 40))
				return nil
			}
		}

		// 2. Expand search criteria
		isMatch := false
		upperMfr := strings.ToUpper(mfr)
		upperProd := strings.ToUpper(prod)

		for _, term := range searchTerms {
			if strings.Contains(upperMfr, term) || strings.Contains(upperProd, term) {
				isMatch = true
				break
			}
		}

		if !isMatch {
			for _, cv := range commonVendors {
				if vid == cv {
					isMatch = true
					break
				}
			}
		}

		if isMatch {
			// Check if already added
			exists := false
			for _, d := range devices {
				if d.VendorID == vid && d.ProductID == pid {
					exists = true
					break
				}
			}

			if !exists {
				name := prod
				if name == "" {
					name = fmt.Sprintf("Unknown-%04X:%04X", vid, pid)
				}
				devices = append(devices, DeviceMatch{vid, pid, name})
				fmt.Println("Found potential device:")
				fmt.Printf("  Vendor ID: 0x%04X\n", vid)
				fmt.Printf("  Product ID: 0x%04X\n", pid)
				fmt.Printf("  Manufacturer: %s\n", mfr)
				fmt.Printf("  Product Name: %s\n", prod)
				fmt.Println(strings.Repeat("-", 40))
			}
		}
		return nil
	})

	return devices
}

// Connect attempts to connect to the device. Uses VID/PID 0 to search automatically.
func (c *BS2ProController) Connect(vendorID, productID uint16) bool {
	if vendorID == 0 || productID == 0 {
		devices := c.FindDevices()
		if len(devices) == 0 {
			fmt.Println("No matching HID device found")
			fmt.Println("\nTip: Manually specify Vendor ID and Product ID")
			fmt.Println("   e.g.: controller.Connect(0x1234, 0x5678)")
			return false
		}

		for _, d := range devices {
			fmt.Printf("Trying to connect to: %s (0x%04X:0x%04X)\n", d.Name, d.VendorID, d.ProductID)
			if c.TryConnect(d.VendorID, d.ProductID) {
				return true
			}
		}

		fmt.Println("Failed to connect to all potential devices")
		return false
	}

	return c.TryConnect(vendorID, productID)
}

// TryConnect attempts to connect to a specifically targeted device
func (c *BS2ProController) TryConnect(vendorID, productID uint16) bool {
	dev, err := hid.OpenFirst(vendorID, productID)
	if err != nil {
		fmt.Printf("Failed to connect to 0x%04X:0x%04X: %v\n", vendorID, productID, err)
		return false
	}

	c.device = dev
	c.vendorID = vendorID
	c.productID = productID

	info, err := dev.GetDeviceInfo()
	mfr := "Unknown"
	prod := "Unknown"
	if err == nil {
		if info.MfrStr != "" {
			mfr = info.MfrStr
		}
		if info.ProductStr != "" {
			prod = info.ProductStr
		}
	}

	fmt.Println("Connection successful!")
	fmt.Printf("  Manufacturer: %s\n", mfr)
	fmt.Printf("  Product: %s\n", prod)
	fmt.Printf("  Vendor ID: 0x%04X\n", vendorID)
	fmt.Printf("  Product ID: 0x%04X\n", productID)
	return true
}

// SendFeatureReport sends a feature report
func (c *BS2ProController) SendFeatureReport(reportID uint8, data[]byte) bool {
	if c.device == nil {
		fmt.Println("Device not connected")
		return false
	}

	// Construct report (Report ID + Data)
	report := make([]byte, 1+len(data))
	report[0] = reportID
	copy(report[1:], data)

	n, err := c.device.SendFeatureReport(report)
	if err != nil {
		fmt.Printf("Failed to send feature report: %v\n", err)
		return false
	}

	fmt.Printf("Sent feature report successfully: Report ID=%d, Length=%d\n", reportID, n)
	return true
}

// GetFeatureReport gets a feature report
func (c *BS2ProController) GetFeatureReport(reportID uint8, length int)[]byte {
	if c.device == nil {
		fmt.Println("Device not connected")
		return nil
	}

	report := make([]byte, length)
	report[0] = reportID

	n, err := c.device.GetFeatureReport(report)
	if err != nil {
		fmt.Printf("Failed to get feature report: %v\n", err)
		return nil
	}

	data := report[:n]
	fmt.Printf("Received feature report: Report ID=%d, Data=%x\n", reportID, data)
	return data
}

// SendOutputReport sends an output report
func (c *BS2ProController) SendOutputReport(data[]byte) bool {
	if c.device == nil {
		fmt.Println("Device not connected")
		return false
	}

	n, err := c.device.Write(data)
	if err != nil {
		fmt.Printf("Failed to send output report: %v\n", err)
		return false
	}

	fmt.Printf("Sent output report successfully: Length=%d\n", n)
	return true
}

// ReadInputReport reads an input report
func (c *BS2ProController) ReadInputReport(timeout time.Duration)[]byte {
	if c.device == nil {
		fmt.Println("Device not connected")
		return nil
	}

	// Read inside non-blocking timeout window
	c.device.SetNonblock(true)
	buf := make([]byte, 64)

	n, err := c.device.ReadWithTimeout(buf, timeout)
	if err != nil {
		errMsg := strings.ToLower(err.Error())
		if strings.Contains(errMsg, "timeout") {
			fmt.Println("No input report received (timeout or no data)")
		} else {
			fmt.Printf("Failed to read input report: %v\n", err)
		}
		return nil
	}

	if n > 0 {
		data := buf[:n]
		fmt.Printf("Received input report: Data=%x\n", data)
		return data
	}

	fmt.Println("No input report received (empty)")
	return nil
}

// SendHexCommand sends a hexadecimal command
// paddingLength is total length, padded with 0s if payload is shorter
func (c *BS2ProController) SendHexCommand(hexStr string, reportID uint8, paddingLength int) bool {
	// Remove spaces and "0x"
	hexStr = strings.ReplaceAll(hexStr, " ", "")
	hexStr = strings.ReplaceAll(hexStr, "0x", "")

	// Fix odd-length hex strings to prevent DecodeString errors
	if len(hexStr)%2 != 0 {
		hexStr += "0"
		fmt.Printf("Warning: Hex string had odd length, appended '0' -> %s\n", hexStr)
	}

	payload, err := hex.DecodeString(hexStr)
	if err != nil {
		fmt.Printf("Hex format error: %v\n", err)
		return false
	}

	// Calculate required padding length (Total length - Report ID (1 byte) - Payload length)
	paddingNeeded := paddingLength - 1 - len(payload)
	if paddingNeeded < 0 {
		fmt.Printf("Warning: Command length (%d) exceeds max allowed length (%d)\n", len(payload), paddingLength-1)
		paddingNeeded = 0
	}

	command := make([]byte, 1+len(payload)+paddingNeeded)
	command[0] = reportID
	copy(command[1:], payload)
	// Remaining bytes are inherently zeroed

	fmt.Printf("Sending command: %s (Total length: %d)\n", hexStr, len(command))
	return c.SendOutputReport(command)
}

// SendHexCmd provides defaults matching the Python caller
func (c *BS2ProController) SendHexCmd(hexStr string) bool {
	return c.SendHexCommand(hexStr, 0x02, 23)
}

// SendMultipleCommands sends multiple hex commands
func (c *BS2ProController) SendMultipleCommands(commands[]string, delaySec float64) int {
	successCount := 0
	for i, cmd := range commands {
		cmd = strings.TrimSpace(cmd)
		if cmd == "" {
			continue // Skip empty lines
		}

		fmt.Printf("\nCommand %d/%d: %s\n", i+1, len(commands), cmd)
		if c.SendHexCmd(cmd) {
			successCount++
		}

		// Delay between commands
		if delaySec > 0 && i < len(commands)-1 {
			time.Sleep(time.Duration(delaySec * float64(time.Second)))
		}
	}

	nonEmptyCount := 0
	for _, cmd := range commands {
		if strings.TrimSpace(cmd) != "" {
			nonEmptyCount++
		}
	}

	fmt.Printf("\nDone! Successfully sent %d/%d commands\n", successCount, nonEmptyCount)
	return successCount
}

// CalculateChecksum calculates the checksum for the RPM command
func (c *BS2ProController) CalculateChecksum(rpm uint16) uint8 {
	// Calculate sum of first 6 bytes: 0x5a, 0xa5, 0x21, 0x04, RPM low, RPM high
	b0, b1, b2, b3 := uint16(0x5A), uint16(0xA5), uint16(0x21), uint16(0x04)
	b4 := uint16(rpm & 0xFF)
	b5 := uint16((rpm >> 8) & 0xFF)

	// Checksum byte = (Sum of first 6 bytes + 1) & 0xFF
	checksum := (b0 + b1 + b2 + b3 + b4 + b5 + 1) & 0xFF
	return uint8(checksum)
}

// EnterRealtimeSpeedMode enters real-time speed change mode
func (c *BS2ProController) EnterRealtimeSpeedMode() bool {
	fmt.Println("Entering real-time speed change mode...")
	return c.SendHexCmd("5aa523022500000000000000000000000000000000000000")
}

// SetFanSpeed sets the fan speed in RPM
func (c *BS2ProController) SetFanSpeed(rpm uint16) bool {
	// Construct first 6 bytes: 5aa52104 + Little-endian speed bytes
	b4 := uint8(rpm & 0xFF)
	b5 := uint8((rpm >> 8) & 0xFF)

	checksum := c.CalculateChecksum(rpm)

	// Construct full command
	cmdStr := fmt.Sprintf("5aa52104%02x%02x%02x00000000000000000000000000000000", b4, b5, checksum)

	fmt.Printf("Setting fan speed: %d RPM\n", rpm)
	fmt.Printf("Command: %s\n", cmdStr)
	return c.SendHexCmd(cmdStr)
}

// SetGearPosition sets gear level and position
func (c *BS2ProController) SetGearPosition(gear, position int) bool {
	type gearKey struct{ g, p int }
	gearPositions := map[gearKey]string{
		{1, 1}: "5aa526050014054400000000000000000000000000000000",
		{1, 2}: "5aa5260500a406d500000000000000000000000000000000",
		{1, 3}: "5aa52605006c079e00000000000000000000000000000000",
		{2, 1}: "5aa526050134086800000000000000000000000000000000",
		{2, 2}: "5aa526050160099500000000000000000000000000000000",
		{2, 3}: "5aa52605018c0ac200000000000000000000000000000000",
		{3, 1}: "5aa5260502f00a2700000000000000000000000000000000",
		{3, 2}: "5aa5260502b80bf00000000000000000000000000000000", // Adjusted from 49 chars (python bug)
		{3, 3}: "5aa5260502e40c1d00000000000000000000000000000000",
		{4, 1}: "5aa5260503ac0de700000000000000000000000000000000",
		{4, 2}: "5aa5260503740eb00000000000000000000000000000000", // Adjusted from 49 chars (python bug)
		{4, 3}: "5aa5260503a00fdd00000000000000000000000000000000",
	}

	cmd, ok := gearPositions[gearKey{gear, position}]
	if !ok {
		fmt.Printf("Invalid gear setting: Gear %d Position %d\n", gear, position)
		fmt.Println("Valid range: Gears 1-4, 1-3 positions per gear")
		return false
	}

	fmt.Printf("Setting gear: Gear %d Position %d\n", gear, position)
	return c.SendHexCmd(cmd)
}

// SetGearLight enables or disables the gear light
func (c *BS2ProController) SetGearLight(enabled bool) bool {
	var command string
	if enabled {
		command = "5aa54803014c000000000000000000000000000000000000"
		fmt.Println("Turn on gear light")
	} else {
		command = "5aa54803004b000000000000000000000000000000000000"
		fmt.Println("Turn off gear light")
	}
	return c.SendHexCmd(command)
}

// SetPowerOnStart configures the power-on auto-start behavior
func (c *BS2ProController) SetPowerOnStart(enabled bool) bool {
	var command string
	if enabled {
		command = "5aa50c030211000000000000000000000000000000000000"
		fmt.Println("Turn on power-on auto-start")
	} else {
		command = "5aa50c030110000000000000000000000000000000000000"
		fmt.Println("Turn off power-on auto-start")
	}
	return c.SendHexCmd(command)
}

// SetSmartStartStop sets smart start/stop behavior ('off', 'immediate', 'delayed')
func (c *BS2ProController) SetSmartStartStop(mode string) bool {
	commands := map[string]string{
		"off":       "5aa50d030010000000000000000000000000000000000000",
		"immediate": "5aa50d030111000000000000000000000000000000000000",
		"delayed":   "5aa50d030212000000000000000000000000000000000000",
	}

	cmd, ok := commands[mode]
	if !ok {
		fmt.Printf("Invalid smart start-stop mode: %s\n", mode)
		fmt.Println("Valid modes: 'off', 'immediate', 'delayed'")
		return false
	}

	fmt.Printf("Setting smart start-stop: %s\n", mode)
	return c.SendHexCmd(cmd)
}

// SetBrightness sets the LED brightness level
func (c *BS2ProController) SetBrightness(percentage int) bool {
	var command string
	if percentage == 0 {
		command = "5aa5470d1c00ff00000000000000006f0000000000000000"
		fmt.Println("Setting brightness: 0%")
	} else if percentage == 100 {
		command = "5aa543024500000000000000000000000000000000000000"
		fmt.Println("Setting brightness: 100%")
	} else {
		fmt.Println("Currently only supports 0% and 100% brightness settings")
		return false
	}

	return c.SendHexCmd(command)
}

// Disconnect gracefully disconnects from the HID device
func (c *BS2ProController) Disconnect() {
	if c.device != nil {
		c.device.Close()
		c.device = nil
		fmt.Println("Device disconnected")
	}
}

// ==========================================
// Mode Functions
// ==========================================

func testBS2ProWithCommands() bool {
	controller := &BS2ProController{}

	fmt.Println("Connecting to BS2PRO device...")
	fmt.Println(strings.Repeat("=", 50))

	// Connect using explicit VID and PID
	if !controller.Connect(0x37D7, 0x1002) {
		fmt.Println("Failed to connect to BS2PRO device")
		return false
	}

	fmt.Println("\nStarting to send commands...")
	fmt.Println(strings.Repeat("-", 30))

	// Test command list - one command per line
	// Note: Appended '0' from Python's original bug which had an odd length of 13 hex characters.
	testCommands :=[]string{
		"5aa54803014b00",
	}

	controller.SendMultipleCommands(testCommands, 0.2)

	// Test reading inputs
	fmt.Println("\nListening for input data...")
	fmt.Println("  (Pressing controller buttons may show data...)")
	for i := 0; i < 3; i++ {
		resp := controller.ReadInputReport(1 * time.Second)
		if len(resp) > 0 {
			printLen := len(resp)
			if printLen > 16 {
				printLen = 16
			}
			fmt.Printf("  Input %d: %x...\n", i+1, resp[:printLen])
			break
		} else {
			fmt.Printf("  Input %d: No data\n", i+1)
		}
	}

	fmt.Println("\nTest complete!")
	controller.Disconnect()
	return true
}

func interactiveCommandMode() {
	controller := &BS2ProController{}

	fmt.Println("Interactive command mode")
	fmt.Println(strings.Repeat("=", 50))

	if !controller.Connect(0x37D7, 0x1002) {
		fmt.Println("Failed to connect to BS2PRO device")
		return
	}

	fmt.Println("\nInstructions:")
	fmt.Println("  - Enter hex command (e.g.: 5aa5410243)")
	fmt.Println("  - Multi-line input separated by Enter, ignored if empty")
	fmt.Println("  - Enter 'quit' or 'exit' to exit")
	fmt.Println("  - Enter 'listen' to listen for input data")
	fmt.Println("  - Enter 'speed <rpm>' to set speed (e.g.: speed 2000)")
	fmt.Println("  - Enter 'gear <gear> <position>' to set gear (e.g.: gear 2 3)")
	fmt.Println(strings.Repeat("-", 30))

	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("\nPlease enter command:\n")
		if !scanner.Scan() {
			break
		}
		line := strings.TrimSpace(scanner.Text())

		if line == "" {
			continue
		}

		lowerLine := strings.ToLower(line)
		if lowerLine == "quit" || lowerLine == "exit" {
			break
		}

		if lowerLine == "listen" {
			fmt.Println("Listen mode (5 seconds)...")
			for i := 0; i < 5; i++ {
				resp := controller.ReadInputReport(1 * time.Second)
				if len(resp) > 0 {
					printLen := len(resp)
					if printLen > 16 {
						printLen = 16
					}
					fmt.Printf("  Input: %x...\n", resp[:printLen])

					// Try to parse FanData structures out of the received report
					if fanData := parseFanData(resp); fanData != nil {
						displayFanData(fanData)
					}
				}
			}
			continue
		}

		if strings.HasPrefix(lowerLine, "speed ") {
			parts := strings.Fields(line)
			if len(parts) >= 2 {
				rpm, err := strconv.Atoi(parts[1])
				if err == nil {
					controller.EnterRealtimeSpeedMode()
					time.Sleep(100 * time.Millisecond)
					controller.SetFanSpeed(uint16(rpm))
					continue
				}
			}
			fmt.Println("Usage: speed <rpm value>")
			continue
		}

		if strings.HasPrefix(lowerLine, "gear ") {
			parts := strings.Fields(line)
			if len(parts) >= 3 {
				gear, err1 := strconv.Atoi(parts[1])
				pos, err2 := strconv.Atoi(parts[2])
				if err1 == nil && err2 == nil {
					controller.SetGearPosition(gear, pos)
					continue
				}
			}
			fmt.Println("Usage: gear <gear> <position>")
			continue
		}

		// Normal hex command execution
		controller.SendHexCmd(line)
	}

	fmt.Println("\nUser interrupted, exiting...")
	controller.Disconnect()
}

func main() {
	// Initialize HID library
	err := hid.Init()
	if err != nil {
		fmt.Printf("Failed to initialize HID library: %v\n", err)
		return
	}
	defer func() {
		// Cleanup HID library resources
		if err := hid.Exit(); err != nil {
			fmt.Printf("Failed to cleanup HID library: %v\n", err)
		}
	}()
	interactiveCommandMode()
}
