import imslib
import sys

print("Test 02: Display/Modify Ethernet Connection Settings")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

conn = imslib.ConnectionList()

print("Scanning for iMS Systems . . .")
systems = conn.scan()
if (len(systems) == 0):
    print("No systems found.")
    sys.exit()

for i, ims in enumerate(systems):
    print(f" {i+1}: ", ims.ConnPort())

choice = 0
while choice == 0:
    choice_str = input("Select an iMS System: ").strip()
    try:
        choice = int(choice_str)
    except ValueError:
        choice = 0
    if choice > len(systems) or choice < 1:
        choice = 0

ims = systems[choice-1]

print()
print("Using iMS System:", ims.ConnPort())

ims.Connect()

settings_eth = ims.RetrieveSettings(imslib.CS_ETH())
settings_rs422 = ims.RetrieveSettings(imslib.CS_RS422())

#############################
# Display Current Settings
#############################

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

#####################################
# Give User Option to Update Settings
#####################################

display_settings()
while True:
    print()
    choice = input("Select an option (1-5), 'd' to display current settings or 'q' to quit: ").strip().lower()

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
    else:
        print("Invalid selection. Please choose 1-5 or 'q'.")


ims.Disconnect()
