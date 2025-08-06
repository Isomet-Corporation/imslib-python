import imslib
import sys
import os

from imslib import kHz, Percent
from imslib import PointClock, ImageTrigger, StopStyle

print("Test 08: Play Images on iMS System")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

conn = imslib.ConnectionList()

print("Scanning for iMS Systems . . .")
systems = conn.scan()
if (len(systems) == 0):
    print("No systems found.")
    quit()

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

sp = imslib.SignalPath(ims)

print("Set RF output to mid-amplitude.")
sp.UpdateDDSPowerLevel(Percent(50.0))
sp.UpdateRFAmplitude(imslib.SignalPath.AmplitudeControl_INDEPENDENT, Percent(50.0))

# Bypass Compensation for this test
sp.EnableImagePathCompensation(False, False)

# Clear any existing RF output
sp.ClearTone()

#############################
# Display Image Table
#############################

table=imslib.ImageTableViewer(ims)
print(f"{len(table)} images in table")
print(table)

if len(table) == 0:
    print("Please download some images to the iMS to continue this example")
    sys.exit()

#############################
# Menu Functions
#############################

class ImageController:
    def __init__(self):
        # Default Player Configuration
        self.cfg = imslib.ImagePlayerConfiguration()
        self.clockRate = kHz(100.0)
        self.clockDiv = 1

    def set_internal_clock(self):
        self.cfg.Clock = PointClock.INTERNAL

    def set_external_clock(self):
        self.cfg.Clock = PointClock.EXTERNAL

    def is_internal_clock(self):
        if self.cfg.Clock == PointClock.INTERNAL:
            return True
        else:
            return False

    def set_continuous_trig(self):
        self.cfg.Trig = ImageTrigger.CONTINUOUS

    def set_external_trig(self):
        self.cfg.Trig = ImageTrigger.EXTERNAL

    def is_continuous_trig(self):
        if self.cfg.Trig == ImageTrigger.CONTINUOUS:
            return True
        else:
            return False

    def set_programmed_repeats(self, count):
        self.cfg.rpts = imslib.ImageRepeats_PROGRAM
        self.cfg.n_rpts = count

    def set_forever_repeats(self):
        self.cfg.rpts = imslib.ImageRepeats_FOREVER

    def set_none_repeats(self):
        self.cfg.rpts = imslib.ImageRepeats_NONE

    def set_clock_rate(self, rate):
        self.clockRate = rate

    def set_clock_div(self, val):
        self.clockDiv = val

    def __str__(self):
        return str(f"Clk => {"Int (" + str(self.clockRate) + ")" if self.is_internal_clock() == True else "Ext (div " + str(self.clockDiv) + ")"}" +
              f"     Trig => {"Cont" if self.is_continuous_trig() else "Ext"}" +
              f"     Rpts => {"None" if self.cfg.rpts == imslib.ImageRepeats_NONE else "Forever" if self.cfg.rpts == imslib.ImageRepeats_FOREVER else str(self.cfg.n_rpts)}")

ic = ImageController()

#############################
# Display Tone Menu
#############################

def display_menu(ic):
    print()
    print("Playback Parameters:")
    print(ic)
    print()
    print("Image Playback Menu ")
    print("    (1) -> Display Image Table")
    print("    (2) -> Play Image")
    print("    (3) -> Configure Clock")
    print("    (4) -> Configure Trigger")
    print("    (5) -> Set Repeats")
    if ic.is_internal_clock() == True:
        print("    (6) -> Internal Clock Frequency")
    else:
        print("    (6) -> External Clock Divider")

#####################################
# Main User Loop
#####################################

while True:
    display_menu(ic)
    print()
    choice = input("Select an option or 'q' to quit: ").strip().lower()

    if choice == 'q':
        break
    elif choice == '1':
        print(table)
    elif choice == '2':
        index = -1
        print()
        while index == -1:
            index_str = input("Select an image index from the image table: ").strip()
            try:
                index = int(index_str)
            except ValueError:
                index = -1
            if index > len(table) or index < 0:
                index = -1
        if ic.is_internal_clock():
            ip = imslib.ImagePlayer(ims, table[index], ic.clockRate)
        else:
            ip = imslib.ImagePlayer(ims, table[index], ic.clockDiv)
        
        ip.Config = ic.cfg
        ip.Play()
        # Currently there is no feedback on image progress or play/stop state so we must prompt the user
        os.system('pause')
        ip.Stop(StopStyle.IMMEDIATELY)
    elif choice == '3':
        index = -1
        print()
        while index == -1:
            index_str = input("Select (1) for internal clock or (2) for external clock: ").strip()
            try:
                index = int(index_str)
            except ValueError:
                index = -1
            if index > 2 or index < 1:
                index = -1
        if index == 1:
            ic.set_internal_clock()
        else:
            ic.set_external_clock()
    elif choice == '4':
        index = -1
        print()
        while index == -1:
            index_str = input("Select (1) for continuous playback or (2) for external trigger: ").strip()
            try:
                index = int(index_str)
            except ValueError:
                index = -1
            if index > 2 or index < 1:
                index = -1
        if index == 1:
            ic.set_continuous_trig()
        else:
            ic.set_external_trig()
    elif choice == '5':
        index = -1
        print()
        while index == -1:
            index_str = input("Select (1) for no repeats, (2) for programmed repeats or (3) to always repeat: ").strip()
            try:
                index = int(index_str)
            except ValueError:
                index = -1
            if index > 3 or index < 1:
                index = -1
        if index == 3:
            ic.set_forever_repeats()
        elif index == 2:
            n_rpts_str = input("  Program Repeat Counter for how many repeats? ").strip()
            try:
                n_rpts = int(n_rpts_str)
            except ValueError:
                n_rpts = 0
            ic.set_programmed_repeats(n_rpts)
        else:
            ic.set_none_repeats()
    elif choice == '6':
        if ic.is_internal_clock():
            try:
                val = float(input("Internal Clock Frequency (kHz): "))
                ic.set_clock_rate(kHz(val))
            except ValueError:
                print("Invalid frequency value.")
        else:
            try:
                val = int(input("External Clock Divider: "))
                ic.set_clock_div(val)
            except ValueError:
                print("Invalid clock divider value.")
    else:
        print("Invalid selection. Please choose 1-6 or 'q'.")



ims.Disconnect()