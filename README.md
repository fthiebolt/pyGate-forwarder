# pyGate-forwarder
[eCOnect] (great)PyGate as a (cheap) true 8 channels LoRaWAN packet forwarder: we directly connected our Nvidia Jetson Nano to the PyGate board through SPI bus.

![](Jetson-nano-PyGate-interco_dec20.jpg)

However, while this works seamlessly when connecting a RPi to a PyGate, it turns out to a total mess on Jetson nano ?!?!
**spoiler** the reason lies in the fact that SPI on nano does not releases the CS line ... thus SX1308 still waits before executing the received write operation!

## Getting started ##
As a side note, both 'lora_gateway' and 'packet_forwarder' are forks from Semtech version (https://github.com/Lora-net/lora_gateway https://github.com/Lora-net/packet_forwarder)

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

### Gateway setup ###

TO BE CONTINUED

### packet_forwarder start :) ###
[*MANDATORY*] Reset the board
```
./reset_pygate.py
```

TO BE CONTINUED

