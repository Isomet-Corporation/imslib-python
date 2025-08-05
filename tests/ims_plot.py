
import matplotlib.pyplot as plt

###################################
# Image Plotting Functions
###################################

def plot_ImageFreq(img, ax=None, title=""):
    if ax == None:
        fig, ax = plt.subplots()

    # Extract each channel into a list
    ch1 = [pt.FreqCh1 for pt in img]
    ch2 = [pt.FreqCh2 for pt in img]
    ch3 = [pt.FreqCh3 for pt in img]
    ch4 = [pt.FreqCh4 for pt in img]

    # Plot
    ax.plot(ch1, label="Ch1")
    ax.plot(ch2, label="Ch2")
    ax.plot(ch3, label="Ch3")
    ax.plot(ch4, label="Ch4")

    ax.set_xlabel("Index")
    ax.set_ylabel("Frequency (MHz)")
    if title=="":
        ax.set_title("Image Frequency")
    else:
        ax.set_title(title)
    ax.legend()
    ax.grid(True)

def plot_ImageFreqXY(img, ax=None, title=""):
    if ax == None:
        fig, ax = plt.subplots()

    # Extract each channel into a list
    ch1 = [pt.FreqCh1 for pt in img]
    ch2 = [pt.FreqCh2 for pt in img]
    ch3 = [pt.FreqCh3 for pt in img]
    ch4 = [pt.FreqCh4 for pt in img]

    # Plot using ch1 as X and ch3 as Y
    ax.plot(ch1, ch3, label="XY")

    ax.set_xlabel("X Channel Frequency (MHz)")
    ax.set_ylabel("X Channel Frequency (MHz)")
    if title=="":
        ax.set_title("X/Y Plot")
    else:
        ax.set_title(title)
    ax.legend()
    ax.grid(True)

def plot_ImagAmpl(img, ax=None, title=""):
    if ax == None:
        fig, ax = plt.subplots()

    # Extract each channel into a list
    ch1 = [pt.AmplCh1 for pt in img]
    ch2 = [pt.AmplCh2 for pt in img]
    ch3 = [pt.AmplCh3 for pt in img]
    ch4 = [pt.AmplCh4 for pt in img]

    # Plot
    ax.plot(ch1, label="Ch1")
    ax.plot(ch2, label="Ch2")
    ax.plot(ch3, label="Ch3")
    ax.plot(ch4, label="Ch4")

    ax.set_xlabel("Index")
    ax.set_ylabel("Amplitude (%)")
    if title=="":
        ax.set_title("Image Amplitude")
    else:
        ax.set_title(title)
    ax.legend()
    ax.grid(True)

def plot_ImagPhase(img, ax=None, title=""):
    if ax == None:
        fig, ax = plt.subplots()

    # Extract each channel into a list
    ch1 = [pt.PhaseCh1 for pt in img]
    ch2 = [pt.PhaseCh2 for pt in img]
    ch3 = [pt.PhaseCh3 for pt in img]
    ch4 = [pt.PhaseCh4 for pt in img]

    # Plot
    ax.plot(ch1, label="Ch1")
    ax.plot(ch2, label="Ch2")
    ax.plot(ch3, label="Ch3")
    ax.plot(ch4, label="Ch4")

    ax.set_xlabel("Index")
    ax.set_ylabel("Phase (°)")
    if title=="":
        ax.set_title("Image Phase")
    else:
        ax.set_title(title)
    ax.legend()
    ax.grid(True)

def plot_ImagSyncA(img, ax=None, title=""):
    if ax == None:
        fig, ax = plt.subplots()

    # Extract each channel into a list
    a1 = [max(0.0, min(1.0, pt.SyncA1)) for pt in img]
    a2 = [max(0.0, min(1.0, pt.SyncA2)) for pt in img]

    # Plot
    ax.plot(a1, label="Analogue 1")
    ax.plot(a2, label="Analogue 2")
        
    ax.set_xlabel("Index")
    ax.set_ylabel("Sync Data")
    if title=="":
        ax.set_title("Analogue Sync Data")
    else:
        ax.set_title(title)
    ax.legend()
    ax.grid(True)

def plot_ImagSyncD(img, ax=None, title=""):
    if ax == None:
        fig, ax = plt.subplots()

    # Extract Sync Data into a list
    d = [pt.SyncD for pt in img]
    t = range(len(d))

    # Extract each bit
    bits = [[] for _ in range(12)]
    for val in d:
        for i in range(12):
            bit = (val >> i) & 1
            bits[i].append(bit)

    # Plot
    for i in range(12):
        ax.step(t, [x+3*i for x in bits[i]], 'r', label="Ch1")

    for tbit, bit in enumerate(bits):
        ax.text(-(len(d)/25), 3*tbit, str(tbit))
        
    ax.set_xlabel("Index")
    ax.set_ylabel("Sync Data")
    if title=="":
        ax.set_title("Digital Sync Data")
    else:
        ax.set_title(title)
    ax.grid(True)

def plot_ImageFAP(img):
    fig, axs = plt.subplots(3, figsize=(6,10))
    plot_ImageFreq(img, axs[0])
    plot_ImagAmpl(img, axs[1])
    plot_ImagPhase(img, axs[2])

def plot_ImageAll(img):
    fig, axs = plt.subplots(3, 2, figsize=(12,10))
    plot_ImageFreq(img, axs[0,0])
    plot_ImagAmpl(img, axs[1,0])
    plot_ImagPhase(img, axs[2,0])
    plot_ImagSyncA(img, axs[0,1])
    plot_ImagSyncD(img, axs[1,1])
