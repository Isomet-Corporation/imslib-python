# Example GUI program for programming iVCS device
# Uses Qt Pyside6 (run "pip install pyside6" in your venv)

import sys
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget,
    QVBoxLayout, QHBoxLayout, QGridLayout,
    QLabel, QPushButton, QLineEdit,
    QComboBox, QGroupBox, QRadioButton,
    QMessageBox, QTabWidget, QLCDNumber, 
    QButtonGroup
)
from PySide6.QtCore import QObject, Signal, QTimer
import threading

import imslib
from imslib import MHz, Percent, RFChannel, VCO
from ims_scan import iMSScanner
from ims_events import EventWaiter


# -------------------------------------------------
# Utilities
# -------------------------------------------------

def error_box(msg):
    QMessageBox.critical(None, "Error", msg)


def channel_from_text(text):
    if text == "1":
        return RFChannel(1)
    if text == "2":
        return RFChannel(2)
    if text.lower() == "both":
        return RFChannel()
    raise ValueError("Invalid channel")


# -------------------------------------------------
# Filter Controls
# -------------------------------------------------

class FilterWidget(QGroupBox):
    def __init__(self, vco):
        super().__init__("Filters")
        self.vco = vco

        layout = QGridLayout(self)

        # CIC
        layout.addWidget(QLabel("CIC Length (1-10)"), 0, 0)
        self.cic_len = QLineEdit("8")
        layout.addWidget(self.cic_len, 0, 1)

        btn_cic_on = QPushButton("Enable CIC")
        btn_cic_off = QPushButton("Disable CIC")
        layout.addWidget(btn_cic_on, 0, 4)
        layout.addWidget(btn_cic_off, 0, 5)

        btn_cic_on.clicked.connect(self.enable_cic)
        btn_cic_off.clicked.connect(
            lambda: self.vco.ConfigureCICFilter(False)
        )

        # IIR
        layout.addWidget(QLabel("IIR Cutoff (kHz)"), 1, 0)
        self.iir_cutoff = QLineEdit("10.0")
        layout.addWidget(self.iir_cutoff, 1, 1)

        layout.addWidget(QLabel("Stages (1-8)"), 1, 2)
        self.iir_stages = QLineEdit("2")
        layout.addWidget(self.iir_stages, 1, 3)

        btn_iir_on = QPushButton("Enable IIR")
        btn_iir_off = QPushButton("Disable IIR")
        layout.addWidget(btn_iir_on, 1, 4)
        layout.addWidget(btn_iir_off, 1, 5)

        btn_iir_on.clicked.connect(self.enable_iir)
        btn_iir_off.clicked.connect(
            lambda: self.vco.ConfigureIIRFilter(False)
        )

    def enable_cic(self):
        try:
            self.vco.ConfigureCICFilter(True, int(self.cic_len.text()))
        except Exception as e:
            error_box(str(e))

    def enable_iir(self):
        try:
            self.vco.ConfigureIIRFilter(
                True,
                float(self.iir_cutoff.text()),
                int(self.iir_stages.text())
            )
        except Exception as e:
            error_box(str(e))


# -------------------------------------------------
# Range Controls
# -------------------------------------------------

class RangeWidget(QGroupBox):
    def __init__(self, vco):
        super().__init__("Ranges")
        self.vco = vco

        layout = QGridLayout(self)

        self.channel = QComboBox()
        self.channel.addItems(["1", "2", "Both"])

        layout.addWidget(QLabel("Channel"), 0, 0)
        layout.addWidget(self.channel, 0, 1)

        # Frequency
        self.f_min = QLineEdit("50.0")
        self.f_max = QLineEdit("100.0")

        layout.addWidget(QLabel("Freq Min (MHz)"), 1, 0)
        layout.addWidget(self.f_min, 1, 1)
        layout.addWidget(QLabel("Freq Max (MHz)"), 1, 2)
        layout.addWidget(self.f_max, 1, 3)

        btn_freq = QPushButton("Set Frequency Range")
        layout.addWidget(btn_freq, 1, 4)
        btn_freq.clicked.connect(self.set_freq)

        # Amplitude
        self.a_min = QLineEdit("0")
        self.a_max = QLineEdit("100")

        layout.addWidget(QLabel("Ampl Min (%)"), 2, 0)
        layout.addWidget(self.a_min, 2, 1)
        layout.addWidget(QLabel("Ampl Max (%)"), 2, 2)
        layout.addWidget(self.a_max, 2, 3)

        btn_amp = QPushButton("Set Amplitude Range")
        layout.addWidget(btn_amp, 2, 4)
        btn_amp.clicked.connect(self.set_amp)

    def set_freq(self):
        try:
            ch = channel_from_text(self.channel.currentText())
            self.vco.SetFrequencyRange(
                MHz(float(self.f_min.text())),
                MHz(float(self.f_max.text())),
                ch
            )
        except Exception as e:
            error_box(str(e))

    def set_amp(self):
        try:
            ch = channel_from_text(self.channel.currentText())
            self.vco.SetAmplitudeRange(
                Percent(float(self.a_min.text())),
                Percent(float(self.a_max.text())),
                ch
            )
        except Exception as e:
            error_box(str(e))


