# pyGate-forwarder
[eCOnect] PyGate packet forwarder while SPI connected to a Jetson Nano

Note: for an unknown reason, Jetson Nano failed to discuss with PyGate using SPI bus (while it perfectly work on RPi ?!?!)
... hence we have had to modify the `lgw_connect` fonction to remove the useless FPGA part and to set software reset of the SX1308

## Getting started ##
Both 'lora_gateway' and 'packet_forwarder' are forks from Semtech version (https://github.com/Lora-net/lora_gateway https://github.com/Lora-net/packet_forwarder)

### Compilation ###
```
cd lora_gateway
make
```
**WARNING** on Nvidia Jetson Nano, you ought to use `make CFLAGS=-DNVIDIA_CS_WORKAROUND`
This stems from a bug in SPI driver.

```
cd packet_fowarder
make
```

TO BE CONTINUED

### Gateway setup ###

TO BE CONTINUED

### packet_forwarder start :) ###
[*MANDATORY*] Reset the board
```
./reset_pygate.py
```

TO BE CONTINUED

