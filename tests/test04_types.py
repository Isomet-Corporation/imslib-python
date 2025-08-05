import imslib

# Import specific types to avoid retyping imslib (without relying on import *)
from imslib import Frequency
from imslib import kHz
from imslib import MHz
from imslib import Degrees
from imslib import Percent
from imslib import FAP
from imslib import RFChannel

print("Test 04: iMS Defined Types")

ver = imslib.LibVersion()
print("Using iMS Library version ", ver.GetVersion())

#############################
# Basic Assignment
#############################

print()
print("Let's test some useful basic types")
f = Frequency(1500)
print(f"f is {f}")
f.value = 2500
print(f"f is now {f}")

a = Percent(75)
print(f"a is {a}")
a.value = 60
print(f"a is now {a}")
a.value = 125
print(f"But it cannot be 125: {a}")
a.value = -10
print(f"Or negative: {a}")

p = Degrees(90)
print(f"p is {p}")
p.value = 30
print(f"p is now {p}")
p.value = 420
print(f"You can go around more than once: {p}")
p.value = -90
print(f"Or go backwards: {p}")

#############################
# Test Inheritance
#############################

print()
print("Now let's try some types derived from iMS::Frequency")
k = kHz(f)
print(f"f is also {k}")
M = MHz(f)
print(f"and {M}")
M2 = MHz(k)
print(f"I can also see that k is {M2}")
M3 = MHz(5)
print(f"If I want to go really fast, I can try {M3}")
f2 = Frequency()
f2 = M3  # BAD
print(f"But beware. In python, assignment just rebinds the object so this is not the same in Hertz: {f2}")
f2 = Frequency()
f2.assign(M3)
print(f"Instead, I must use the assign operator: {f2}")
start = kHz(75.0)
incr = Frequency(100)
print(f"I can iterate using mixed types, so let's start at {start}")
freqHz = Frequency(start)
freqkHz = start
freqMHz = MHz(start)
for I in range(1,11):
    freqHz += incr
    freqkHz += incr
    freqMHz += incr
    print(f"  iteration {I}: {freqHz} / {freqkHz:.3} / {freqMHz:.3}")
start = MHz(1.5)
incr = kHz(50)
freqMHz = start
print(f"Or {start}")
for I in range(1,11):
    freqMHz -= incr
    print(f"  iteration {I}: {freqMHz:.3}")

#############################
# Structured Types
#############################

print()
print("Now let's test some structured types")
print("A FAP has a Frequency, Amplitude and a Phase, for example,")
fap1 = FAP(50.0, 80.0, 15.0)
print(fap1)
fap2 = fap1  ## NOTE: This is incorrect!
print(f"Copy test: Does FAP1 == FAP2? {fap2 == fap1}")
fap2.freq = MHz(60.0)
print(f"Now FAP2 frequency is {fap2.freq.value} so FAP1 != FAP2? {fap2 != fap1}")
fap2 = FAP(fap1)
fap1.freq = MHz(70.0)
print(f"With correct copy syntax, FAP1 != FAP2: {fap1 != fap2}")

print()
print("An iMS System can have up to 4 RF Channels. I can iterate through them like this...")
chan = RFChannel()
chan.value = 1
for i in chan:
    print(f" Channel {i}")  # prints 1 to 4
print(f"without mutating the original variable: {chan}")
print(f"Don't try and assign a variable that is out of range: chan = 0 => {RFChannel(0)} chan = 5 => {RFChannel(5)}")
print(f"We can obtain the value like this: My channel number is {int(chan)}")
print("Increment/Decrement it, limited to min/max:")
for i in range(5):
    print(int(chan))
    chan += 1
for i in range(5):
    print(int(chan))
    chan -= 1
chan.value = RFChannel.all
print(f"There is a special value that represents 'All Channels' to library code: IsAll() = {chan.IsAll()}")
print(f"Finally, we can use comparison operators. Is Channel 1 == Channel 2? {RFChannel(1) == RFChannel(2)}. Is Channel 1 < Channel 2? {RFChannel(1) < RFChannel(2)}")

