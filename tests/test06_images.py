import sys
import math
import imslib
from ims_plot import *

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import MHz
from imslib import Degrees
from imslib import Percent
from imslib import FAP

print("Test 06: Working with Image Points, Images and Image Groups")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

###################################
# Create an Image Group of 3 images
###################################

print()
print("Let's start by defining an Image Group with 3 images")
grp = imslib.ImageGroup(3, "My Test Image Group")
print(grp)

fullAmpl = Percent(100)
zeroPhase = Degrees(0)
#############################
# Modify and Plot Image 1
#############################

print()
print("Image 1: Create a 500pt linear ramp from 70-130MHz at full amplitude")

im1=grp[0]
freq = MHz()
startFreq = 70.0
endFreq = 130.0
for i in range(0,500):
    freq.value = startFreq + (endFreq - startFreq) * i / 500
    pt = imslib.ImagePoint(FAP(freq, fullAmpl, zeroPhase))
    im1.append(pt)

print(grp[0])
print("Image Point 100:") 
print(grp[0][100])

print("Now let's say I want channels 3 and 4 to ramp in the reverse direction")
for i, pt in enumerate(reversed(im1)):
    im1[i].FreqCh3 = pt.FreqCh1
    im1[i].FreqCh4 = pt.FreqCh2

print("Image Point 100 is now:") 
print(grp[0][100])

print("Let's plot this. Close the figure to continue")
plot_ImageFreq(im1)
plt.tight_layout()
plt.show()

#############################
# Create Image 2
#############################
im2=grp[1]

print()
print("Image 2 has 5 discrete points centred around Fc = 110MHz")
# Create 5 discrete dots at 8MHz spacing around Fc=110MHz and randomly select them
freq = MHz()
ampl = Percent(80.0)
phaseinc = Degrees(0.0)
Fc = 110.0
step = 8.0

for i in range(-60,60):
    freq.value = step * math.floor(i / 20) + Fc
    ampl.value = 80.0 - 20.0 * (freq.value / Fc) ** 4
    phaseinc.value = (freq.value - Fc) * (5.0 / step)
    pt = imslib.ImagePoint(FAP(freq, ampl, zeroPhase), 
                           FAP(freq, ampl, phaseinc), 
                           FAP(freq, ampl, Degrees(2*phaseinc.value)), 
                           FAP(freq, ampl, Degrees(3*phaseinc.value)))
    im2.append(pt)

plot_ImageFAP(im2)
plt.tight_layout()
print("Each channel has a different phase value such as might be used in a beam steered AOD")
print(" Close the image to continue")
plt.show()

#############################
# Create Image 3
#############################
im3=grp[2]

print()
print("Image 3 shows how we can use sync data to observe Image progress and/or trigger external equipment")

freq = MHz()
ampl = Percent()
imlen = 1024
upperFreq = 180.0
lowerFreq = 105.0
for i in range(0,imlen):
    if (i > imlen/2):
        freq.value = lowerFreq + (imlen - i) / (imlen/2) * (upperFreq - lowerFreq)
    else:
        freq.value = lowerFreq + (i / (imlen/2)) * (upperFreq - lowerFreq)
    ampl.value = 90.0 * math.cos(math.pi/2 * (i-imlen/2)/imlen)
    pt = imslib.ImagePoint(FAP(freq, ampl, zeroPhase))

    syncData = i
    if i < 32:
        syncData |= int("0x800", 16)
    pt.SyncA1 = freq.value / upperFreq
    pt.SyncA2 = ampl.value / 100.0
    pt.SyncD = syncData
    im3.append(pt)

plot_ImageAll(im3)
plt.tight_layout()

print("The two analogue outputs represent the frequency and amplitude respectively")
print(" while the digital output encodes the image index and has the top bit asserted for the first 32 clock cycles")
print(" Close the image to continue")
plt.show()

#############################
# Create a bank of X/Y images
#############################
lissgrp = imslib.ImageGroup(9, "Lissajous Group")

print()
print("Let's see how we might use two channels to drive an X/Y deflector")

def generate_lissajous(a, b, samples=1000):
    """
    Generate X and Y lists for a Lissajous figure.
    
    Parameters:
        a (int): Frequency for the X axis.
        b (int): Frequency for the Y axis.
        samples (int): Number of points to generate.

    Returns:
        tuple: (x_values, y_values)
    """
    x_values = []
    y_values = []

    for i in range(samples):
        t = (i / samples) * 2 * math.pi
        x = math.sin(a * t)
        y = math.sin(b * t + math.pi / 2)  # phase shift to make it more interesting
        x_values.append(x)
        y_values.append(y)

    return x_values, y_values

fig, axs = plt.subplots(3, 3, figsize=(18,10))
Fc = 100.0
span = 30.0
for a in range(1,4):
    for b in range(1,4):
        liss=lissgrp[(a-1)*3+b-1]
        x, y = generate_lissajous(a,b)
        for xval, yval in zip(x, y):
            xfap = FAP(Fc + span * xval, 100.0, 0.0)
            yfap = FAP(Fc + span * yval, 100.0, 0.0)
            liss.append(imslib.ImagePoint(xfap, xfap, yfap, yfap))
        plot_ImageFreqXY(liss, axs[a-1,b-1], title=f"Lissajous a={a} b={b}")

plt.tight_layout()
print(" Close the image to continue")
plt.show()

#############################
# Save to Disk
#############################
# We decide we really like this last group of Images and want to save it to disk to recall later on
# (Or to open in Isomet iMS Studio)
prj = imslib.ImageProject()
prj.ImageGroupContainer.append(lissgrp)
print("Saving image group to LissajousGroup.iip")
prj.Save("LissajousGroup.iip")  # iMS Project files use .iip extension as default

# Reopen and test
print()
print("Reloading image group from LissajousGroup.iip")
print(" Checking each image in the group matches the original image")
prj2 = imslib.ImageProject("LissajousGroup.iip")
if len(prj2.ImageGroupContainer) < 1:
    print("Error: No groups in ImageGroupContainer")
else:
    for im, liss in zip(prj2.ImageGroupContainer[0], lissgrp):
        print(f" -> {im.Name}: TEST => {im == liss}")

sys.exit()
