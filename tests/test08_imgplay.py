import imslib
import sys

from ims_events import EventWaiter

from imslib import kHz, Percent
from imslib import PointClock, ImageTrigger, StopStyle

from ims_scan import iMSScanner
from ims_apputil import KeyListener

import threading
import queue
import time
import sys

#############################
# Event loop thread
#############################

class PlayerEventLoop(threading.Thread):
    def __init__(self, player, waiter, event_messages, stop_event_ids=None):
        super().__init__(daemon=True)
        self.waiter = waiter
        self.player = player
        self.event_messages = event_messages
        self.stop_event_ids = set(stop_event_ids or [])
        self._running = threading.Event()
        self._queue = queue.Queue()

    def subscribe(self):
        for evt in self.event_messages.keys():
            self.player.ImagePlayerEventSubscribe(evt, self.waiter)

    def unsubscribe(self):
        for evt in self.event_messages.keys():
            self.player.ImagePlayerEventUnsubscribe(evt, self.waiter)

    def run(self):
        self._running.set()
        self.subscribe()
        try:
            while self._running.is_set():
                try:
                    msg, args = self.waiter.wait(timeout=0.1)
                    self._queue.put((msg, args))
                    if msg in self.stop_event_ids:
                        self._running.clear()
                except TimeoutError:
                    continue
        finally:
            self.unsubscribe()

    def get_event(self):
        try:
            return self._queue.get_nowait()
        except queue.Empty:
            return None

    def stop(self):
        self._running.clear()

EVENT_MESSAGES = {
    imslib.ImagePlayerEvents_POINT_PROGRESS: "Progress",
    imslib.ImagePlayerEvents_IMAGE_FINISHED: "Playback finished",
}

print("Test 08: Play Images on iMS System")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available system
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

sp = imslib.SignalPath(ims)

print("Set RF output amplitude.")
sp.UpdateDDSPowerLevel(Percent(80.0))
sp.UpdateRFAmplitude(imslib.SignalPath.AmplitudeControl_INDEPENDENT, Percent(80.0))
sp.SwitchRFAmplitudeControlSource(imslib.SignalPath.AmplitudeControl_INDEPENDENT)

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
            if index >= len(table) or index < 0:
                index = -1
        if ic.is_internal_clock():
            player = imslib.ImagePlayer(ims, table[index], ic.clockRate)
        else:
            player = imslib.ImagePlayer(ims, table[index], ic.clockDiv)
        
        player.Config = ic.cfg

        waiter = EventWaiter()
        waiter.listen_for(list(EVENT_MESSAGES.keys()))

        # Start threads to listen for callbacks from library and input from user
        event_loop = PlayerEventLoop(player, waiter, EVENT_MESSAGES, stop_event_ids=[imslib.ImagePlayerEvents_IMAGE_FINISHED])
        key_listener = KeyListener()

        event_loop.start()
        key_listener.start()

        player.Play()

        print("Press <SPACE> to abort playback")
        running = True
        while running:
            # Handle events
            event = event_loop.get_event()
            if event:
                msg, args = event
                friendly_msg = EVENT_MESSAGES.get(msg, f"Unknown event {msg}")
                if msg == imslib.ImagePlayerEvents_POINT_PROGRESS:
                    progress = args[0] if args else 0
                    print(f"\r{friendly_msg}: {progress}   ", end="", flush=True)
                elif msg == imslib.ImagePlayerEvents_IMAGE_FINISHED:
                    print(f"\n{friendly_msg}")
                    running = False

            # Handle keyboard input
            key = key_listener.get_key()
            if key:
                if key.lower() == ' ':
                    player.Stop(StopStyle.IMMEDIATELY)

            time.sleep(0.5)
            player.GetProgress()

        # Stop threads cleanly
        event_loop.stop()
        key_listener.stop()
        event_loop.join()
        key_listener.join()
        
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


sp.ClearTone()
ims.Disconnect()