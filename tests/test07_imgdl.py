import imslib
import os.path
import sys
import time

from ims_scan import iMSScanner

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

#############################
# Download all Images to iMS
#############################

grp = prj.ImageGroupContainer[0]
for img in grp:
    dl = imslib.ImageDownload(ims, img)
    print(f"Downloading Image: {img.Name}")
    dl.StartDownload()
    time.sleep(1)  ## Simple delay as no response capability yet in Python

#############################
# Display Image Table
#############################

table=imslib.ImageTableViewer(ims)
print(f"{len(table)} images in table")
print(table)

ims.Disconnect()