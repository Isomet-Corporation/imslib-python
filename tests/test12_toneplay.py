import imslib
import os.path
import sys
import time

from ims_scan import iMSScanner
from ims_events import EventWaiter, WaitOnEventsThenPrint

print("Test 12: Download Tone Buffer and Output Tones")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available system
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

# Reuse Tone Buffer Image Project from previous test
if os.path.isfile("ToneBuffers.iip") == False:
    print("Can't find Image Project 'ToneBuffers.iip'. Please run the previous example to regenerate it")
    sys.exit()

#############################
# Load Image Project
#############################
prj = imslib.ImageProject("ToneBuffers.iip")

if len(prj.ToneBufferContainer) < 1:
    print("Error: Nothing in ToneBufferContainer")
    sys.exit()

sp = imslib.SignalPath(ims)

print("Setting RF output amplitude.")
sp.UpdateDDSPowerLevel(imslib.Percent(80.0))
sp.UpdateRFAmplitude(imslib.SignalPath.AmplitudeControl_INDEPENDENT, imslib.Percent(80.0))
sp.SwitchRFAmplitudeControlSource(imslib.SignalPath.AmplitudeControl_INDEPENDENT)

# Start with tone disabled
sp.ClearTone()

#######################################
# Ask User to select a Tone Buffer to download
#######################################

# List of Events that we will subscribe to, and strings to print when they fire
EVENT_MESSAGES = {
    imslib.ToneBufferEvents_DOWNLOAD_FINISHED: "✅ Tone Buffer downloaded successfully!",
    imslib.ToneBufferEvents_DOWNLOAD_ERROR: "❌ Tone Buffer download failed!",
}

def DownloadToneBuffer():
    print("Select a Tone Buffer to download:")
    for i, tb in enumerate(prj.ToneBufferContainer):
        print(f"  {i} : {tb.Name}")

    print()
    valid = False
    while valid == False:
        choice = input("Make a selection or 'q' to quit: ").strip().lower()
        if choice == 'q':
            sys.exit()
        else:
            try:
                a = int(choice)
                if a >= 0 and a < len(prj.ToneBufferContainer):
                    valid = True
            except ValueError:
                valid = False

    tb = prj.ToneBufferContainer[a]

    dl = imslib.ToneBufferDownload(ims, tb)
    waiter = EventWaiter()

    # Define the list of events the waiter should wait for
    waiter.listen_for(list(EVENT_MESSAGES.keys()))

    # Subscribe the waiter
    for evt in waiter._watched:
        dl.ToneBufferDownloadEventSubscribe(evt, waiter)
            
    print(f"Downloading Tone Buffer: {tb.Name}   ", end=" ")
    dl.StartDownload(0, 16)  # We know only the first 16 tones are used

    # Waits for the first event to arrive and prints a message
    WaitOnEventsThenPrint(waiter, EVENT_MESSAGES, timeout=5.0)

    # Unsubscribe
    for evt in waiter._watched:
        dl.ToneBufferDownloadEventUnsubscribe(evt, waiter)

#############################
# Create a Single Tone in buffer
#############################

def DownloadSingleTone():
    tone = imslib.FAP()
    try:
        val = int(input("Tone Buffer Index: "))
        toneIdx = val
    except ValueError:
        print("Invalid value.")
        return
    try:
        val = float(input("Tone Frequency (MHz): "))
        tone.freq = imslib.MHz(val)
    except ValueError:
        print("Invalid value.")
        return
    try:
        val = float(input("Tone Amplitude (%): "))
        tone.ampl = imslib.Percent(val)
    except ValueError:
        print("Invalid value.")
        return

    tb = imslib.ToneBuffer(imslib.TBEntry(tone))

    dl = imslib.ToneBufferDownload(ims, tb)
    waiter = EventWaiter()

    # Define the list of events the waiter should wait for
    waiter.listen_for(list(EVENT_MESSAGES.keys()))

    # Subscribe the waiter
    for evt in waiter._watched:
        dl.ToneBufferDownloadEventSubscribe(evt, waiter)
            
    print(f"Downloading Single Tone: [{toneIdx}] = {tone} ", end=" ")
    dl.StartDownload(toneIdx % 256)

    # Waits for the first event to arrive and prints a message
    WaitOnEventsThenPrint(waiter, EVENT_MESSAGES, timeout=5.0)

    # Unsubscribe
    for evt in waiter._watched:
        dl.ToneBufferDownloadEventUnsubscribe(evt, waiter)    


#############################
# Play a Tone
#############################
def PlayTone():
    try:
        val = int(input("Play Tone Buffer Index: "))
        toneIdx = val
    except ValueError:
        print("Invalid value.")
        return
    
    sp.UpdateLocalToneBuffer(sp.ToneBufferControl_HOST, 
                             toneIdx, 
                             sp.Compensation_BYPASS, # Run this demo with LUT compensation turned off
                             sp.Compensation_BYPASS
                             )

#############################
# External Control
#############################
def ExternalControl():
    sp.UpdateLocalToneBuffer(sp.ToneBufferControl_EXTERNAL_EXTENDED,   # Extended uses more pins to select from all 256 tone entries
                             0, 
                             sp.Compensation_BYPASS, # Run this demo with LUT compensation turned off
                             sp.Compensation_BYPASS
                             )
    print("Now controlling externally. Use PROFILE and GPI pins to select a tone")
    
#############################
# Store Tone Buffer in NVM
#############################
def StoreToneBuffer():
    print("Select a Tone Buffer to store:")
    for i, tb in enumerate(prj.ToneBufferContainer):
        print(f"  {i} : {tb.Name}")

    print()
    valid = False
    while valid == False:
        choice = input("Make a selection or 'q' to quit: ").strip().lower()
        if choice == 'q':
            sys.exit()
        else:
            try:
                a = int(choice)
                if a >= 0 and a < len(prj.ToneBufferContainer):
                    valid = True
            except ValueError:
                valid = False

    tb = prj.ToneBufferContainer[a]

    dl = imslib.ToneBufferDownload(ims, tb)
    dl.Store("Test12", imslib.FileDefault_DEFAULT)
    print(f"Stored Tone Buffer {tb.Name} in NVM. Tone Buffer will be restored on power up.")


#############################
# Erase Tone Buffer from NVM
#############################
def EraseToneBuffer():
    fsm = imslib.FileSystemManager()
    fsm.Delete("Test12")
    print("Tone Buffer erased from NVM")


#############################
# Display Tone Buffer Menu
#############################

def display_menu():
    print()
    print("Tone Buffer Playback Menu ")
    print("    (1) -> Download a Tone Buffer")
    print("    (2) -> Add/Update a Single Tone")
    print("    (3) -> Play a Tone")
    print("    (4) -> Control Externally")
    print("    (5) -> Store Tone Buffer in NVM")
    print("    (6) -> Erase Tone Buffer from NVM")
    print("    (q) -> Quit")

while True:
    display_menu()
    print()
    choice = input("Select an option or 'q' to quit: ").strip().lower()
    if choice == 'q':
        break
    elif choice == '1':
        DownloadToneBuffer()
    elif choice == '2':
        DownloadSingleTone()
    elif choice == '3':
        PlayTone()
    elif choice == '4':
        ExternalControl()
    elif choice == '5':
        StoreToneBuffer()
    elif choice == '6':
        EraseToneBuffer()

sp.UpdateLocalToneBufferControl(sp.ToneBufferControl_OFF)
sp.ClearTone()

ims.Disconnect()