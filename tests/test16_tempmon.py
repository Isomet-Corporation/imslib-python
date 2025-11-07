import imslib
import sys
import time
import threading

from ims_scan import iMSScanner
from ims_apputil import KeyListener
from ims_events import EventWaiter

from imslib import SystemFunc, Diagnostics

print("Test 16: System Temperature Monitor")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available system
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

# This example uses the event handler mechanism to receive temperature reports and logged hours from the system
# SystemFunc is used to read Synthesiser internal temperatures
sf = SystemFunc(ims)

# Diagnostics is used for more advanced system monitoring.  This isn't supported on all Synths (including the iCSA Compact Synth), but it does support reading back synthesiser logged hours
diag = Diagnostics(ims)

#############################
# Temperature Monitor Event loop thread
#############################

class TemperatureEventLoop(threading.Thread):
    def __init__(self, sysFunc, waiter, event_messages):
        super().__init__(daemon=True)
        self.waiter = waiter
        self.sysFunc = sysFunc
        self.event_messages = event_messages
        self.event_monitor = {}
        self._running = threading.Event()

    def subscribe(self):
        for evt in self.event_messages.keys():
            self.sysFunc.SystemFuncEventSubscribe(evt, self.waiter)

    def unsubscribe(self):
        for evt in self.event_messages.keys():
            self.sysFunc.SystemFuncEventUnsubscribe(evt, self.waiter)

    def run(self):
        self._running.set()
        self.subscribe()
        try:
            while self._running.is_set():
                try:
                    msg, args = self.waiter.wait(timeout=0.1)
                    if msg in self.event_messages:
                        self.event_monitor[msg] = args[0]
                except TimeoutError:
                    continue
        finally:
            self.unsubscribe()

    def get_value(self, i):
        if i in self.event_monitor:
            return self.event_monitor[i]

    def stop(self):
        self._running.clear()

TEMP_EVENT_MESSAGES = {
    imslib.SystemFuncEvents_SYNTH_TEMPERATURE_1: "Temperature Monitor 1",
    imslib.SystemFuncEvents_SYNTH_TEMPERATURE_2: "Temperature Monitor 2",
}

#############################
# Logged Hours Monitor Event loop thread
#############################

class HoursEventLoop(threading.Thread):
    def __init__(self, diag, waiter, event_messages):
        super().__init__(daemon=True)
        self.waiter = waiter
        self.diag = diag
        self.event_messages = event_messages
        self.event_monitor = {}
        self._running = threading.Event()

    def subscribe(self):
        for evt in self.event_messages.keys():
            self.diag.DiagnosticsEventSubscribe(evt, self.waiter)

    def unsubscribe(self):
        for evt in self.event_messages.keys():
            self.diag.DiagnosticsEventUnsubscribe(evt, self.waiter)

    def run(self):
        self._running.set()
        self.subscribe()
        try:
            while self._running.is_set():
                try:
                    msg, args = self.waiter.wait(timeout=0.1)
                    if msg in self.event_messages:
                        self.event_monitor[msg] = args[0]
                except TimeoutError:
                    continue
        finally:
            self.unsubscribe()

    def get_value(self, i):
        if i in self.event_monitor:
            return self.event_monitor[i]

    def stop(self):
        self._running.clear()

HOURS_EVENT_MESSAGES = {
    imslib.DiagnosticsEvents_SYN_LOGGED_HOURS: "Synth Logged Hours: ",
}

#############################
# Create Listening Threads
#############################

SystemFuncWaiter = EventWaiter()
SystemFuncWaiter.listen_for(list(TEMP_EVENT_MESSAGES.keys()))

DiagnosticsWaiter = EventWaiter()
DiagnosticsWaiter.listen_for(list(HOURS_EVENT_MESSAGES.keys()))

# Start threads to listen for callbacks from library and input from user
temp_event_loop = TemperatureEventLoop(sf, SystemFuncWaiter, TEMP_EVENT_MESSAGES)
temp_event_loop.start()

hours_event_loop = HoursEventLoop(diag, DiagnosticsWaiter, HOURS_EVENT_MESSAGES)
hours_event_loop.start()

key_listener = KeyListener()
key_listener.start()

#############################
# Main Loop
#############################

print("Press any key to stop temperature monitoring...")
running = True
while running:
    key = key_listener.get_key()
    if key:
        break

    sf.ReadSystemTemperature(SystemFunc.TemperatureSensor_TEMP_SENSOR_1)
    sf.ReadSystemTemperature(SystemFunc.TemperatureSensor_TEMP_SENSOR_2)
    diag.GetLoggedHours(Diagnostics.TARGET_SYNTH)

    time.sleep(1.0)

    print("\r", end="", flush=True)
    for i in TEMP_EVENT_MESSAGES:
        print(f"\t{TEMP_EVENT_MESSAGES.get(i)}: {temp_event_loop.get_value(i)}  ", end="", flush=True)
    for i in HOURS_EVENT_MESSAGES:
        print(f"\t {HOURS_EVENT_MESSAGES.get(i)}: {hours_event_loop.get_value(i)}  ", end="", flush=True)

print()

key_listener.stop()
temp_event_loop.stop()
hours_event_loop.stop()

key_listener.join()
temp_event_loop.join()
hours_event_loop.join()

ims.Disconnect()
