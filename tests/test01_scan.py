import imslib

print("Test 01: Scan for iMS Systems")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

conn = imslib.ConnectionList()

print("Scanning for iMS Systems . . .")
systems = conn.scan()
if (len(systems) == 0):
    print("No systems found.")
    quit()

for i, ims in enumerate(systems):
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