# -------------------------------------------------
# Gain
# -------------------------------------------------

class GainWidget(QGroupBox):
    def __init__(self, vco):
        super().__init__("Digital Gain")
        self.vco = vco

        layout = QHBoxLayout(self)

        self.gains = {}
        for g in (1, 2, 4, 8):
            rb = QRadioButton(f"{g}x")
            self.gains[g] = rb
            layout.addWidget(rb)

        self.gains[1].setChecked(True)

        # Button group for exclusivity
        group = QButtonGroup(self)
        group.setExclusive(True)
        for g, rb in self.gains.items():
            group.addButton(rb)
            rb.toggled.connect(lambda checked, b=rb: self._on_toggled(b, checked))        


    def _on_toggled(self, button, checked):
        if not checked:
            return  # Only act when the button becomes checked

        mapping = {
            1: VCO.VCOGain_X1,
            2: VCO.VCOGain_X2,
            4: VCO.VCOGain_X4,
            8: VCO.VCOGain_X8,
        }
        for g, rb in self.gains.items():
            if rb.isChecked():
                self.vco.ApplyDigitalGain(mapping[g])
                return


# -------------------------------------------------
# Routing
# -------------------------------------------------

class RoutingWidget(QGroupBox):
    def __init__(self, vco):
        super().__init__("Routing / Tracking")
        self.vco = vco

        layout = QHBoxLayout(self)

        self.output = QComboBox()
        self.output.addItems([
            "CH1 Frequency",
            "CH1 Amplitude",
            "CH2 Frequency",
            "CH2 Amplitude"
        ])

        self.input = QComboBox()
        self.input.addItems(["Input A", "Input B"])

        self.track = QComboBox()
        self.track.addItems([
            "Track",
            "Hold / Freeze",
            "External Pin Control"
        ])

        btn = QPushButton("Set")

        layout.addWidget(self.output)
        layout.addWidget(self.input)
        layout.addWidget(self.track)
        layout.addWidget(btn)

        btn.clicked.connect(self.route)

    def route(self):
        out_map = [
            VCO.VCOOutput_CH1_FREQUENCY,
            VCO.VCOOutput_CH1_AMPLITUDE,
            VCO.VCOOutput_CH2_FREQUENCY,
            VCO.VCOOutput_CH2_AMPLITUDE,
        ]
        in_map = {
            0: VCO.VCOInput_A,
            1: VCO.VCOInput_B,
        }
        track_map = [
            VCO.VCOTracking_TRACK,
            VCO.VCOTracking_HOLD,
            VCO.VCOTracking_PIN_CONTROLLED,
        ]

        self.vco.Route(
            out_map[self.output.currentIndex()],
            in_map[self.input.currentIndex()]
        )
        self.vco.TrackingMode(
            out_map[self.output.currentIndex()],
            track_map[self.track.currentIndex()]
        )


# -------------------------------------------------
# Muting
# -------------------------------------------------

