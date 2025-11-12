import imslib
import sys
import time
import threading

from ims_scan import iMSScanner
from ims_events import EventWaiter

from imslib import SystemFunc, Diagnostics

import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.widgets as mwidgets
import time
import itertools

print("Test 19: System Diagnostics Plotter")

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
# Diagnostics Monitor Event loop thread
#############################

class DiagEventLoop(threading.Thread):
    def __init__(self, diag, waiter, event_messages):
        super().__init__(daemon=True)
        self.waiter = waiter
        self.diag = diag
        self.event_messages = event_messages
        self.event_monitor = {}
        self._running = threading.Event()
        self.diag_update = False

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
                    if msg == imslib.DiagnosticsEvents_DIAGNOSTICS_UPDATE_AVAILABLE:
                        self.diag_update = True
                    elif msg == imslib.DiagnosticsEvents_DIAG_READ_FAILED:
                        self.diag_update = False
                    elif msg in self.event_messages:
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

DIAG_EVENT_MESSAGES = {
    imslib.DiagnosticsEvents_AOD_TEMP_UPDATE: "AOD Temperature",
    imslib.DiagnosticsEvents_RFA_TEMP_UPDATE: "RF Amp Temperature",
    imslib.DiagnosticsEvents_DIAGNOSTICS_UPDATE_AVAILABLE: "Diagnostics Update",
    imslib.DiagnosticsEvents_DIAG_READ_FAILED: "Diagnostics Read Failed",
}

#############################
# Create Listening Threads
#############################

SystemFuncWaiter = EventWaiter()
SystemFuncWaiter.listen_for(list(TEMP_EVENT_MESSAGES.keys()))

DiagnosticsWaiter = EventWaiter()
DiagnosticsWaiter.listen_for(list(DIAG_EVENT_MESSAGES.keys()))

# Start threads to listen for callbacks from library and input from user
temp_event_loop = TemperatureEventLoop(sf, SystemFuncWaiter, TEMP_EVENT_MESSAGES)
temp_event_loop.start()

diag_event_loop = DiagEventLoop(diag, DiagnosticsWaiter, DIAG_EVENT_MESSAGES)
diag_event_loop.start()

#############################
# Main Animation Plotter
#############################

# --- SETTINGS ---
ROLLING_WINDOW = 60      # seconds visible on graph
UPDATE_INTERVAL = 1000   # ms between updates (1 Hz)
CHANNELS = [1, 2, 3, 4]

# --- Matplotlib Setup ---
plt.style.use("seaborn-v0_8-darkgrid")
fig, axes = plt.subplots(4, 1, figsize=(12, 10), sharex=True)

# Leave space for widgets on right
plt.subplots_adjust(left=0.08, right=0.75, top=0.9, bottom=0.1, hspace=0.3)
fig.suptitle("iMS Diagnostics Live Monitor", fontsize=16, weight="bold")

# Separate axes
ax_forward, ax_reflected, ax_dc, ax_temp = axes

# Distinct colors for 4 channels
colors = plt.cm.tab10.colors[:len(CHANNELS)]  # First 4 colors
channel_colors = {ch: colors[i] for i, ch in enumerate(CHANNELS)}

# --- RF Power Plots ---
power_metrics = ["Forward", "Reflected", "DC Current"]
power_axes = [ax_forward, ax_reflected, ax_dc]
power_lines = {metric: [] for metric in power_metrics}
channel_enabled = {ch: True for ch in CHANNELS}  # track enabled channels

for metric, ax in zip(power_metrics, power_axes):
    for ch in CHANNELS:
        line, = ax.plot([], [], label=f"Ch{ch}", color=channel_colors[ch])
        power_lines[metric].append(line)
    ax.set_title(metric + " Power / Current")
    ax.set_ylabel("%")
    ax.legend(ncol=len(CHANNELS), fontsize=8)
    ax.grid(True)

# --- Temperature Plot ---
temp_metrics = ["Synth Temp 1", "Synth Temp 2", "AOD Temp", "RFA Temp"]
temp_lines = []
temp_colors = plt.cm.Set2.colors[:len(temp_metrics)]
temp_enabled = {metric: True for metric in temp_metrics}
for metric, c in zip(temp_metrics, temp_colors):
    line, = ax_temp.plot([], [], label=metric, color=c)
    temp_lines.append(line)

ax_temp.set_title("System Temperatures")
ax_temp.set_xlabel("Time (s)")
ax_temp.set_ylabel("°C")
ax_temp.legend(ncol=2, fontsize=8)
ax_temp.grid(True)

#plt.tight_layout(rect=[0, 0, 1, 0.96])

# --- Data Buffers ---
start_time = time.time()
time_data = []
power_data = {metric: {ch: [] for ch in CHANNELS} for metric in power_metrics}
temp_data = {metric: [] for metric in temp_metrics}

# --- Pause Control ---
paused = False
pause_ax = fig.add_axes([0.77, 0.9, 0.2, 0.05])  # [left, bottom, width, height]
def toggle_pause(event):
    global paused
    paused = not paused
