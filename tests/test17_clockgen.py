import imslib
import sys

from ims_scan import iMSScanner

from imslib import SystemFunc, kHz, Percent, Degrees

print("Test 17: Clock Generator")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available system
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

sf = SystemFunc(ims)

# This example uses the internal clock generator feature of iMS systems to output a clock signal
# to the clock connector that is synchronous with Image playback

ckgen = imslib.ClockGenConfiguration()    

clk_freq = None
while clk_freq == None:
    try:
        val = float(input("Clock Frequency (kHz): "))
        clk_freq = kHz(val)
        ckgen.ClockFreq.assign(clk_freq)
    except ValueError:
        print("Invalid value.")

ckgen.OscPhase = Degrees(0)

duty_cycle = None
while duty_cycle == None:
    try:
        val = float(input("Duty Cycle (%): "))
        duty_cycle = Percent(val)
        ckgen.DutyCycle = duty_cycle
    except ValueError:
        print("Invalid value.")

ckgen.AlwaysOn = True
ckgen.GenerateTrigger = False

polarity = None
while polarity == None:
    try:
        polarity = int(input("Polarity (0/1): "))
        if polarity == 1:
            ckgen.Polarity = imslib.Polarity_INVERSE
        elif polarity == 0:
            ckgen.Polarity = imslib.Polarity_NORMAL
        else:
            polarity = None
    except ValueError:
        print("Invalid value.")

ckgen.TrigPolarity = imslib.Polarity_NORMAL

sf.ConfigureClockGenerator(ckgen)

print("Clock Generator configured. Observe output on clock port and try running an image test to confirm it is synchronous. ")

# Use this function call to disable the clock generator.  However, we will leave it running
#sf.DisableClockGenerator()

ims.Disconnect()
