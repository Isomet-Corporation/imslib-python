import imslib
import sys

from ims_scan import iMSScanner

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import MHz
from imslib import Degrees
from imslib import Percent
from imslib import FAP
from imslib import RFChannel
from imslib import VCO

print("Test 21: iVCS Filter Control")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Interactive selection
scanner = iMSScanner()
if scanner.scan():
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

#############################
# Display Tone Menu
#############################

def display_menu():
    print()
    print(" iVCS Filter Menu ")
    print("    (1) -> Enable CIC")
    print("    (2) -> Disable CIC")
    print("    (3) -> Enable IIR")
    print("    (4) -> Disable IIR")
    print("    (5) -> Set Frequency Range")
    print("    (6) -> Set Amplitude Range")
    print("    (7) -> Apply Digital Gain (1-8X)")
    print("    (8) -> Change Channel Routing")
    print("    (9) -> Set VCO Control Function")
    print("    (10) -> Use External mute control")
    print("    (11) -> Set Constant Frequency")
    print("    (12) -> Set Constant Amplitude")
    print("    (13) -> Save Startup State")

#############################
# Menu Functions
#############################

class VCOFilterController:
    def __init__(self, vco):
        self.cic_en = False
        self.iir_en = False
        self.vco = vco

    def enable_cic(self, val):
        self.vco.ConfigureCICFilter(True, val)
        self.cic_en = True

    def disable_cic(self):
        self.vco.ConfigureCICFilter(False)
        self.cic_en = False

    def enable_iir(self, cutoff, stages):
        self.vco.ConfigureIIRFilter(True, cutoff, stages)
        self.iir_en = True

    def disable_iir(self):
        self.vco.ConfigureIIRFilter(False)
        self.iir_en = False