class RFMuteWidget(QGroupBox):
    def __init__(self, vco):
        super().__init__("RF Mute Control")
        self.vco = vco

        layout = QGridLayout(self)

        # Header
        layout.addWidget(QLabel("RF Channel"), 0, 0)
        layout.addWidget(QLabel("Mode"), 0, 1)

        # Rows
        self._create_row(layout, row=1, label="Ch 1", channel=RFChannel(1))
        self._create_row(layout, row=2, label="Ch 2", channel=RFChannel(2))

    def _create_row(self, layout, row, label, channel):
        layout.addWidget(QLabel(label), row, 0)

        rb_run = QRadioButton("Run")
        rb_mute = QRadioButton("Mute")
        rb_pin = QRadioButton("Pin Control")

        rb_run.setChecked(True)

        # Per-row button group
        group = QButtonGroup(self)
        group.setExclusive(True)
        group.addButton(rb_run)
        group.addButton(rb_mute)
        group.addButton(rb_pin)

        layout.addWidget(rb_run, row, 1)
        layout.addWidget(rb_mute, row, 2)
        layout.addWidget(rb_pin, row, 3)

        for rb in (rb_run, rb_mute, rb_pin):
            rb.toggled.connect(lambda checked, b=rb, ch=channel: self._on_toggled(b, ch, checked))

    def _on_toggled(self, button, channel, checked):
        if not checked:
            return  # Only act when button becomes checked

        text = button.text()
        if text == "Run":
            mute = VCO.VCOMute_UNMUTE
        elif text == "Mute":
            mute = VCO.VCOMute_MUTE
        elif text == "Pin Control":
            mute = VCO.VCOMute_PIN_CONTROLLED
        else:
            return

        try:
            self.vco.RFMute(mute, channel)
        except Exception as e:
            QMessageBox.critical(self, "Error", str(e))

# -------------------------------------------------
# Constants & Startup
# -------------------------------------------------

class ConstantWidget(QGroupBox):
    def __init__(self, vco):
        super().__init__("Constant Output")
        self.vco = vco

        layout = QGridLayout(self)

        self.channel = QComboBox()
        self.channel.addItems(["1", "2", "Both"])

        self.freq = QLineEdit("50.0")
        self.amp = QLineEdit("75.0")

        layout.addWidget(QLabel("Channel"), 0, 0)
        layout.addWidget(self.channel, 0, 1)

        layout.addWidget(QLabel("Frequency (MHz)"), 1, 0)
        layout.addWidget(self.freq, 1, 1)

        btn_f = QPushButton("Set Frequency")
        layout.addWidget(btn_f, 1, 2)
        btn_f.clicked.connect(self.set_freq)

        layout.addWidget(QLabel("Amplitude (%)"), 2, 0)
        layout.addWidget(self.amp, 2, 1)

        btn_a = QPushButton("Set Amplitude")
        layout.addWidget(btn_a, 2, 2)
        btn_a.clicked.connect(self.set_amp)

    def set_freq(self):
        try:
            self.vco.SetConstantFrequency(
                MHz(float(self.freq.text())),
                channel_from_text(self.channel.currentText())
            )
        except Exception as e:
            error_box(str(e))

    def set_amp(self):
        try:
            self.vco.SetConstantAmplitude(
                Percent(float(self.amp.text())),
                channel_from_text(self.channel.currentText())
            )
        except Exception as e:
            error_box(str(e))


# -------------------------------------------------
# Main Window
# -------------------------------------------------

class MainWindow(QMainWindow):
    def __init__(self, ims, vco, event_bridge):
        super().__init__()
        self.setWindowTitle("iVCS Control Panel")
        self.vco = vco

        tabs = QTabWidget()
        self.setCentralWidget(tabs)
        
        # Control tab
        control = QWidget()        
        control_layout = QVBoxLayout(control)

        control_layout.addWidget(FilterWidget(vco))
        control_layout.addWidget(RangeWidget(vco))
        control_layout.addWidget(GainWidget(vco))
        control_layout.addWidget(RoutingWidget(vco))
        control_layout.addWidget(RFMuteWidget(vco))
        control_layout.addWidget(ConstantWidget(vco))

        btn_save = QPushButton("Save Startup State")
        btn_save.clicked.connect(self.save_state)
        control_layout.addWidget(btn_save)

        tabs.addTab(control, "Control")

        # Monitoring tab
        tabs.addTab(
            MonitoringWidget(vco, event_bridge),
            "Monitoring"
        )        

    def save_state(self):
        self.vco.SaveStartupState()
        QMessageBox.information(None, "Saved", "VCO Configuration Stored to iVCS")


# -------------------------------------------------
# VCO Monitor Event loop thread
# -------------------------------------------------

