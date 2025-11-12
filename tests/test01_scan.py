import imslib
import sys
import os

print("Test 01: Scan for iMS Systems")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# This is the length of time the iMS library will wait after issuing a broadcast discovery
# message for responses to arrive, in milliseconds.  Shorter timeouts speed up scan time
# at the risk of missing responses from systems on slow or laggy networks. Default = 100ms
DiscoveryTimeout = 50

conn = imslib.ConnectionList(DiscoveryTimeout)

def SysInfo(i, system):
    print(f"iMS System {i+1}:", ims.ConnPort())
    print()

    syn = ims.Synth()
    syncap = syn.GetCap()
    print(f"  Found Synthesiser: {syn.Model()} : {syn.Description()}")
    print(f"    -> FW Version: {syn.GetVersion()}")
    print(f"    -> # Channels = {syncap.channels}  Freq Range = {syncap.lowerFrequency}-{syncap.upperFrequency} MHz")
    print()

    ctrl = ims.Ctlr()
    ctrlcap = ctrl.GetCap()
    print(f"  Found Controller: {ctrl.Model()} : {ctrl.Description()}")
    print(f"    -> FW Version: {ctrl.GetVersion()}")
    print(f"    -> Max Image Size = {ctrlcap.MaxImageSize}  Max Image Rate = {ctrlcap.MaxImageRate}")
    print()

print("Scan Option 1: Scanning for iMS Systems using Full System Scan (All Interfaces) . . .")
systems = conn.Scan()
if (len(systems) == 0):
    print("No systems found.")
else:
    print(f"Found {len(systems)} iMS Systems:")
    for i, ims in enumerate(systems):
        SysInfo(i, ims)

# Performs a scan for a single iMS system on one interface
Interface = "CM_USBLITE"
intfList = conn.Modules()

print()
os.system('pause')
print()
print(f"Scan Option 2: Performing a Limited Scan for a Single System on a Single Interface")
print(f"Interface options are: {intfList}")
print(f"  Scanning -->> {Interface} -->>")
system = conn.Scan(Interface)
# It's also possible to scan for a known device on an interface, e.g. for an iMS with a fixed IP Address:
# system = conn.Scan("CM_ETH", "192.168.1.100")
if (system == None):
    print("No system found.")
else:
    print(f"Found a system on interface {Interface}:")
    SysInfo(0, system)

# Put your serial number in here
SystemID = "iCSA2501"

print()
os.system('pause')
print()
print(f"Scan Option 3: Performing a Targeted Scan for a Known System (based on ID)")
print(f"Searching for system {SystemID}:")
system = conn.Find(Interface, SystemID)
if (system == None):
    print("No system found.")
else:
    print(f"Found system {SystemID} on interface {Interface}:")
    SysInfo(0, system)
