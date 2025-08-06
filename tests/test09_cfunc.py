import sys
import imslib
from ims_plot import *

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import MHz
from imslib import Degrees
from imslib import Percent
from imslib import CompensationTable, CompensationFunction, CompensationPoint, CompensationPointSpecification

print("Test 09: Working with Compensation Functions")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

###################################
# Introduction
###################################

print()
print("iMS Systems use Compensation Tables to:")
print("  (1) adjust for amplitude variation across the frequency range")
print("  (2) apply phase beam steering to maximise efficiency in AODs")
print("  (3) control external equipment or monitor performance in different frequency bands")
print()
print("Look-Up Tables are used to generate the required data for amplitude, phase or synchronous outputs with respect to frequency")
print("A LUT (CompensationTable) has a fixed number of points linearly spaced between a lower and upper frequency.")
print("These parameters are defined by the iMS hardware")
print("CompensationTable's may be applied Globally to all RF Channels, or individually, per Channel")
print()
print("The iMS SDK has rich support for generating CompensationTable's either by direct programming of LUT points, ")
print("or by rendering a CompensationTable from a single or multiple specifications called CompensationFunctions.")
print()

#############################
# Direct Programmng
#############################

print()
print("**1** Let's start by directly programming a LUT")
print("      We're not connecting to any hardware so our table will be for a hypothetical 1024pt LUT from 50-200MHz")

ctbl_direct = CompensationTable(1024, MHz(50.0), MHz(200.0))

for i in range(len(ctbl_direct)):
    # Simple ramp
    ctbl_direct[i].Amplitude = Percent(50.0 + 50.0 * (i / len(ctbl_direct)))
    ctbl_direct[i].Phase = Degrees((512 - i) * 45.0 / 512.0)

    # Ramp analogue between 110 and 130MHz
    if ctbl_direct.FrequencyAt(i).value < 110.0:
        ctbl_direct[i].SyncAnlg = 1.0
    elif ctbl_direct.FrequencyAt(i).value > 130.0:
        ctbl_direct[i].SyncAnlg = 0.0
    else:
        ctbl_direct[i].SyncAnlg = (130.0 - ctbl_direct.FrequencyAt(i).value) / 20.0

    # Switch control bit for frequencies below 100MHz
    if ctbl_direct.FrequencyAt(i).value < 100.0:
        ctbl_direct[i].SyncDig = 0x001
    else:
        ctbl_direct[i].SyncDig = 0

print()
print("      This figure shows how simple it is to create a compensation table with multiple features.\n" \
      "      The table we have programmed can be downloaded to an iMS system (assuming it matches in number of points and frequency range,\n" \
      "        if not, it will be automatically interpolated by the iMS library before downloading), and saved to disk as a .lut file")
print()
print("Close Figure to continue...")
plot_CompAll(ctbl_direct)
#plot_CompSyncD(ctbl_direct)
plt.tight_layout()
plt.show()

#############################
# Amplitude Function
#############################
print()
print("**2** Now let's render a table from a function specification \n" \
      "      Direct programming can be useful as it references the exact data used by the iMS system to modify the output signals using a look-up table.\n" \
      "      However it can be a little unwieldy to generate the LUT data in the required format.\n" \
      "      The iMS library has a set of features that allow the rendering of CompensationTable's from a function specification\n\n" \
      "      For example, let's say we have a test fixture that can measure the RF power and so the relative efficiency of an AOD at different frequencies\n" \
      "      We have the following results:\n" \
      "        @ 80MHz => 63%\n" \
      "        @ 90MHz => 47%\n" \
      "        @ 100MHz => 78%\n" \
      "        @ 110MHz => 85%\n" \
      "        @ 120MHz => 56%\n\n" \
      "      These can be encoded into a CompensationFunction which can then be rendered to a CompensationTable\n" \
      "      This figure shows the rendered table if the resulting values are inverted, normalised and held from one frequency measurement point to the next")

powerResults = [63, 47, 78, 85, 56]
freqPoints = [80, 90, 100, 110, 120]

cfunc_ampl = CompensationFunction()

# Create poweradjustment based on inverse of measured power normalised to maximum
powerAdjust = [(100 + min(powerResults) - p) for p in powerResults]

for p, f in zip(powerAdjust, freqPoints):
    cfunc_ampl.append(CompensationPointSpecification(CompensationPoint(Percent(p)), MHz(f)))

cfunc_ampl.AmplitudeInterpolationStyle = CompensationFunction.InterpolationStyle_STEP

ctbl_rendered = CompensationTable(1024, MHz(50.0), MHz(200.0))
ctbl_rendered.ApplyFunction(cfunc_ampl, imslib.CompensationFeature_AMPLITUDE)

print()
print("Close Figure to continue...")

plot_CompAmpl(ctbl_rendered)
plt.show()

print()
print("      We may prefer an extrapolated version instead...")

