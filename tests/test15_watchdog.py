import imslib
import sys

from ims_scan import iMSScanner
from ims_apputil import KeyListener

from imslib import SystemFunc

print("Test 15: Communications Watchdog")

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

# This example uses the heartbeat function of the iMS library to monitor host communications and reset 
# the device if communications are lost.  Heartbeats can either be sent manually on a regular interval
# by application code, or automatically by starting the heartbeat timer in the library.  In this example,
# we shall use the automatic function

heartbeatInterval = 3000

sf.ClearNHF()
sf.StartHeartbeat(heartbeatInterval)
sf.ConfigureNHF(True, 3*heartbeatInterval, SystemFunc.NHFLocalReset_RESET_ON_COMMS_UNHEALTHY)

print("When ready, press any key to stop the heartbeat.  System will reset after watchdog expires")

key_listener = KeyListener()
key_listener.start()

while True:
    key = key_listener.get_key()
    if key:
        sf.StopHeartbeat()
        break

key_listener.stop()
key_listener.join()

ims.Disconnect()
