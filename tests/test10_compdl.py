import imslib
import sys
import os
import time
from ims_scan import iMSScanner
from ims_plot import *

from imslib import MHz, kHz, Percent, Degrees, FAP
from imslib import PointClock, ImageTrigger, StopStyle

print("Test 10: Download Compensation Table to iMS System")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available iMS System
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

#############################
# Configure Signal Path
#############################

sp = imslib.SignalPath(ims)

print("Set RF output amplitude.")
sp.UpdateDDSPowerLevel(Percent(80.0))
sp.UpdateRFAmplitude(imslib.SignalPath.AmplitudeControl_INDEPENDENT, Percent(80.0))
sp.SwitchRFAmplitudeControlSource(imslib.SignalPath.AmplitudeControl_INDEPENDENT)

# Enable Compensation for Demo
sp.EnableImagePathCompensation(True, True)

# Route LUT Sync data to Sync outputs
sp.AssignSynchronousOutput(imslib.SignalPath.SYNC_SINK_ANLG_A, imslib.SignalPath.SYNC_SRC_LOOKUP_FIELD_CH1)
sp.AssignSynchronousOutput(imslib.SignalPath.SYNC_SINK_DIG, imslib.SignalPath.SYNC_SRC_LOOKUP_FIELD_CH1)

# Clear any existing RF output
sp.ClearTone()

#############################
# Import Compensation Table
#############################

# Reuse Compensation Table from previous example
if os.path.isfile("myCompensationTable.lut") == False:
    print("Can't find LUT File 'myCompensationTable.lut'. Please run the previous example to regenerate it")
    sys.exit()

importer = imslib.CompensationTableImporter("myCompensationTable.lut")
if not importer.IsValid():
    print("Error in LUT File.")
    sys.exit()

comp = importer.RetrieveGlobalLUT()

while True:
    response = input("Display LUT? [y|N]").strip().lower()
    if not response or response == 'n':
        break
    elif response == 'y':
        plot_CompAll(comp)
        plt.tight_layout()
        plt.show()
        break

print()
print("Downloading Compensation Table to iMS System...please wait...")

ctdl = imslib.CompensationTableDownload(ims, comp)
ctdl.StartDownload()
time.sleep(10) # No feedback from iMS at present, so we must wait..

print("Download complete")

#############################
# Create a simple image sweep
#############################

freq = MHz()
fullAmpl = Percent(100)
zeroPhase = Degrees(0)
startFreq = ims.Synth().GetCap().lowerFrequency
endFreq = ims.Synth().GetCap().upperFrequency
n_pts = 1000

sweep = imslib.Image("FullSweep")
for i in range(0,n_pts):
    freq.value = startFreq + (endFreq - startFreq) * i / n_pts
    pt = imslib.ImagePoint(FAP(freq, fullAmpl, zeroPhase))
    sweep.append(pt)

dl = imslib.ImageDownload(ims, sweep)
print(f"Downloading Image: {sweep.Name}")
dl.StartDownload()
time.sleep(1)

print()
print("Ready to play image. Observe amplitude/phase compensation and sync anlg/dig outputs")
os.system('pause')

cfg = imslib.ImagePlayerConfiguration()
cfg.Clock = PointClock.INTERNAL
cfg.Trig = ImageTrigger.CONTINUOUS
cfg.rpts = imslib.ImageRepeats_FOREVER

# Play a slow sweep so compensation effects are visible
sweep.ClockRate = kHz(0.2)

ip = imslib.ImagePlayer(ims, sweep)

ip.Config = cfg

while True:
    ip.Play()
    # Currently there is no feedback on image progress or play/stop state so we must prompt the user
    os.system('pause')
    ip.Stop(StopStyle.IMMEDIATELY)

    sp.ClearTone()

    response = input("[R]epeat or [q]uit? ").strip().lower()
    if not response or response == 'r':
        continue
    elif response == 'q':
        break

sp.ClearTone()

ims.Disconnect()