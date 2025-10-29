import imslib
import os.path
import sys
import time

from ims_scan import iMSScanner
from ims_events import EventWaiter, WaitOnEventsThenPrint

print("Test 07: Download Images to iMS System")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

# Select first available system
scanner = iMSScanner()
if scanner.scan(auto_select=True):
    ims = scanner.get_system()
else:
    sys.exit()

ims.Connect()

# Reuse Lissajous Image Project from previous test
if os.path.isfile("LissajousGroup.iip") == False:
    print("Can't find Image Project 'LissajousGroup.iip'. Please run the previous example to regenerate it")
    sys.exit()

#############################
# Load Image Project
#############################
prj = imslib.ImageProject("LissajousGroup.iip")

if len(prj.ImageGroupContainer) < 1:
    print("Error: No groups in ImageGroupContainer")
    sys.exit()

#######################################
# Download all Images to iMS and Verify
#######################################

# List of Events that we will subscribe to, and strings to print when they fire
EVENT_MESSAGES = {
    imslib.DownloadEvents_VERIFY_SUCCESS: "✅ Verify success!",
    imslib.DownloadEvents_VERIFY_FAIL: "❌ Verify failed!",
    imslib.DownloadEvents_DOWNLOAD_ERROR: "⚠️ Download error",
    imslib.DownloadEvents_DOWNLOAD_FINISHED: "✅ Download finished",
    imslib.DownloadEvents_DOWNLOAD_FAIL_MEMORY_FULL: "⚠️ Download failed: memory full",
    imslib.DownloadEvents_DOWNLOAD_FAIL_TRANSFER_ABORT: "⚠️ Download failed: transfer aborted",
}

# Demonstrates a function with custom logic to execute when events are received
def CustomVerifyWaitOnEvents(waiter: EventWaiter, timeout: float = 5.0):
    while True:
        try:
            msg, params = waiter.wait(timeout)
            if msg == imslib.DownloadEvents_VERIFY_SUCCESS:
                return True
            elif msg == imslib.DownloadEvents_VERIFY_FAIL:
                return False
        except TimeoutError:
            print("⏱️ Timed out waiting for events.")
            return False

grp = prj.ImageGroupContainer[0]
for img in grp:
    dl = imslib.ImageDownload(ims, img)
    waiter = EventWaiter()

    # Define the list of events the waiter should wait for
    waiter.listen_for(list(EVENT_MESSAGES.keys()))
    
    # Subscribe the waiter
    for evt in waiter._watched:
        dl.ImageDownloadEventSubscribe(evt, waiter)
        
    print(f"Downloading Image: {img.Name}   ", end=" ")
    dl.StartDownload()

    # Waits for the first event to arrive and prints a message
    WaitOnEventsThenPrint(waiter, EVENT_MESSAGES, timeout=5.0)

    print(f"Verifying Image:   {img.Name}   ", end=" ")
    dl.StartVerify()

    # Our custom event handler that determines whether the verify was successfull or not.
    verifyResult = CustomVerifyWaitOnEvents(waiter)
    if verifyResult:
        print("Verify Sucessful")
    else:
        print("Verify Failed. Aborting")
        break

    # Unsubscribe
    for evt in waiter._watched:
        dl.ImageDownloadEventUnsubscribe(evt, waiter)
            
#############################
# Display Image Table
#############################

table=imslib.ImageTableViewer(ims)
print(f"{len(table)} images in table")
print(table)

ims.Disconnect()