class VCOEventBridge(QObject):
    voltage_ready = Signal(dict)

    def __init__(self, vco):
        super().__init__()
        self.vco = vco

    def on_voltage_read_complete(self):
        """
        Called by vco_event_loop when the async read completes
        """
        try:
            data = dict(self.vco.GetVoltageInputDataStr().items())
            self.voltage_ready.emit(data)
        except Exception as e:
            print("Voltage read error:", e)

class VCOEventLoop(threading.Thread):
    def __init__(self, vco, waiter, event_messages, event_bridge):
        super().__init__(daemon=True)
        self.waiter = waiter
        self.vco = vco
        self.event_messages = event_messages
        self._running = threading.Event()
        self.event_bridge = event_bridge
        #self.vco_update = False

    def subscribe(self):
        for evt in self.event_messages.keys():
            self.vco.VCOEventSubscribe(evt, self.waiter)

    def unsubscribe(self):
        for evt in self.event_messages.keys():
            self.vco.VCOEventUnsubscribe(evt, self.waiter)

    def run(self):
        self._running.set()
        self.subscribe()
        try:
            while self._running.is_set():
                try:
                    msg, args = self.waiter.wait(timeout=0.1)
                    if msg == imslib.VCOEvents_VCO_UPDATE_AVAILABLE:
                        self.event_bridge.on_voltage_read_complete()
                except TimeoutError:
                    continue
        finally:
            self.unsubscribe()

    def stop(self):
        self._running.clear()

VCO_EVENT_MESSAGES = {
    imslib.VCOEvents_VCO_UPDATE_AVAILABLE: "VCO Update",
    imslib.VCOEvents_VCO_READ_FAILED: "VCO Read Failed",
}


class MonitoringWidget(QGroupBox):
    def __init__(self, vco, event_bridge):
        super().__init__("Input Monitoring")
        self.vco = vco

        layout = QGridLayout(self)

        self.displays = {}

        labels = [
            "Voltage Input Ch A",
            "Voltage Input Ch B",
            "Processed Value Ch A",
            "Processed Value Ch B",
        ]

        for row, name in enumerate(labels):
            layout.addWidget(QLabel(name), row, 0)

            lcd = QLCDNumber()
            lcd.setDigitCount(7)          # xxx.xxx
            lcd.setSmallDecimalPoint(True)
            lcd.setSegmentStyle(QLCDNumber.Flat)
            lcd.display("0.000")

            layout.addWidget(lcd, row, 1)
            if "Voltage" in name:
                layout.addWidget(QLabel("Volts"), row, 2)
            else:
                layout.addWidget(QLabel("%"), row, 2)

            self.displays[name] = lcd

        # Connect event signal
        event_bridge.voltage_ready.connect(self.update_values)

        # Timer to trigger readback
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.request_update)
        self.timer.start(200)  # 5 Hz update rate

    def request_update(self):
        """
        Trigger async readback
        """
        try:
            self.vco.ReadVoltageInput()
        except Exception as e:
            print("ReadVoltageInput failed:", e)

    def update_values(self, data):
        """
        Called when async read completes
        """
        for key, percent_obj in data.items():
            if key not in self.displays:
                continue
            try:
                value = float(percent_obj)
                if "Voltage" in key:                
                    value /= 10.0
                self.displays[key].display(f"{value:.3f}")
            except Exception as e:
                print(f"Failed to update {key}: {e}")

# -------------------------------------------------
# Entry Point
# -------------------------------------------------

def main():
    app = QApplication(sys.argv)

    scanner = iMSScanner()
    if not scanner.scan():
        sys.exit(1)

    ims = scanner.get_system()
    if ims.Synth().Model() != "iVCS":
        error_box("Require an iVCS Synthesiser to run this application!")
        sys.exit(1)

    ims.Connect()

    vco = VCO(ims)

    VCOWaiter = EventWaiter()
    VCOWaiter.listen_for(list(VCO_EVENT_MESSAGES.keys()))

    # Start threads to listen for callbacks from library and input from user
    event_bridge = VCOEventBridge(vco)
    vco_event_loop = VCOEventLoop(vco, VCOWaiter, VCO_EVENT_MESSAGES, event_bridge)
    vco_event_loop.start()

    win = MainWindow(ims, vco, event_bridge)
    win.show()

    app.exec()

    ims.Disconnect()


if __name__ == "__main__":
    main()
