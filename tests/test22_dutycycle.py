import imslib
import sys
import time

from ims_scan import iMSScanner
from ims_events import EventWaiter, WaitOnEventsThenPrint

from imslib import MHz, kHz, Percent, NanoSeconds
from imslib import FAP
from imslib import PointClock, ImageTrigger, StopStyle, ImageRepeats_FOREVER

print("Test 22: RF Duty Cycle with Image Playback")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available system
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

#############################
# Create a simple image
#############################

print()
print("Creating a simple 100-point image: linear frequency ramp 80-120 MHz")

im = imslib.Image()
freq = MHz()
for i in range(100):
    freq.value = 80.0 + 40.0 * i / 100
    im.append(imslib.ImagePoint(FAP(freq, Percent(80.0), imslib.Degrees(0.0))))

#############################
# Download the image
#############################

EVENT_MESSAGES = {
    imslib.DownloadEvents_VERIFY_SUCCESS: "Verify success",
    imslib.DownloadEvents_VERIFY_FAIL: "Verify failed",
    imslib.DownloadEvents_DOWNLOAD_ERROR: "Download error",
    imslib.DownloadEvents_DOWNLOAD_FINISHED: "Download finished",
    imslib.DownloadEvents_DOWNLOAD_FAIL_MEMORY_FULL: "Download failed: memory full",
    imslib.DownloadEvents_DOWNLOAD_FAIL_TRANSFER_ABORT: "Download failed: transfer aborted",
}

dl = imslib.ImageDownload(ims, im)
waiter = EventWaiter()
waiter.listen_for(list(EVENT_MESSAGES.keys()))
for evt in waiter._watched:
    dl.ImageDownloadEventSubscribe(evt, waiter)

print(f"Downloading image...   ", end=" ")
dl.StartDownload()
WaitOnEventsThenPrint(waiter, EVENT_MESSAGES, timeout=5.0)

print(f"Verifying image...     ", end=" ")
dl.StartVerify()

verify_ok = False
while True:
    try:
        msg, _ = waiter.wait(timeout=5.0)
        if msg == imslib.DownloadEvents_VERIFY_SUCCESS:
            print("Verify successful")
            verify_ok = True
            break
        elif msg == imslib.DownloadEvents_VERIFY_FAIL:
            print("Verify failed. Aborting")
            break
    except TimeoutError:
        print("Timed out waiting for verify. Aborting")
        break

for evt in waiter._watched:
    dl.ImageDownloadEventUnsubscribe(evt, waiter)

if not verify_ok:
    ims.Disconnect()
    sys.exit()

#############################
# Configure signal path
#############################

sp = imslib.SignalPath(ims)

sp.UpdateDDSPowerLevel(Percent(80.0))
sp.UpdateRFAmplitude(imslib.SignalPath.AmplitudeControl_INDEPENDENT, Percent(80.0))
sp.SwitchRFAmplitudeControlSource(imslib.SignalPath.AmplitudeControl_INDEPENDENT)
sp.EnableImagePathCompensation(False, False)
sp.ClearTone()
sp.ExtPhaseResync(False)

#############################
# Ask user about duty cycling
#############################

print()
duty_cycle_enabled = False
answer = input("Enable RF duty cycling? (y/n): ").strip().lower()
if answer == 'y':
    delay_ns = 0
    width_ns = 0

    while True:
        try:
            delay_ns = int(input("  Duty cycle delay (ns): ").strip())
            break
        except ValueError:
            print("  Please enter an integer value.")

    while True:
        try:
            width_ns = int(input("  RF window width (ns): ").strip())
            break
        except ValueError:
            print("  Please enter an integer value.")

    result = sp.SetRFDutyCycle(True, NanoSeconds(delay_ns), NanoSeconds(width_ns))
    if result:
        print(f"RF duty cycle enabled: delay={delay_ns} ns, width={width_ns} ns")
        duty_cycle_enabled = True
    else:
        print("SetRFDutyCycle returned False — check parameters and hardware state")
else:
    sp.SetRFDutyCycle(False, NanoSeconds(0), NanoSeconds(0))
    print("RF duty cycling disabled")

#############################
# Play the image
#############################

print()
table = imslib.ImageTableViewer(ims)
if len(table) == 0:
    print("No images in table — nothing to play")
    ims.Disconnect()
    sys.exit()

# Play the most recently downloaded image (last entry in table)
img_entry = table[len(table) - 1]

cfg = imslib.ImagePlayerConfiguration()
cfg.Clock = PointClock.INTERNAL
cfg.Trig = ImageTrigger.CONTINUOUS
cfg.rpts = ImageRepeats_FOREVER

player = imslib.ImagePlayer(ims, img_entry, kHz(100.0))
player.Config = cfg

play_waiter = EventWaiter()
play_waiter.listen_for([imslib.ImagePlayerEvents_POINT_PROGRESS, imslib.ImagePlayerEvents_IMAGE_FINISHED])
for evt in play_waiter._watched:
    player.ImagePlayerEventSubscribe(evt, play_waiter)

print(f"Playing image: {img_entry.Name}")
print("Press Enter to stop playback")
player.Play()

import threading

stop_event = threading.Event()

def wait_for_enter():
    input()
    stop_event.set()

t = threading.Thread(target=wait_for_enter, daemon=True)
t.start()

while not stop_event.is_set():
    try:
        msg, args = play_waiter.wait(timeout=0.5)
        if msg == imslib.ImagePlayerEvents_POINT_PROGRESS:
            progress = args[0] if args else 0
            print(f"\rProgress: {progress}   ", end="", flush=True)
        elif msg == imslib.ImagePlayerEvents_IMAGE_FINISHED:
            print("\nPlayback finished")
            break
    except TimeoutError:
        player.GetProgress()

player.Stop(StopStyle.IMMEDIATELY)
for evt in play_waiter._watched:
    player.ImagePlayerEventUnsubscribe(evt, play_waiter)

#############################
# Disable duty cycle on exit
#############################

if duty_cycle_enabled:
    sp.SetRFDutyCycle(False, NanoSeconds(0), NanoSeconds(0))
    print("RF duty cycling disabled")

sp.ClearTone()
ims.Disconnect()