vco = VCO(ims)
vfc = VCOFilterController(vco)

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
        try:
            val = int(input("CIC Filter Length (1-10): "))
        except ValueError:
            print("Invalid integer value.")
            continue
        vfc.enable_cic(val)

    elif choice == '2':
        vfc.disable_cic()

    elif choice == '3':
        try:
            freq = float(input("IIR Filter Cutoff Frequency (kHz): "))
        except ValueError:
            print("Invalid float value.")
            continue
        try:
            stages = int(input("IIR Filter Stages (1-8): "))
        except ValueError:
            print("Invalid integer value.")
            continue
        vfc.enable_iir(freq, stages)

    elif choice == '4':
        vfc.disable_iir()

    elif choice == '5':
        ch = input("Set Frequency Range for Channel 1, 2 or Both (1/2/B): ")
        if ch == '1':
            channel = RFChannel(1)
        elif ch == '2':
            channel = RFChannel(2)
        elif ch == 'b' or ch == 'B':
            channel = RFChannel()
        try:
            lower = float(input("Enter Lower bound of Frequency Range (MHz): "))
        except ValueError:
            print("Invalid float value.")
            continue
        try:
            upper = float(input("Enter Upper bound of Frequency Range (MHz): "))
        except ValueError:
            print("Invalid float value.")
            continue
        vco.SetFrequencyRange(MHz(lower), MHz(upper), channel) 

    elif choice == '6':
        ch = input("Set Amplitude Range for Channel 1, 2 or Both (1/2/B): ")
        if ch == '1':
            channel = RFChannel(1)
        elif ch == '2':
            channel = RFChannel(2)
        elif ch == 'b' or ch == 'B':
            channel = RFChannel()
        try:
            lower = float(input("Enter Lower bound of Amplitude Range (%): "))
        except ValueError:
            print("Invalid float value.")
            continue
        try:
            upper = float(input("Enter Upper bound of Amplitude Range (%): "))
        except ValueError:
            print("Invalid float value.")
            continue
        vco.SetAmplitudeRange(Percent(lower), Percent(upper), channel) 
        
    elif choice == '7':
        try:
            gain = int(input("Digital Gain (1/2/4/8): "))
        except ValueError:
            print("Invalid integer value.")
            continue
        if gain == 1:
            vco.ApplyDigitalGain(VCO.VCOGain_X1)
        elif gain == 2:
            vco.ApplyDigitalGain(VCO.VCOGain_X2)
        elif gain == 4:
            vco.ApplyDigitalGain(VCO.VCOGain_X4)
        elif gain == 8:
            vco.ApplyDigitalGain(VCO.VCOGain_X8)

    elif choice == '8':  
        print()
        print(" Select analogue input routing for which channel: ")
        print("   (1): Channel 1 Frequency")
        print("   (2): Channel 1 Amplitude")
        print("   (3): Channel 2 Frequency")
        print("   (4): Channel 2 Amplitude")
        try:
            channel = int(input())
        except ValueError:
            print("Invalid integer value.")
            continue
        if (channel == 1):
            vcoOut = VCO.VCOOutput_CH1_FREQUENCY
        elif (channel == 2):
            vcoOut = VCO.VCOOutput_CH1_AMPLITUDE
        elif (channel == 3):
            vcoOut = VCO.VCOOutput_CH2_FREQUENCY
        elif (channel == 4):
            vcoOut = VCO.VCOOutput_CH2_AMPLITUDE
        else:
            continue

        print()
        print(" Route from which input:")
        print("   (A): Analogue Input A")
        print("   (B): Analogue Input B")
        anlg_in = input().strip().lower()
        if (anlg_in == 'a'):
            vcoIn = VCO.VCOInput_A
        elif (anlg_in == 'b'):
            vcoIn = VCO.VCOInput_B
        else:
            continue

        vco.Route(vcoOut, vcoIn)

    elif choice == '9':  
        print()
        print(" Select control function for which channel: ")
        print("   (1): Channel 1 Frequency")
        print("   (2): Channel 1 Amplitude")
        print("   (3): Channel 2 Frequency")
        print("   (4): Channel 2 Amplitude")
        try:
            channel = int(input())
        except ValueError:
            print("Invalid integer value.")
            continue
        if (channel == 1):
            vcoOut = VCO.VCOOutput_CH1_FREQUENCY
        elif (channel == 2):
            vcoOut = VCO.VCOOutput_CH1_AMPLITUDE
        elif (channel == 3):
            vcoOut = VCO.VCOOutput_CH2_FREQUENCY
        elif (channel == 4):
            vcoOut = VCO.VCOOutput_CH2_AMPLITUDE
        else:
            continue

        print()
        print(" Control Function: ")
        print("   (1): Normal Input Tracking")
        print("   (2): Hold")
        print("   (3): Conditional (Use pin GPI(2) to track/hold)")
        print("   (4): Mute")
        try:
            func = int(input())
        except ValueError:
            print("Invalid integer value.")
            continue
        if (func == 1):
            vcoFunc = VCO.VCOFunction_TRACK
        elif (func == 2):
            vcoFunc = VCO.VCOFunction_HOLD
        elif (func == 3):
            vcoFunc = VCO.VCOFunction_CONDITIONAL
        elif (func == 4):
            vcoFunc = VCO.VCOFunction_MUTE
        else:
            continue
        vco.ControlFunction(vcoOut, vcoFunc)

    elif choice == '10':
        ch = input("Use External Mute control for Channel 1, 2, Both or Neither (1/2/B/N): ").strip().lower()
        mute = True
        if ch == '1':
            channel = RFChannel(1)
        elif ch == '2':
            channel = RFChannel(2)
        elif ch == 'b':
            channel = RFChannel()
        elif ch == 'n':
            channel = RFChannel()
            mute = False
        else:
            continue
        vco.ExternalRFMute(mute, channel)

    elif choice == '11':
        ch = input("Set Constant Frequency for Channel 1, 2 or Both (1/2/B): ").strip().lower()
        if ch == '1':
            channel = RFChannel(1)
        elif ch == '2':
            channel = RFChannel(2)
        elif ch == 'b':
            channel = RFChannel()
        else:
            continue
        try:
            freq = float(input("Enter Frequency (MHz): "))
        except ValueError:
            print("Invalid float value.")
            continue
        vco.SetConstantFrequency(MHz(freq), channel)
        print("Change Control Function to cancel constant frequency")

    elif choice == '12':
        ch = input("Set Constant Amplitude for Channel 1, 2 or Both (1/2/B): ").strip().lower()
        if ch == '1':
            channel = RFChannel(1)
        elif ch == '2':
            channel = RFChannel(2)
        elif ch == 'b':
            channel = RFChannel()
        else:
            continue
        try:
            ampl = float(input("Enter Amplitude (%): "))
        except ValueError:
            print("Invalid float value.")
            continue
        vco.SetConstantAmplitude(Percent(ampl), channel)
        print("Change Control Function to cancel constant amplitude")

    elif choice == '13':
        vco.SaveStartupState()
        print("This function is not yet implemented")

    else:
        print("Invalid selection. Please choose 1-13 or 'q'.")

ims.Disconnect()