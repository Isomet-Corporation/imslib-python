import imslib
import sys

from ims_scan import iMSScanner

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import MHz
from imslib import Degrees
from imslib import Percent
from imslib import FAP
from imslib import RFChannel

print("Test 05: Calibration Tone / Single Tone Mode")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Interactive selection
scanner = iMSScanner()
if scanner.scan():
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

sp = imslib.SignalPath(ims)

print("Set RF output amplitude.")
sp.UpdateDDSPowerLevel(Percent(80.0))
sp.UpdateRFAmplitude(imslib.SignalPath.AmplitudeControl_INDEPENDENT, Percent(80.0))
sp.SwitchRFAmplitudeControlSource(imslib.SignalPath.AmplitudeControl_INDEPENDENT)

# Start with tone disabled
sp.ClearTone()

#############################
# Display Tone Menu
#############################

def display_menu():
    print()
    print(f" Lock State: Ch1={sp.GetCalibrationChannelLockState(RFChannel(1))}"
          f" Ch2={sp.GetCalibrationChannelLockState(RFChannel(2))}"
          f" Ch3={sp.GetCalibrationChannelLockState(RFChannel(3))}"
          f" Ch4={sp.GetCalibrationChannelLockState(RFChannel(4))}")
    print(" Calibration Tone Menu ")
    print("    (1) -> Enable Tone")
    print("    (2) -> Disable Tone")
    print("    (3) -> Set Frequency")
    print("    (4) -> Set Amplitude")
    print("    (5) -> Set Phase")
    print("    (6) -> Toggle Channel 1 Lock")
    if ims.Synth().GetCap().channels > 1:
        print("    (7) -> Toggle Channel 2 Lock")
    if ims.Synth().GetCap().channels > 2:
        print("    (8) -> Toggle Channel 3 Lock")
    if ims.Synth().GetCap().channels > 3:
        print("    (9) -> Toggle Channel 4 Lock")

#############################
# Menu Functions
#############################

class ToneController:
    def __init__(self, sp):
        # Default Frequency, Amplitude & Phase
        self.tone = FAP(MHz(100.0), Percent(100.0), Degrees(0.0))
        self.toneOn = False
        self.sp = sp

    def enable_tone(self):
        self.sp.SetCalibrationTone(self.tone)
        self.toneOn = True

    def disable_tone(self):
        self.sp.ClearTone()
        self.toneOn = False

    def update_freq(self, f):
        self.tone.freq = MHz(f)
        if self.toneOn is True:
            self.enable_tone()

    def update_ampl(self, a):
        self.tone.ampl = Percent(a)
        if self.toneOn is True:
            self.enable_tone()

    def update_phs(self, p):
        self.tone.phase = Degrees(p)
        if self.toneOn is True:
            self.enable_tone()

    def toggle_lock(self, ch):
        lock = self.sp.GetCalibrationChannelLockState(RFChannel(ch))
        if lock:
            self.sp.ClearCalibrationChannelLock(RFChannel(ch))
        else:
            self.sp.SetCalibrationChannelLock(RFChannel(ch))

tc = ToneController(sp)

#####################################
# Main User Loop
#####################################

while True:
    display_menu()
    print()
    choice = input("Select an option 'q' to quit: ").strip().lower()

    if choice == 'q':
        break
    elif choice == '1':
        tc.enable_tone()
    elif choice == '2':
        tc.disable_tone()
    elif choice == '3':
        try:
            val = float(input("New Frequency (MHz): "))
            tc.update_freq(val)
        except ValueError:
            print("Invalid integer value.")
    elif choice == '4':
        try:
            val = float(input("New Amplitude (%): "))
            tc.update_ampl(val)
        except ValueError:
            print("Invalid integer value.")
    elif choice == '5':
        try:
            val = float(input("New Phase (degrees): "))
            tc.update_phs(val)
        except ValueError:
            print("Invalid integer value.")
    elif choice == '6':
        tc.toggle_lock(1)
    elif choice == '7':
        tc.toggle_lock(2)
    elif choice == '8':
        tc.toggle_lock(3)
    elif choice == '9':
        tc.toggle_lock(4)
    else:
        print("Invalid selection. Please choose 1-9 or 'q'.")

sp.ClearTone()

ims.Disconnect()