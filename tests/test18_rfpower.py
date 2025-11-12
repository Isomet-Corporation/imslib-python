import imslib
import sys

from ims_scan import iMSScanner

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import MHz
from imslib import Percent
from imslib import Degrees
from imslib import FAP
from imslib import RFChannel

import tkinter as tk
from tkinter import ttk

print("Test 18: RF Power / Amplifier Control")
# A very simple example GUI demonstrating how to control system functions like amplifier enable and RF power

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

class PowerController:
    def __init__(self, sp, sf):
        # Default Frequency, Amplitude & Phase
        self.tone = FAP(MHz(100.0), Percent(100.0), Degrees(0.0))
        self.toneOn = False
        self.sp = sp
        self.sf = sf

    def enable_tone(self):
        self.sp.SetCalibrationTone(self.tone)
        self.toneOn = True

    def disable_tone(self):
        self.sp.ClearTone()
        self.toneOn = False

    def update_freq(self, f):
        self.tone.freq = MHz(f)
        if self.toneOn is True:
            self.enable_tone()

    def set_dds_power(self, p):
        self.sp.UpdateDDSPowerLevel(Percent(p))

    def set_chan_power(self, p, c):
        self.sp.UpdateRFAmplitude(imslib.SignalPath.AmplitudeControl_INDEPENDENT, Percent(p), RFChannel(c))

    def set_int_modulation(self):
        self.sp.SwitchRFAmplitudeControlSource(imslib.SignalPath.AmplitudeControl_INDEPENDENT)

    def set_ext_modulation(self):
        self.sp.SwitchRFAmplitudeControlSource(imslib.SignalPath.AmplitudeControl_EXTERNAL)

    def enable_amp(self):
        self.sf.EnableAmplifier(True)
        self.sf.EnableRFChannels(True, True)

    def disable_amp(self):
        self.sf.EnableAmplifier(False)
        self.sf.EnableRFChannels(False, False)


#####################################
# GUI
#####################################

class PowerControllerGUI:
    def __init__(self, master, controller):
        self.master = master
        self.controller = controller
        master.title(" iMS Power Controller")

        self.build_ui()

    def build_ui(self):
        # --- Tone controls ---
        tone_frame = ttk.LabelFrame(self.master, text="Tone Control", padding=10)
        tone_frame.grid(row=0, column=0, padx=10, pady=10, sticky="ew")

        # Frequency slider
        self.freq_var = tk.DoubleVar(value=100.0)
        ttk.Label(tone_frame, text="Tone Frequency (MHz)").grid(row=0, column=0, sticky="w")
        freq_slider = ttk.Scale(tone_frame, from_=10, to=220, variable=self.freq_var, command=self.on_freq_change)
        freq_slider.grid(row=0, column=1, padx=10, sticky="ew")

        # Tone enable checkbox
        self.tone_on_var = tk.BooleanVar(value=False)
        tone_check = ttk.Checkbutton(
            tone_frame, text="Enable Tone", variable=self.tone_on_var, command=self.on_tone_toggle
        )
        tone_check.grid(row=1, column=0, columnspan=2, sticky="w")

        # --- DDS Power ---
        dds_frame = ttk.LabelFrame(self.master, text="DDS Power", padding=10)
        dds_frame.grid(row=1, column=0, padx=10, pady=10, sticky="ew")

        self.dds_var = tk.DoubleVar(value=100.0)
        ttk.Label(dds_frame, text="DDS Power (%)").grid(row=0, column=0, sticky="w")
        dds_slider = ttk.Scale(dds_frame, from_=0, to=100, variable=self.dds_var, command=self.on_dds_change)
        dds_slider.grid(row=0, column=1, padx=10, sticky="ew")

        # --- RF Channel Controls ---
        rf_frame = ttk.LabelFrame(self.master, text="RF Channels", padding=10)
        rf_frame.grid(row=2, column=0, padx=10, pady=10, sticky="ew")

        self.chan_vars = []
        for c in range(4):
            var = tk.DoubleVar(value=100.0)
            self.chan_vars.append(var)
            ttk.Label(rf_frame, text=f"RF Channel {c+1} Power (%)").grid(row=c, column=0, sticky="w")
            slider = ttk.Scale(rf_frame, from_=0, to=100, variable=var, command=lambda val, ch=c: self.on_chan_change(val, ch))
            slider.grid(row=c, column=1, padx=10, sticky="ew")

        # --- Amplifier Controls ---
        amp_frame = ttk.LabelFrame(self.master, text="Amplifier", padding=10)
        amp_frame.grid(row=3, column=0, padx=10, pady=10, sticky="ew")

        self.amp_on_var = tk.BooleanVar(value=False)
        amp_check = ttk.Checkbutton(
            amp_frame, text="Enable Amplifier", variable=self.amp_on_var, command=self.on_amp_toggle
        )
        amp_check.grid(row=0, column=0, sticky="w")

        # --- Modulation Source ---
        mod_frame = ttk.LabelFrame(self.master, text="Modulation Source", padding=10)
        mod_frame.grid(row=4, column=0, padx=10, pady=10, sticky="ew")

        self.mod_mode = tk.StringVar(value="internal")
        ttk.Radiobutton(mod_frame, text="Internal", variable=self.mod_mode, value="internal", command=self.on_mod_change).grid(row=0, column=0)
        ttk.Radiobutton(mod_frame, text="External", variable=self.mod_mode, value="external", command=self.on_mod_change).grid(row=0, column=1)

        # Configure layout stretch
        for frame in [tone_frame, dds_frame, rf_frame]:
            frame.columnconfigure(1, weight=1)

    # --- Event Handlers ---
    def on_freq_change(self, val):
        freq = float(val)
        self.controller.update_freq(freq)

    def on_dds_change(self, val):
        power = float(val)
        self.controller.set_dds_power(power)

    def on_chan_change(self, val, ch):
        power = float(val)
        self.controller.set_chan_power(power, ch+1)

    def on_tone_toggle(self):
        if self.tone_on_var.get():
            self.controller.enable_tone()
        else:
            self.controller.disable_tone()

    def on_amp_toggle(self):
        if self.amp_on_var.get():
            self.controller.enable_amp()
        else:
            self.controller.disable_amp()

    def on_mod_change(self):
        if self.mod_mode.get() == "internal":
            self.controller.set_int_modulation()
        else:
            self.controller.set_ext_modulation()


if __name__ == "__main__":
    scanner = iMSScanner()
    if scanner.scan():
        ims = scanner.get_system()
    else:
        sys.exit()

    ims.Connect()

    sp = imslib.SignalPath(ims)
    sf = imslib.SystemFunc(ims)

    # Start with tone disabled
    sp.ClearTone()

    tc = PowerController(sp, sf)

    root = tk.Tk()
    app = PowerControllerGUI(root, tc)
    root.mainloop()


sp.ClearTone()

ims.Disconnect()