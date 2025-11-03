import sys
import math
import imslib
from ims_plot import *

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import MHz
from imslib import Degrees
from imslib import Percent
from imslib import FAP

print("Test 11: Creating Tone Buffers")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

fullAmpl = Percent(100)
zeroPhase = Degrees(0)
stopTone = FAP(MHz(0), Percent(0), zeroPhase)

# Create a new tone buffer filled with a default 100MHz tone
tone = imslib.TBEntry(FAP(MHz(100.0), fullAmpl, zeroPhase))
tb = imslib.ToneBuffer(tone, "My Example Tone Buffer")

# We can modify individual values
tb[0].FreqCh1 = MHz(60.0)
tb[1].SetAll(FAP(MHz(70.0), Percent(80.0), Degrees(0.0)))
tb[255].SyncD = 0x8000

# And we can work on ranges
i = 0
for tbe in tb[10:20]:
    tbe.FreqCh1 = tbe.FreqCh2 = MHz(75.0 + i * 5.0)
    tbe.FreqCh3 = tbe.FreqCh4 = MHz(125.0 - i * 5.0)
    tbe.AmplCh1 = tbe.AmplCh2 = tbe.AmplCh3 = tbe.AmplCh4 = Percent(50.0)
    tbe.SyncD = i
    tbe.SyncA1 = i * 0.1
    tbe.SyncA2 = 1.0 - tbe.SyncA1
    i=i+1

# Always a good idea to have a STOP Tone
tb[20].SetAll(stopTone)    
tb[20].SyncD = 0xFFFF

# Tone Buffer Entries are synonymous with Image Points so we can use the same plotting / utility functions that we use with Images
plot_ImageAll(tb[0:21])
plt.tight_layout()
plt.show()

#############################
# Create some example Tone Buffers from real AODs
#############################
# Use AODeviceList.getList() to find the available AOD models in the library
AOList = ['D110-T110S(633)', 'D600-G50L', 'D1365-aQ180L']

fig, axs = plt.subplots(1, len(AOList), figsize=(15,3*len(AOList)))

# Create a Tone Buffer and add to a Project Container
proj = imslib.ImageProject("Tone Buffer Test Project")

nTones = 15
for i, aod_str in enumerate(AOList):
    aod = imslib.AODevice(aod_str)  
    aod_bw = float(aod.SweepBW)
    aod_lf = float(aod.CentreFrequency) - aod_bw / 2

    aod_tb = imslib.ToneBuffer(aod.Model)
    for n in range(0, nTones):
        aod_tb[n].SetAll(FAP(MHz(aod_lf + (n * aod_bw) / (nTones - 1)), fullAmpl, zeroPhase))

    aod_tb[nTones].SetAll(stopTone)

    proj.ToneBufferContainer.append(aod_tb)

    plot_ImageFreq(aod_tb[0:nTones+1], axs[i], title=f"{nTones} Step Tone Buffer for {aod_str}", drawstyle='steps-mid')
    axs[i].set_ylim(0, 220)

plt.tight_layout()
plt.show()

#############################
# Save to Disk
#############################
# Save it to disk to recall later on
# (Or to open in Isomet iMS Studio)
print("Saving tone buffer group to ToneBuffers.iip")
proj.Save("ToneBuffers.iip")  # iMS Project files use .iip extension as default
