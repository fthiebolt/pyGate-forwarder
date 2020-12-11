#
# WiPy module tests
#
# F.Thiebolt    dec.20  simple led tests
#

import time
import pycom

leds_values = [ 0xFF0000, 0x00FF00, 0x0000FF ]

# hello!
print("Simple led re-programming!")
time.sleep(1)

# stop heartbeat
pycom.heartbeat(False)

# change led colors
for v in leds_values:
    time.sleep(0.5)
    pycom.rgbled( v )

time.sleep(0.5)

# reactivate heartbeat
pycom.heartbeat(True)