cfunc_ampl.AmplitudeInterpolationStyle = CompensationFunction.InterpolationStyle_LINEXTEND
ctbl_rendered.ApplyFunction(cfunc_ampl, imslib.CompensationFeature_AMPLITUDE)

plot_CompAmpl(ctbl_rendered)
plt.show()

print()
print("      Or a spline interpolation...")

cfunc_ampl.AmplitudeInterpolationStyle = CompensationFunction.InterpolationStyle_BSPLINE
ctbl_rendered.ApplyFunction(cfunc_ampl, imslib.CompensationFeature_AMPLITUDE)

plot_CompAmpl(ctbl_rendered)
plt.show()

print()
print("      It's possible to multiply one table by the values in another. For example, let's modify this one by\n" \
      "       the one we created directly earlier")

ctbl_multiply = ctbl_direct
ctbl_multiply.ApplyFunction(cfunc_ampl, imslib.CompensationFeature_AMPLITUDE, imslib.CompensationModifier_MULTIPLY)

plot_CompAmpl(ctbl_multiply)
plt.show()

print()
print("      So you can see it's very easy to quickly build up complex compensation tables based on multiple desired characteristics")

#############################
# Phase Function
#############################
print()
print("**3** It's possible to use all of this rendering features on Phase, Sync Analogue and Sync Digital tables too\n" \
      "      The iMS Library has built-in knowledge of AO Crystal properties and Isomet AO Devices.  Let's take advantage of that\n" \
      "      to build a phase steering compensation function")
print()
print("These are the Isomet AO Devices with data available:")
aolist = imslib.AODeviceList.GetList()

for i, ao in enumerate(aolist):
    print(f"  ({i+1}): {str(ao)}")

device = -1
while device == -1:
    device_str = input("Select a device: ").strip()
    try:
        device = int(device_str)
    except ValueError:
        device = -1
    if device > len(aolist) or device < 1:
        device = -1

# Get AOD parameters from library database
aod = imslib.AODevice(aolist[device-1])
print(f"Operating wavelength of device {aod.Model} is {aod.OperatingWavelength}um")
opw = -1
while opw == -1:
    opw_str = input("Use operating wavelength [ENTER] or custom wavelength? ")
    if not opw_str:
        cfunc_phase = aod.GetCompensationFunction()
        bragg = aod.ExternalBragg()
        break
    else:
        try:
            opw = float(opw_str)
            cfunc_phase = aod.GetCompensationFunction(imslib.Micrometre(opw))
            bragg = aod.ExternalBragg(imslib.Micrometre(opw))
        except ValueError:
            opw = -1

print("Ok. Let's apply that to our rendered table.  The library can create a function that we can plot the Phase Compensation response for.")
print()
print(f"AOD {aod.Model} is made from {aod.Material.Description}")
print(f"It has a centre frequency of {aod.CentreFrequency} and a bandwidth of {aod.SweepBW}")
print(f"The external Bragg Angle to set is: {bragg}")

ctbl_rendered.ApplyFunction(cfunc_phase, imslib.CompensationFeature_PHASE)

for i in range(len(ctbl_rendered)):
    # Switch control bit for frequencies within range of Sweep BW
    if ctbl_rendered.FrequencyAt(i).value > (aod.CentreFrequency.value - aod.SweepBW.value/2) and \
        ctbl_rendered.FrequencyAt(i).value < (aod.CentreFrequency.value + aod.SweepBW.value/2):
        ctbl_rendered[i].SyncDig = 0x001
    else:
        ctbl_rendered[i].SyncDig = 0
    
    ctbl_rendered[i].SyncAnlg = ctbl_rendered[i].Amplitude.value/100.0

plot_CompAll(ctbl_rendered)
plt.tight_layout()
plt.show()

#############################
# Save Compensation Functions
#############################
print()
print("We've created a number of different CompensationFunction objects in this example which we might decide to save for future use.\n" \
      "  ImageProjects can be used to store libraries of CompensationFunctions which can be useful building blocks for creating \n" \
      "  look-up tables to download to iMS systems depending on the AOD type or measured response of a particular optical system")
print()
print("Let's save these for later")

prj = imslib.ImageProject()
prj.CompensationFunctionContainer.append(cfunc_ampl)
prj.CompensationFunctionContainer.append(cfunc_phase)
print("Saving image group to CompensationFunctions.iip")
prj.Save("CompensationFunctions.iip")  # iMS Project files use .iip extension as default

#############################
# Export Compensation Table
#############################
print()
print("Once we're happy with the rendered results of our Compensation Functions, we can export them to disk for later, or download to the hardware\n" \
      "  Let's export our Compensation Table and we'll explore downloading in the next example")

exporter = imslib.CompensationTableExporter()
# For now, we just use a single table for all channels (global compensation)
exporter.ProvideGlobalTable(ctbl_rendered)
exporter.ExportGlobalLUT("myCompensationTable.lut")  # Any extension will do, but .lut is typical

print("Compensation Table saved to myCompensationTable.lut")

sys.exit()