pause_button = mwidgets.Button(pause_ax, 'Pause/Resume')
pause_button.on_clicked(toggle_pause)

# --- Channel Checkboxes ---
checkbox_ax = fig.add_axes([0.77, 0.3, 0.2, 0.6])
checkbox_labels = [f"Ch{ch}" for ch in CHANNELS] + temp_metrics
initial_state = [True]*len(checkbox_labels)
checkbox = mwidgets.CheckButtons(checkbox_ax, checkbox_labels, initial_state)

def checkbox_func(label):
    if label.startswith("Ch"):
        ch = int(label[-1])
        channel_enabled[ch] = not channel_enabled[ch]
    else:
        temp_enabled[label] = not temp_enabled[label]

checkbox.on_clicked(checkbox_func)

# --- Animation Update Function ---
def update(frame):
    global time_data
    if paused:
        return list(sum(power_lines.values(), [])) + temp_lines

    # --- Read new data from hardware ---
    sf.ReadSystemTemperature(SystemFunc.TemperatureSensor_TEMP_SENSOR_1)
    sf.ReadSystemTemperature(SystemFunc.TemperatureSensor_TEMP_SENSOR_2)
    diag.UpdateDiagnostics()
    diag.GetTemperature(Diagnostics.TARGET_AO_DEVICE)
    diag.GetTemperature(Diagnostics.TARGET_RF_AMPLIFIER)

    # current time
    max_points = int(ROLLING_WINDOW * 1000 / UPDATE_INTERVAL)
    t = time.time() - start_time
    time_data.append(t)
    if len(time_data) > max_points:
        time_data.pop(0)

    # --- RF Diagnostics ---
    if diag_event_loop.diag_update:
        diag_data = dict(diag.GetDiagnosticsDataStr().items())
        for metric in power_metrics:
            for i, ch in enumerate(CHANNELS):
                key = f"{metric}_CH{ch}"
                val = diag_data.get(key, 0.0) or 0.0
                power_data[metric][ch].append(val)
                if len(power_data[metric][ch]) > max_points:
                    power_data[metric][ch].pop(0)

    # --- Temperatures ---
    temp_data["Synth Temp 1"].append(temp_event_loop.get_value(imslib.SystemFuncEvents_SYNTH_TEMPERATURE_1) or 0.0)
    temp_data["Synth Temp 2"].append(temp_event_loop.get_value(imslib.SystemFuncEvents_SYNTH_TEMPERATURE_2) or 0.0)
    temp_data["AOD Temp"].append(diag_event_loop.get_value(imslib.DiagnosticsEvents_AOD_TEMP_UPDATE) or 0.0)
    temp_data["RFA Temp"].append(diag_event_loop.get_value(imslib.DiagnosticsEvents_RFA_TEMP_UPDATE) or 0.0)
    for metric in temp_metrics:
        if len(temp_data[metric]) > max_points:
            temp_data[metric].pop(0)


    # --- Update power lines ---
    for metric, ax in zip(power_metrics, power_axes):
        visible_values = []
        for i, ch in enumerate(CHANNELS):
            line = power_lines[metric][i]
            if channel_enabled[ch]:
                line.set_data(time_data[-len(power_data[metric][ch]):], power_data[metric][ch])
                line.set_visible(True)
                visible_values.extend(power_data[metric][ch])
            else:
                line.set_visible(False)

        # Dynamic scaling
        if visible_values:
            ax.set_ylim(min(visible_values)*0.9, max(visible_values)*1.1+1)        

    # --- Update temperature plot ---
    visible_temp = []
    for i, line in enumerate(temp_lines):
        metric = temp_metrics[i]
        if temp_enabled[metric]:
            line.set_data(time_data[-len(temp_data[metric]):], temp_data[metric])
            line.set_visible(True)
            visible_temp.extend(temp_data[metric])
        else:
            line.set_visible(False)

    if visible_temp:
        ax_temp.set_ylim(min(visible_temp)*0.9, max(visible_temp)*1.1+1)

    # --- Compute X-axis limits ---
    if len(time_data) < max_points:
        xmin = 0
        xmax = max(ROLLING_WINDOW, time_data[-1] + 1)  # extend a bit beyond last point
    else:
        xmin = time_data[-1] - ROLLING_WINDOW
        xmax = time_data[-1]

    # Apply to all axes
    for ax in power_axes + [ax_temp]:
        ax.set_xlim(xmin, xmax)

    # force full redraw of updated limits
    fig.canvas.draw_idle()

    return list(sum(power_lines.values(), [])) + temp_lines

# --- Run animation ---
ani = animation.FuncAnimation(
    fig,
    update,
    interval=UPDATE_INTERVAL,
    blit=False,
    cache_frame_data=False
)
plt.show(block=True)

temp_event_loop.stop()
diag_event_loop.stop()

temp_event_loop.join()
diag_event_loop.join()

ims.Disconnect()
