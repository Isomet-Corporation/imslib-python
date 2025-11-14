import imslib
import sys

from ims_scan import iMSScanner
from imslib import CS_ETH, CS_RS422

# This test is used to update connection settings on the device
# Ensure that your host settings (below) match those stored in the device
# If there is a mismatch, the connection attempt will fail
print("Test 02: Display/Modify Ethernet/RS422 Connection Settings")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

#############################
# Host Side Settings
#############################
# These are the settings that will be used to configure the host side communications.
# Update these to match whatever values are stored in the iMS system to enable serial 
# communications with the desired characteristics
host_settings = CS_RS422()
host_settings.baud = 115200 # All common rates up to 921.6kbaud supported if supported by host serial port driver
host_settings.databits = CS_RS422.DataBitsSetting_BITS_8   ## 8 data bits are required by the iMS Communications protocol
host_settings.parity   = CS_RS422.ParitySetting_NONE
host_settings.stopbits = CS_RS422.StopBitsSetting_BITS_1

# Interactive selection
scanner = iMSScanner(settings={"CM_SERIAL": host_settings})
if scanner.scan():
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

#############################
# Get Device Side Settings
#############################
settings_eth = ims.RetrieveSettings(CS_ETH())
settings_rs422 = ims.RetrieveSettings(CS_RS422())

#############################
# Display Current Settings
#############################

dataBits_conversion_map = {
    CS_RS422.DataBitsSetting_BITS_7: "7",
    CS_RS422.DataBitsSetting_BITS_8: "8",
}

parity_conversion_map = {
    CS_RS422.ParitySetting_NONE: "None",
    CS_RS422.ParitySetting_ODD:  "Odd",
    CS_RS422.ParitySetting_EVEN: "Even",
}

stopBits_conversion_map = {
    CS_RS422.StopBitsSetting_BITS_1: "1",
    CS_RS422.StopBitsSetting_BITS_2: "2",
}

def display_settings():
    print()
    print(f" Connection settings_eth for module {settings_eth.Ident()}")
    print(f"    (1) -> UseDHCP = {settings_eth.dhcp}")
    print(f"    (2) -> Address = {settings_eth.addr}")
    print(f"    (3) -> Netmask = {settings_eth.mask}")
    print(f"    (4) -> Gateway = {settings_eth.gw}")

    print()
    print(f" Connection settings_rs422 for module {settings_rs422.Ident()}")
    print(f"    (5) -> BaudRate = {settings_rs422.baud}")
    print(f"    (6) -> DataBits = {dataBits_conversion_map[settings_rs422.databits]}")
    print(f"    (7) -> Parity   = {parity_conversion_map[settings_rs422.parity]}")
    print(f"    (8) -> StopBits = {stopBits_conversion_map[settings_rs422.stopbits]}")

#############################
# Settings Update Functions
#############################

def update_dhcp(value):
    settings_eth.dhcp = value
    ims.ApplySettings(settings_eth)

def update_address(value):
    settings_eth.addr = value
    ims.ApplySettings(settings_eth)

def update_netmask(value):
    settings_eth.mask = value
    ims.ApplySettings(settings_eth)

def update_gateway(value):
    settings_eth.gw = value
    ims.ApplySettings(settings_eth)

def update_baudrate(value):
    settings_rs422.baud = value
    ims.ApplySettings(settings_rs422)

def update_databits(value):
    databits_options = {
        8: CS_RS422.DataBitsSetting_BITS_8,
    }
    if value in databits_options.keys():
        settings_rs422.databits = databits_options[value]
    ims.ApplySettings(settings_rs422)

def update_parity(value):
    parity_options = {
        'n': CS_RS422.ParitySetting_NONE,
        'o': CS_RS422.ParitySetting_ODD,
        'e': CS_RS422.ParitySetting_EVEN,
    }
    if value in parity_options.keys():
        settings_rs422.parity = parity_options[value]
    ims.ApplySettings(settings_rs422)

def update_stopbits(value):
    stopbits_options = {
        1: CS_RS422.StopBitsSetting_BITS_1,
        2: CS_RS422.StopBitsSetting_BITS_2,
    }
    if value in stopbits_options.keys():
        settings_rs422.stopbits = stopbits_options[value]
    ims.ApplySettings(settings_rs422)

#####################################
# Give User Option to Update Settings
#####################################

display_settings()
while True:
    print()
    choice = input("Select an option (1-8), 'd' to display current settings or 'q' to quit: ").strip().lower()

    if choice == 'q':
        break
    elif choice == 'd':
        display_settings()
    elif choice == '1':
        val = input("Use DHCP => True(1) or False(0): ").strip().lower()
        if val in ['true', '1', 'yes']:
            update_dhcp(True)
        elif val in ['false', '0', 'no']:
            update_dhcp(False)
        else:
            print("Invalid boolean value.")
    elif choice == '2':
        val = input("New IP Address: ")
        update_address(val)
    elif choice == '3':
        val = input("New Netmask: ")
        update_netmask(val)
    elif choice == '4':
        val = input("New Gateway: ")
        update_gateway(val)
    elif choice == '5':
        try:
            val = int(input("New Baud Rate: "))
            update_baudrate(val)
        except ValueError:
            print("Invalid integer value.")
    elif choice == '6':
        print("Data Bits must be set to 8")
        update_databits(8)
    elif choice == '7':
        val = input("New Parity (N)one, (O)dd or (E)ven: ").strip().lower()[0]
        if val in ['n', 'o', 'e']:
            update_parity(val)
        else:
            print("Invalid value")
    elif choice == '8':
        try:
            val = int(input("New Stop Bits (1 or 2): "))
        except ValueError:
            print("Invalid integer value.")        
        if val in range(1,3):
            update_stopbits(val)
        else:
            print("Value out of range")
        
        
    else:
        print("Invalid selection. Please choose 1-8 or 'q'.")

print("If you updated iMS settings, please restart the device to take effect")

ims.Disconnect()
