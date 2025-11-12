import imslib
import sys

from ims_scan import iMSScanner

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import Auxiliary
from imslib import SystemFunc

import tkinter as tk
from tkinter import ttk

print("Test 20: LED Assignment")
# A very simple example GUI demonstrating how to assign LEDs but also how to store startup state to the iMS system
# This example could be extended into a full system configurator allowing iMS systems to operate standalone on
# power-up without software connection

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

LED_SOURCE_NAMES = [
    "OFF", "ON", "PULS", "NPULS", "PIXEL_ACT", "CTRL_ACT",
    "COMMS_HEALTHY", "COMMS_UNHEALTHY", "RF_GATE", "INTERLOCK",
    "LASER", "CHECKSUM", "OVERTEMP", "PLL_LOCK"
]

LED_SINK_NAMES = [
    "GREEN",
	"YELLOW",
	"RED"
]

# Map strings back to the SWIG constants
LED_SOURCE_MAP = {name: getattr(Auxiliary, f"LED_SOURCE_{name}") for name in LED_SOURCE_NAMES}
LED_SINK_MAP = {name: getattr(Auxiliary, f"LED_SINK_{name}") for name in LED_SINK_NAMES}

def assign_led(led_index, source):
    """Called when a combo box changes selection"""
    sink = LED_SINK_NAMES[led_index]
    print(f"{LED_SINK_NAMES[led_index]} LED set to {source}")
    aux.AssignLED(LED_SINK_MAP[sink], LED_SOURCE_MAP[source])

def store_defaults(sf):
    """Store the current LED selections to Flash"""
    values_to_store = [LED_SOURCE_MAP[combo.get()] for combo in combo_boxes]
    print("Storing default LED values to Flash:", values_to_store)

    cfg = imslib.StartupConfiguration()
    cfg.LEDGreen = values_to_store[LED_SINK_NAMES.index("GREEN")]
    cfg.LEDYellow = values_to_store[LED_SINK_NAMES.index("YELLOW")]
    cfg.LEDRed = values_to_store[LED_SINK_NAMES.index("RED")]

    sf.StoreStartupConfig(cfg)

if __name__ == "__main__":
    scanner = iMSScanner()
    if scanner.scan(auto_select=True):
        ims = scanner.get_system()
    else:
        sys.exit()

    ims.Connect()

    aux = Auxiliary(ims)
    sf = SystemFunc(ims)

    root = tk.Tk()
    root.title("Auxiliary LED Assignment")

    main_frame = ttk.Frame(root, padding=10)
    main_frame.grid(row=0, column=0, sticky="nsew")

    # LED assignment panel
    led_frame = ttk.LabelFrame(main_frame, text="LED Assignment", padding=10)
    led_frame.grid(row=0, column=0, padx=5, pady=5, sticky="nsew")

    combo_boxes = []
    for i in range(3):
        label = ttk.Label(led_frame, text=f"{LED_SINK_NAMES[i]} LED:")
        label.grid(row=i, column=0, padx=5, pady=5, sticky="e")

        combo = ttk.Combobox(led_frame, values=LED_SOURCE_NAMES, state="readonly")
        combo.grid(row=i, column=1, padx=5, pady=5, sticky="w")
        combo.current(0)  # Default to OFF
        combo.bind("<<ComboboxSelected>>", lambda e, idx=i: assign_led(idx, e.widget.get()))
        combo_boxes.append(combo)

    # Default Values panel with STORE button
    default_frame = ttk.LabelFrame(main_frame, text="Save Default Values to System Flash", padding=10)
    default_frame.grid(row=1, column=0, padx=5, pady=10, sticky="nsew")

    store_button = ttk.Button(default_frame, text="STORE", command=lambda: store_defaults(sf))
    store_button.pack(padx=10, pady=10)

    root.mainloop()

ims.Disconnect()