import imslib
import os.path
import sys
import time

print("Test 07: Download Images to iMS System")

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

grp = prj.ImageGroupContainer[0]
for img in grp:
    dl = imslib.ImageDownload(ims, img)
    print(f"Downloading Image: {img.Name}")
    dl.StartDownload()
    time.sleep(1)

table=imslib.ImageTableViewer(ims)
print(f"{len(table)} images in table")
print(table)
ims.Disconnect()