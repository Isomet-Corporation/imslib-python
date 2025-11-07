import imslib
import sys

from ims_scan import iMSScanner
from ims_apputil import KeyListener

from imslib import SystemFunc

print("Test 14: Apply a Software Reset")

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

print("When ready, press any key to reset the iMS System")

key_listener = KeyListener()
key_listener.start()

while True:
    key = key_listener.get_key()
    if key:
        # The NHF (Not Healthy Flag) is designed to self-reset the iMS system when it loses comms with the host
        # In normal usage, applications should send a heartbeat message on a regular interval and configure the
        # flag to reset on a multiple of the interval.  This example reuses that process with a very short interval
        # and no heartbeat to cause the iMS to self-reset
        sf.ClearNHF()
        sf.ConfigureNHF(True, 10, SystemFunc.NHFLocalReset_RESET_ON_COMMS_UNHEALTHY)   ## Resets when no message received within 10ms (an artifically short period to enforce a reset)
        break

key_listener.stop()
key_listener.join()

ims.Disconnect()