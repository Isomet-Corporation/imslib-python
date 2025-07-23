import imslib

print("Test 03: Configure Connection Manager")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

def iMS_Scan(connList):
    print("Scanning for iMS Systems . . .")
    systems = connList.scan()
    if (len(systems) == 0):
        print("No systems found.")

    for i, ims in enumerate(systems):
        print(f"iMS System {i+1}:", ims.ConnPort())

    print()

def print_settings(cfg):
    print(f"  Include In Scan = {cfg.IncludeInScan}")
    print(f"  Port Mask: {cfg.PortMask}")

conn = imslib.ConnectionList()

print("These are the modules available to the Connection Manager:")
print(conn.modules())

print("We are going to test the CM_ETH module.  Please use an Ethernet connection to the iMS")

eth_config = conn.config("CM_ETH")
print("Let's test the default settings, which are:")
print_settings(eth_config)

iMS_Scan(conn)

eth_config.IncludeInScan = False
print("If there was an Ethernet connected iMS, it should be listed. Now let's retry the scan")
print_settings(eth_config)

iMS_Scan(conn)

print(f"Any Ethernet connected iMS should have disappeared")
print()

eth_config.IncludeInScan = True
eth_config.PortMask.append("192.168.2")
print("Finally, let's use a port mask to limit the scope of the CM_ETH scan.")
print("The port mask restricts scanning to a particular interface on the host")
print("We can use a partial IP address to scan only interfaces that match that address range")
print("For example, 'PortMask=192.168.2' will match a host interface with IP=192.168.2.1 but not 192.168.1.1")
print("Any iMS systems connected to that interface and within the host subnet should be discovered")
print("Don't confuse this with the IP address of the iMS system, we are masking the host interface not the iMS")
print_settings(eth_config)

iMS_Scan(conn)
