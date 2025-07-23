import imslib

print("Test 04: iMS Defined Types")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

#############################
# Basic Assignment
#############################

print()
print("Let's test some useful basic types")
f = imslib.Frequency(1500)
print(f"f is {f.value}")
f.value = 2500
print(f"f is now {f.value}")

a = imslib.Percent(75)
print(f"a is {a.value}")
a.value = 60
print(f"a is now {a.value}")
a.value = 125
print(f"But it cannot be 125: {a.value}")
a.value = -10
print(f"Or negative: {a.value}")

p = imslib.Degrees(90)
print(f"p is {p.value}")
p.value = 30
print(f"p is now {p.value}")
p.value = 420
print(f"You can go around more than once: {p.value}")
p.value = -90
print(f"Or go backwards: {p.value}")

#############################
# Test Inheritance
#############################

print()
print("Now let's try some types derived from iMS::Frequency")
k = imslib.kHz(f)
print(f"f is also {k.value}kHz")
M = imslib.MHz(f)
print(f"and {M.value}MHz")
M2 = imslib.MHz(k)
print(f"I can also see that k is {M2.value}MHz")
M3 = imslib.MHz(5)
print(f"If I want to go really fast, I can try {M3.value}MHz")
f2 = imslib.Frequency()
f2 = M3  # BAD
print(f"But beware. In python, assignment just rebinds the object so this is not the same in Hertz: {f2.value}Hz")
f2.assign(M3)
print(f"Instead, I must use the assign operator: {f2.value}Hz")
start = imslib.kHz(75.0)
incr = imslib.Frequency(100)
print(f"I can iterate using mixed types, so let's start at {start.value}kHz")
freqHz = imslib.Frequency(start)
freqkHz = start
freqMHz = imslib.MHz(start)
for I in range(1,11):
    freqHz += incr
    freqkHz += incr
    freqMHz += incr
    print(f"  iteration {I}: {freqHz.value}Hz / {freqkHz.value:.3}kHz / {freqMHz.value:.3}MHz")
start = imslib.MHz(1.5)
incr = imslib.kHz(50)
freqMHz = start
print(f"Or {start.value}MHz")
for I in range(1,11):
    freqMHz -= incr
    print(f"  iteration {I}: {freqMHz.value:.3}MHz")

#############################
# Structured Types
#############################

print()
print("Now let's test some structured types")
print("A FAP has a Frequency, Amplitude and a Phase, for example,")
fap1 = imslib.FAP(50.0, 80.0, 15.0)
print(fap1)
fap2 = fap1  ## NOTE: This is incorrect!
print(f"Copy test: Does FAP1 == FAP2? {fap2 == fap1}")
fap2.freq = imslib.MHz(60.0)
print(f"Now FAP2 frequency is {fap2.freq.value} so FAP1 != FAP2? {fap2 != fap1}")
fap2 = imslib.FAP(fap1)
fap1.freq = imslib.MHz(70.0)
print(f"With correct copy syntax, FAP1 != FAP2: {fap1 != fap2}")

print()
print("An iMS System can have up to 4 RF Channels. I can iterate through them like this...")
chan = imslib.RFChannel()
chan.value = 1
for i in chan:
    print(f" Channel {i}")  # prints 1 to 4
print(f"without mutating the original variable: {chan}")
print(f"Don't try and assign a variable that is out of range: chan = 0 => {imslib.RFChannel(0)} chan = 5 => {imslib.RFChannel(5)}")
print(f"We can obtain the value like this: My channel number is {int(chan)}")
print("Increment/Decrememnt it, limited to min/max:")
for i in range(5):
    print(int(chan))
    chan += 1
for i in range(5):
    print(int(chan))
    chan -= 1
chan.value = imslib.RFChannel.all
print(f"There is a special value that represents 'All Channels' to library code: IsAll() = {chan.IsAll()}")
print(f"Finally, we can use comparison operators. Is Channel 1 == Channel 2? {imslib.RFChannel(1) == imslib.RFChannel(2)}. Is Channel 1 < Channel 2? {imslib.RFChannel(1) < imslib.RFChannel(2)}")

